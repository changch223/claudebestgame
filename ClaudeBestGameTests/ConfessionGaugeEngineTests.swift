import XCTest
@testable import ClaudeBestGame

final class ConfessionGaugeEngineTests: XCTestCase {

    // MARK: - Legacy 2-arg API (pressing category, vigilance 0.0)

    func testSeverityNoneNoChange() {
        let result = ConfessionGaugeEngine.update(
            currentGauge: 0.4, severity: .none, difficulty: 1
        )
        XCTAssertEqual(result.delta, 0.0, accuracy: 0.0001)
        XCTAssertEqual(result.newGauge, 0.4, accuracy: 0.0001)
    }

    func testSeveritySmallDifficulty1() {
        let result = ConfessionGaugeEngine.update(
            currentGauge: 0.0, severity: .small, difficulty: 1
        )
        // 0.06 × 1.0 (d1) × 1.0 (pressing) × 1.0 (no vig) = 0.06
        XCTAssertEqual(result.delta, 0.06, accuracy: 0.0001)
    }

    func testSeverityMediumDifficulty1() {
        let result = ConfessionGaugeEngine.update(
            currentGauge: 0.0, severity: .medium, difficulty: 1
        )
        XCTAssertEqual(result.delta, 0.16, accuracy: 0.0001)
    }

    func testSeverityLargeDifficulty1IsThirtyTwo() {
        let result = ConfessionGaugeEngine.update(
            currentGauge: 0.5, severity: .large, difficulty: 1
        )
        XCTAssertEqual(result.delta, 0.32, accuracy: 0.0001)
        XCTAssertEqual(result.newGauge, 0.82, accuracy: 0.0001)
    }

    func testDifficulty5Multiplier() {
        // medium 0.16 × 0.6 = 0.096
        let result = ConfessionGaugeEngine.update(
            currentGauge: 0.0, severity: .medium, difficulty: 5
        )
        XCTAssertEqual(result.delta, 0.096, accuracy: 0.0001)
    }

    func testGaugeClampsAtOne() {
        let result = ConfessionGaugeEngine.update(
            currentGauge: 0.95, severity: .large, difficulty: 1
        )
        XCTAssertEqual(result.newGauge, 1.0, accuracy: 0.0001)
    }

    // MARK: - New 5-arg API (category-aware)

    func testEvidenceCategoryAmplifiesDelta() {
        // medium 0.16 × 1.0 × 1.8 × 1.0 = 0.288
        let r = ConfessionGaugeEngine.update(
            currentGauge: 0.0, severity: .medium, category: .evidence,
            difficulty: 1, vigilance: 0.0
        )
        XCTAssertEqual(r.delta, 0.288, accuracy: 0.0001)
    }

    func testNeutralCategoryReducesDelta() {
        // medium 0.16 × 0.6 = 0.096
        let r = ConfessionGaugeEngine.update(
            currentGauge: 0.0, severity: .medium, category: .neutral,
            difficulty: 1, vigilance: 0.0
        )
        XCTAssertEqual(r.delta, 0.096, accuracy: 0.0001)
    }

    func testHighVigilancePenalizesDelta() {
        // medium 0.16 × 1.0 × 1.0 × 0.4 = 0.064  (vig=1.0 → penalty 0.4)
        let r = ConfessionGaugeEngine.update(
            currentGauge: 0.0, severity: .medium, category: .pressing,
            difficulty: 1, vigilance: 1.0
        )
        XCTAssertEqual(r.delta, 0.064, accuracy: 0.0001)
    }
}
