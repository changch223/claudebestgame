import Foundation
import SwiftData

enum PlayResult: String, Codable {
    case inProgress = "in_progress"
    case victory
    case defeat
    case abandoned
}

@Model
final class PlaySession {
    @Attribute(.unique) var id: UUID
    var caseId: UUID
    var caseKey: String
    var suspectId: UUID
    var startedAt: Date
    var endedAt: Date?
    var resultRaw: String
    var finalGauge: Double
    var vigilance: Double
    var turnCount: Int
    /// 0-indexed loop number for the same case key (0 = first attempt).
    var loopIndex: Int
    var score: Int
    var isBossBattle: Bool

    var result: PlayResult {
        get { PlayResult(rawValue: resultRaw) ?? .inProgress }
        set { resultRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        caseId: UUID,
        caseKey: String,
        suspectId: UUID,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        result: PlayResult = .inProgress,
        finalGauge: Double = 0,
        vigilance: Double = 0,
        turnCount: Int = 0,
        loopIndex: Int = 0,
        score: Int = 0,
        isBossBattle: Bool = false
    ) {
        self.id = id
        self.caseId = caseId
        self.caseKey = caseKey
        self.suspectId = suspectId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.resultRaw = result.rawValue
        self.finalGauge = max(0, min(1, finalGauge))
        self.vigilance = max(0, min(1, vigilance))
        self.turnCount = max(0, turnCount)
        self.loopIndex = max(0, loopIndex)
        self.score = score
        self.isBossBattle = isBossBattle
    }
}
