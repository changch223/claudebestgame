import Foundation
import SwiftData

@Model
final class CaseRecord {
    @Attribute(.unique) var id: UUID
    /// Logical key (FallbackCase.id for fallback, or "ai-<uuid>" for AI-generated cases).
    var caseKey: String
    var caseType: String
    var victimName: String
    var weapon: String
    var trueMotive: String
    var difficulty: Int
    /// Stage number in the campaign (1..10, 11 for boss).
    var stageNumber: Int
    var isFallback: Bool
    var generatedAt: Date

    init(
        id: UUID = UUID(),
        caseKey: String,
        caseType: String,
        victimName: String,
        weapon: String,
        trueMotive: String,
        difficulty: Int,
        stageNumber: Int,
        isFallback: Bool,
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.caseKey = caseKey
        self.caseType = caseType
        self.victimName = victimName
        self.weapon = weapon
        self.trueMotive = trueMotive
        self.difficulty = max(1, min(5, difficulty))
        self.stageNumber = max(1, stageNumber)
        self.isFallback = isFallback
        self.generatedAt = generatedAt
    }
}
