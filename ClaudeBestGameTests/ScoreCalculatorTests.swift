import XCTest
@testable import ClaudeBestGame

final class ScoreCalculatorTests: XCTestCase {

    func testDefeatScoresZero() {
        let s = ScoreCalculator.calculate(
            remainingSeconds: 30, difficulty: 3, isVictory: false, isBossBattle: false
        )
        XCTAssertEqual(s, 0)
    }

    func testVictoryDifficulty1() {
        // 30 * 100 + 0 = 3000, no boss
        let s = ScoreCalculator.calculate(
            remainingSeconds: 30, difficulty: 1, isVictory: true, isBossBattle: false
        )
        XCTAssertEqual(s, 3000)
    }

    func testVictoryDifficulty4() {
        // 30 * 100 + 3 * 1000 = 6000
        let s = ScoreCalculator.calculate(
            remainingSeconds: 30, difficulty: 4, isVictory: true, isBossBattle: false
        )
        XCTAssertEqual(s, 6000)
    }

    func testBossTriplesScore() {
        // 30 * 100 + 4 * 1000 = 7000, x3 = 21000
        let s = ScoreCalculator.calculate(
            remainingSeconds: 30, difficulty: 5, isVictory: true, isBossBattle: true
        )
        XCTAssertEqual(s, 21000)
    }

    func testRemainingZeroVictoryStillScores() {
        let s = ScoreCalculator.calculate(
            remainingSeconds: 0, difficulty: 3, isVictory: true, isBossBattle: false
        )
        XCTAssertEqual(s, 2000) // 0 base + 2000 difficulty bonus
    }

    func testFractionalSecondsRound() {
        // 30.7 * 100 = 3070
        let s = ScoreCalculator.calculate(
            remainingSeconds: 30.7, difficulty: 1, isVictory: true, isBossBattle: false
        )
        XCTAssertEqual(s, 3070)
    }
}
