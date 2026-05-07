import XCTest
@testable import ClaudeBestGame

final class ChoiceGeneratorTests: XCTestCase {

    private let sampleCase = FallbackCase(
        id: "test-case",
        stageNumber: 1,
        caseType: "test",
        victimName: "X",
        weapon: "Y",
        trueMotive: "Z",
        difficulty: 1,
        suspectName: "S",
        suspectAge: 30,
        suspectJob: "J",
        persona: "stoic",
        alibiStory: "Alibi",
        weakPoint: "W",
        contradictionKeywords: ["a"],
        evidenceTriggers: [],
        choicePool: FallbackChoicePool(
            opening: [
                FallbackChoice(text: "O1", category: "neutral"),
                FallbackChoice(text: "O2", category: "neutral"),
                FallbackChoice(text: "O3", category: "pressing"),
                FallbackChoice(text: "O4", category: "aggressive")
            ],
            pressing: [
                FallbackChoice(text: "P1", category: "pressing"),
                FallbackChoice(text: "P2", category: "pressing"),
                FallbackChoice(text: "P3", category: "pressing")
            ],
            aggressive: [
                FallbackChoice(text: "A1", category: "aggressive"),
                FallbackChoice(text: "A2", category: "aggressive")
            ]
        )
    )

    private func ctx(
        turn: Int = 0,
        evidence: [(id: UUID, title: String, detail: String)] = [],
        priorTexts: [String] = []
    ) -> ChoiceGeneratorContext {
        ChoiceGeneratorContext(
            turnIndex: turn, maxTurns: 6, vigilance: 0,
            confessionGauge: 0, evidenceItems: evidence,
            priorPlayerTexts: priorTexts
        )
    }

    func testGeneratesUpToFourChoices() {
        let r = ChoiceGeneratorService.generate(for: sampleCase, context: ctx())
        XCTAssertGreaterThan(r.count, 0)
        XCTAssertLessThanOrEqual(r.count, 4)
    }

    func testEvidenceUnlocksEvidenceChoiceWhenOwned() {
        let evidence = [(id: UUID(), title: "妻の出張", detail: "海外にいた")]
        let r = ChoiceGeneratorService.generate(
            for: sampleCase, context: ctx(turn: 1, evidence: evidence)
        )
        XCTAssertTrue(r.contains(where: { $0.category == .evidence }))
    }

    func testNoEvidenceMeansNoEvidenceChoice() {
        let r = ChoiceGeneratorService.generate(for: sampleCase, context: ctx(turn: 1))
        XCTAssertFalse(r.contains(where: { $0.category == .evidence }))
    }

    func testPriorTextsAreNotRepeated() {
        let r = ChoiceGeneratorService.generate(
            for: sampleCase,
            context: ctx(priorTexts: ["O1", "O2", "O3", "O4"])
        )
        // Player has used all opening choices; the generator should pull from
        // pressing and aggressive pools instead.
        for choice in r {
            XCTAssertFalse(["O1", "O2", "O3", "O4"].contains(choice.text))
        }
    }

    func testLateTurnUsesPressingAndAggressive() {
        let r = ChoiceGeneratorService.generate(for: sampleCase, context: ctx(turn: 4))
        // No opening choices in the early slots
        let firstThree = r.prefix(3)
        XCTAssertFalse(firstThree.contains(where: { $0.text.hasPrefix("O") && $0.text != "O3" }))
    }
}
