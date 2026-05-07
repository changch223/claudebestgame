import Foundation

struct FallbackChoice: Codable, Sendable {
    let text: String
    let category: String  // ChoiceCategory.rawValue

    var resolvedCategory: ChoiceCategory {
        ChoiceCategory(rawValue: category) ?? .neutral
    }
}

struct FallbackChoicePool: Codable, Sendable {
    let opening: [FallbackChoice]
    let pressing: [FallbackChoice]
    let aggressive: [FallbackChoice]
}

struct FallbackCase: Codable, Sendable {
    let id: String
    let stageNumber: Int
    let caseType: String
    let victimName: String
    let weapon: String
    let trueMotive: String
    let difficulty: Int
    let suspectName: String
    let suspectAge: Int
    let suspectJob: String
    let persona: String
    let alibiStory: String
    let weakPoint: String
    let contradictionKeywords: [String]
    let evidenceTriggers: [EvidenceTrigger]
    let choicePool: FallbackChoicePool
}

enum FallbackCaseProvider {

    static func loadAll() -> [FallbackCase] {
        guard let url = Bundle.main.url(
            forResource: "cases", withExtension: "json", subdirectory: "FallbackCases"
        ) ?? Bundle.main.url(forResource: "cases", withExtension: "json") else {
            assertionFailure("cases.json not found in bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([FallbackCase].self, from: data)
        } catch {
            assertionFailure("Failed to decode cases.json: \(error)")
            return []
        }
    }

    /// Returns the case for a specific stage number, or nil if not found.
    static func forStage(_ stage: Int) -> FallbackCase? {
        loadAll().first { $0.stageNumber == stage }
    }

    /// Returns a random case (used for bonus mode / freeplay).
    static func random(excluding excludedIDs: Set<String> = []) -> FallbackCase? {
        let all = loadAll().filter { !excludedIDs.contains($0.id) }
        return all.randomElement() ?? loadAll().randomElement()
    }
}
