import Foundation
import SwiftData

@Model
final class Progress {
    @Attribute(.unique) var id: UUID
    var totalCleared: Int
    var totalPlayed: Int
    var totalLoops: Int
    var perfectClears: Int  // クリア時の loopIndex == 0 の回数
    /// Stage that the player should attempt next (1..10, 11 = boss).
    var currentStage: Int
    var bossUnlocked: Bool
    var bossCleared: Bool
    var bonusModeUnlocked: Bool
    var highScoreOverall: Int
    var highScoreByTypeData: Data
    var lastPlayedAt: Date?

    static let singletonId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    init(
        totalCleared: Int = 0,
        totalPlayed: Int = 0,
        totalLoops: Int = 0,
        perfectClears: Int = 0,
        currentStage: Int = 1,
        bossUnlocked: Bool = false,
        bossCleared: Bool = false,
        bonusModeUnlocked: Bool = false,
        highScoreOverall: Int = 0,
        highScoreByType: [String: Int] = [:],
        lastPlayedAt: Date? = nil
    ) {
        self.id = Progress.singletonId
        self.totalCleared = totalCleared
        self.totalPlayed = totalPlayed
        self.totalLoops = totalLoops
        self.perfectClears = perfectClears
        self.currentStage = max(1, currentStage)
        self.bossUnlocked = bossUnlocked
        self.bossCleared = bossCleared
        self.bonusModeUnlocked = bonusModeUnlocked
        self.highScoreOverall = highScoreOverall
        self.highScoreByTypeData = (try? JSONEncoder().encode(highScoreByType)) ?? Data()
        self.lastPlayedAt = lastPlayedAt
    }

    var highScoreByType: [String: Int] {
        get { (try? JSONDecoder().decode([String: Int].self, from: highScoreByTypeData)) ?? [:] }
        set { highScoreByTypeData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }
}
