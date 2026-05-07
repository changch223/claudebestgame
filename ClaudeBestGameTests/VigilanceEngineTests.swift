import XCTest
@testable import ClaudeBestGame

final class VigilanceEngineTests: XCTestCase {

    func testNeutralChoiceDecaysVigilanceWhenNoContradiction() {
        let r = VigilanceEngine.update(
            currentVigilance: 0.5, category: .neutral,
            severity: .none, difficulty: 1
        )
        XCTAssertLessThan(r.newVigilance, 0.5)
    }

    func testPressingMissRaisesVigilance() {
        // pressing × none × d1: 0.10 × 1.0 = +0.10
        let r = VigilanceEngine.update(
            currentVigilance: 0.0, category: .pressing,
            severity: .none, difficulty: 1
        )
        XCTAssertEqual(r.newVigilance, 0.10, accuracy: 0.0001)
    }

    func testAggressiveBackfireBigger() {
        // aggressive × none × d1: 0.20
        let r = VigilanceEngine.update(
            currentVigilance: 0.0, category: .aggressive,
            severity: .none, difficulty: 1
        )
        XCTAssertEqual(r.newVigilance, 0.20, accuracy: 0.0001)
    }

    func testEvidenceMissIsHugePenalty() {
        // evidence × none × d1: 0.30
        let r = VigilanceEngine.update(
            currentVigilance: 0.0, category: .evidence,
            severity: .none, difficulty: 1
        )
        XCTAssertEqual(r.newVigilance, 0.30, accuracy: 0.0001)
    }

    func testEvidenceHitOnlyTinyVigilance() {
        // evidence × medium × d1: 0.02
        let r = VigilanceEngine.update(
            currentVigilance: 0.0, category: .evidence,
            severity: .medium, difficulty: 1
        )
        XCTAssertEqual(r.newVigilance, 0.02, accuracy: 0.0001)
    }

    func testDifficultyAmplifiesVigilanceGrowth() {
        // pressing miss at d5: 0.10 × 1.4 = 0.14
        let r = VigilanceEngine.update(
            currentVigilance: 0.0, category: .pressing,
            severity: .none, difficulty: 5
        )
        XCTAssertEqual(r.newVigilance, 0.14, accuracy: 0.0001)
    }

    func testVigilanceClampsAtOne() {
        let r = VigilanceEngine.update(
            currentVigilance: 0.9, category: .evidence,
            severity: .none, difficulty: 5
        )
        XCTAssertEqual(r.newVigilance, 1.0, accuracy: 0.0001)
    }
}
