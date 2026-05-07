import Foundation
import SwiftData
import Observation

struct DialogueMessage: Identifiable, Equatable, Sendable {
    let id: UUID = UUID()
    let speaker: Speaker
    let text: String
    let category: ChoiceCategory?     // player turn only
    let severity: ContradictionSeverity?  // suspect turn only
    let gaugeDelta: Double

    enum Speaker: String, Sendable { case player, suspect }
}

/// Loop / turn-based interrogation state machine.
@MainActor
@Observable
final class InterrogationViewModel {
    // Public observable state
    var fallbackCase: FallbackCase?
    var messages: [DialogueMessage] = []
    var gauge: Double = 0
    var vigilance: Double = 0
    var lastSeverity: ContradictionSeverity = .none
    var currentChoices: [QuestionChoice] = []
    var isAwaitingReply: Bool = false
    var turnIndex: Int = 0           // 0..maxTurns-1
    let maxTurns: Int
    var loopIndex: Int = 0
    var resultGauge: Double = 0
    var remainingTurns: Int = 0
    var score: Int = 0
    var didWin: Bool = false
    var newlyDiscoveredEvidence: [EvidenceDiscovery] = []  // for current loop's UI flash
    private(set) var endedAt: Date?
    private(set) var notebook: InvestigationNotebook?
    private(set) var ownedEvidence: [EvidenceItem] = []

    private let repository: ProgressRepository
    private let stageNumber: Int
    private let isBoss: Bool
    private var guardian: FallbackGuardian?
    private var ended: Bool = false
    private var priorPlayerTexts: [String] = []
    private var priorTurns: [(question: String, reply: String)] = []

    init(
        repository: ProgressRepository,
        stageNumber: Int,
        isBossBattle: Bool = false
    ) {
        self.repository = repository
        self.stageNumber = stageNumber
        self.isBoss = isBossBattle
        self.maxTurns = isBossBattle ? 8 : 6
    }

    // MARK: - Lifecycle

    /// Starts a new investigation (or restarts the current case). The notebook
    /// and evidence items persist across loops via SwiftData.
    func begin(loopIndex: Int = 0) {
        self.loopIndex = loopIndex
        self.ended = false
        self.endedAt = nil
        self.didWin = false
        self.gauge = 0
        self.vigilance = 0
        self.lastSeverity = .none
        self.turnIndex = 0
        self.messages = []
        self.priorPlayerTexts = []
        self.priorTurns = []
        self.newlyDiscoveredEvidence = []

        // Pick the case for this stage. Boss = stage 11 (no fallback case → use stage 10 alike)
        let stageToLoad = isBoss ? max(10, stageNumber) : stageNumber
        guard let c = FallbackCaseProvider.forStage(stageToLoad)
            ?? FallbackCaseProvider.random() else { return }
        self.fallbackCase = c
        self.guardian = FallbackGuardian(fallbackCase: c)

        // Notebook and evidence persist across loops via case key.
        self.notebook = repository.notebook(for: c.id)
        self.notebook?.totalLoops = max(self.notebook?.totalLoops ?? 0, loopIndex + 1)
        self.notebook?.lastUpdatedAt = Date()
        self.ownedEvidence = repository.evidence(for: c.id)

        // Suspect's opening line
        let intro = "私は\(c.suspectName)。\(c.alibiStory)"
        messages.append(DialogueMessage(
            speaker: .suspect, text: intro,
            category: nil, severity: nil, gaugeDelta: 0
        ))

        regenerateChoices()
    }

    // MARK: - Choice handling

