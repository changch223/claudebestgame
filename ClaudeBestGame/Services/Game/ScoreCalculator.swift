import Foundation

enum ScoreCalculator {

    /// New turn-based scoring:
    ///   base = remainingTurns × 200
    ///   bonus = (difficulty - 1) × 1000
    ///   penalty = loopIndex × 300
    ///   boss multiplier = 3
    static func calculate(
        remainingTurns: Int,
        difficulty: Int,
        loopIndex: Int,
        isVictory: Bool,
        isBossBattle: Bool
    ) -> Int {
        guard isVictory else { return 0 }
        let clampedDifficulty = max(1, min(5, difficulty))
        let base = max(0, remainingTurns) * 200
        let bonus = (clampedDifficulty - 1) * 1000
        let penalty = max(0, loopIndex) * 300
        let bossMul = isBossBattle ? 3 : 1
        return max(0, (base + bonus - penalty) * bossMul)
    }

    /// Legacy time-based scoring for the deprecated 60-second mode (kept for tests).
    static func calculate(
        remainingSeconds: Double,
        difficulty: Int,
        isVictory: Bool,
        isBossBattle: Bool
    ) -> Int {
        guard isVictory else { return 0 }
        let clampedDifficulty = max(1, min(5, difficulty))
        let base = Int((remainingSeconds * 100).rounded())
        let bonus = (clampedDifficulty - 1) * 1000
        let bossMul = isBossBattle ? 3 : 1
        return (base + bonus) * bossMul
    }
}
