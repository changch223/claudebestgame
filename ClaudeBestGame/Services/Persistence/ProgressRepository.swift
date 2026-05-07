import Foundation
import SwiftData

@MainActor
final class ProgressRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func load() -> Progress {
        let id = Progress.singletonId
        let descriptor = FetchDescriptor<Progress>(
            predicate: #Predicate { $0.id == id }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let new = Progress()
        context.insert(new)
        try? context.save()
        return new
    }

    /// Mark a case as cleared. Tracks loop count so the game can
    /// reward perfect (1-loop) clears.
    func markCleared(caseType: String, score: Int, isBoss: Bool, loopIndex: Int) {
        let progress = load()
        progress.totalPlayed += 1
        progress.totalCleared += 1
        progress.totalLoops += loopIndex   // count *extra* loops beyond the first attempt
        if loopIndex == 0 { progress.perfectClears += 1 }
        progress.lastPlayedAt = Date()

        if score > progress.highScoreOverall {
            progress.highScoreOverall = score
        }
        var byType = progress.highScoreByType
        if score > (byType[caseType] ?? 0) {
            byType[caseType] = score
        }
        progress.highScoreByType = byType

        if isBoss {
            progress.bossCleared = true
            progress.bonusModeUnlocked = true
        } else {
            progress.currentStage = min(11, progress.currentStage + 1)
        }
        if progress.totalCleared >= 10 && !progress.bossUnlocked {
            progress.bossUnlocked = true
        }

        try? context.save()
    }

    /// A failed attempt still counts a loop and a played session.
    func markDefeated(loopIndex: Int) {
        let progress = load()
        progress.totalPlayed += 1
        progress.totalLoops += loopIndex
        progress.lastPlayedAt = Date()
        try? context.save()
    }

    func reset() {
        let progress = load()
        progress.totalCleared = 0
        progress.totalPlayed = 0
        progress.totalLoops = 0
        progress.perfectClears = 0
        progress.currentStage = 1
        progress.bossUnlocked = false
        progress.bossCleared = false
        progress.bonusModeUnlocked = false
        progress.highScoreOverall = 0
        progress.highScoreByType = [:]
        progress.lastPlayedAt = nil
        try? context.save()
    }

    /// Get-or-create the singleton notebook for a given case key.
    func notebook(for caseKey: String) -> InvestigationNotebook {
        let descriptor = FetchDescriptor<InvestigationNotebook>(
            predicate: #Predicate { $0.caseKey == caseKey }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let new = InvestigationNotebook(caseKey: caseKey)
        context.insert(new)
        try? context.save()
        return new
    }

    /// Returns evidence items already discovered for this case key, in the
    /// order they were discovered.
    func evidence(for caseKey: String) -> [EvidenceItem] {
        let descriptor = FetchDescriptor<EvidenceItem>(
            predicate: #Predicate { $0.caseKey == caseKey },
            sortBy: [SortDescriptor(\.discoveredAt, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func recordEvidence(caseKey: String, title: String, detail: String, loopIndex: Int) {
        let existing = evidence(for: caseKey)
        guard !existing.contains(where: { $0.title == title }) else { return }
        let item = EvidenceItem(
            caseKey: caseKey,
            title: title,
            detail: detail,
            discoveredAtLoop: loopIndex
        )
        context.insert(item)
        try? context.save()
    }

    func save() {
        try? context.save()
    }
}