    /// Player picks a choice. Drives the suspect reply, contradiction analysis,
    /// gauge / vigilance update, and evidence discovery.
    func play(choice: QuestionChoice) async {
        guard !ended,
              !isAwaitingReply,
              let c = fallbackCase,
              let guardian else { return }

        isAwaitingReply = true
        priorPlayerTexts.append(choice.text)
        messages.append(DialogueMessage(
            speaker: .player, text: choice.text,
            category: choice.category, severity: nil, gaugeDelta: 0
        ))

        // Brief delay to give the suspect "think" feedback
        try? await Task.sleep(for: .milliseconds(380))

        let reply = guardian.reply(to: choice.text, category: choice.category)

        // Detect contradiction
        let detection = ContradictionDetector.detect(
            playerQuestion: choice.text,
            suspectReply: reply,
            category: choice.category,
            contradictionKeywords: c.contradictionKeywords,
            priorTurns: priorTurns
        )

        // Update gauge
        let gaugeUpdate = ConfessionGaugeEngine.update(
            currentGauge: gauge,
            severity: detection.severity,
            category: choice.category,
            difficulty: c.difficulty,
            vigilance: vigilance
        )
        gauge = gaugeUpdate.newGauge
        lastSeverity = detection.severity

        // Update vigilance
        let vigilanceUpdate = VigilanceEngine.update(
            currentVigilance: vigilance,
            category: choice.category,
            severity: detection.severity,
            difficulty: c.difficulty
        )
        vigilance = vigilanceUpdate.newVigilance

        // Append suspect message
        messages.append(DialogueMessage(
            speaker: .suspect, text: reply,
            category: nil, severity: detection.severity, gaugeDelta: gaugeUpdate.delta
        ))

        // Discover evidence
        let discovered = EvidenceTracker.scan(
            playerQuestion: choice.text,
            suspectReply: reply,
            triggers: c.evidenceTriggers
        ).filter { found in
            !ownedEvidence.contains(where: { $0.title == found.title })
        }
        for d in discovered {
            repository.recordEvidence(
                caseKey: c.id, title: d.title, detail: d.detail, loopIndex: loopIndex
            )
        }
        if !discovered.isEmpty {
            newlyDiscoveredEvidence = discovered
            ownedEvidence = repository.evidence(for: c.id)
            // Add to notebook
            for d in discovered {
                notebook?.appendLine("【発見】\(d.title): \(d.detail)")
            }
        }
        // Flag potential suspect quotes when severity is non-trivial
        if detection.severity != .none {
            notebook?.flag(quote: reply)
        }
        repository.save()

        priorTurns.append((question: choice.text, reply: reply))
        turnIndex += 1
        isAwaitingReply = false

        // Win/lose evaluation
        if gauge >= 1.0 {
            endSession(victory: true)
        } else if vigilance >= VigilanceEngine.lossThreshold {
            endSession(victory: false)
        } else if turnIndex >= maxTurns {
            endSession(victory: false)
        } else {
            regenerateChoices()
        }
    }

    // MARK: - Regenerate choices each turn

    private func regenerateChoices() {
        guard let c = fallbackCase else { return }
        let evidenceTuples = ownedEvidence.map { (id: $0.id, title: $0.title, detail: $0.detail) }
        let context = ChoiceGeneratorContext(
            turnIndex: turnIndex,
            maxTurns: maxTurns,
            vigilance: vigilance,
            confessionGauge: gauge,
            evidenceItems: evidenceTuples,
            priorPlayerTexts: priorPlayerTexts
        )
        currentChoices = ChoiceGeneratorService.generate(for: c, context: context)
    }

    // MARK: - Session end

    private func endSession(victory: Bool) {
        guard !ended else { return }
        ended = true
        didWin = victory
        endedAt = Date()
        resultGauge = gauge
        remainingTurns = max(0, maxTurns - turnIndex)

        let difficulty = fallbackCase?.difficulty ?? 1
        let caseType = fallbackCase?.caseType ?? "unknown"

        score = ScoreCalculator.calculate(
            remainingTurns: remainingTurns,
            difficulty: difficulty,
            loopIndex: loopIndex,
            isVictory: victory,
            isBossBattle: isBoss
        )

        if victory {
            repository.markCleared(
                caseType: caseType,
                score: score,
                isBoss: isBoss,
                loopIndex: loopIndex
            )
            // After victory, clear evidence + notebook for this case to free up state
            // (per Outer Wilds idea: once truth is known, the case closes)
        } else {
            repository.markDefeated(loopIndex: loopIndex)
        }
    }
}
