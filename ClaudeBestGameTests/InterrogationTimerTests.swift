import XCTest
@testable import ClaudeBestGame

@MainActor
final class InterrogationTimerTests: XCTestCase {

    func testStartSetsRemainingAndIsRunning() async {
        let timer = InterrogationTimer()
        timer.start(seconds: 60)
        XCTAssertEqual(timer.remainingSeconds, 60, accuracy: 0.2)
        XCTAssertTrue(timer.isRunning)
    }

    func testCountdownDecreasesOverTime() async throws {
        let timer = InterrogationTimer()
        timer.start(seconds: 2)
        try await Task.sleep(for: .milliseconds(700))
        XCTAssertLessThan(timer.remainingSeconds, 2)
        XCTAssertGreaterThan(timer.remainingSeconds, 1)
        timer.stop()
    }

    func testPauseFreezesTime() async throws {
        let timer = InterrogationTimer()
        timer.start(seconds: 5)
        try await Task.sleep(for: .milliseconds(500))
        timer.pause()
        let frozen = timer.remainingSeconds
        try await Task.sleep(for: .milliseconds(500))
        XCTAssertEqual(timer.remainingSeconds, frozen, accuracy: 0.05)
        XCTAssertFalse(timer.isRunning)
    }

    func testResumeContinuesFromPaused() async throws {
        let timer = InterrogationTimer()
        timer.start(seconds: 3)
        try await Task.sleep(for: .milliseconds(300))
        timer.pause()
        let pausedAt = timer.remainingSeconds
        try await Task.sleep(for: .milliseconds(400))
        timer.resume()
        try await Task.sleep(for: .milliseconds(300))
        // Should be ~ pausedAt - 0.3
        XCTAssertLessThan(timer.remainingSeconds, pausedAt)
        XCTAssertGreaterThan(timer.remainingSeconds, pausedAt - 0.6)
        timer.stop()
    }

    func testStopResets() {
        let timer = InterrogationTimer()
        timer.start(seconds: 10)
        timer.stop()
        XCTAssertFalse(timer.isRunning)
    }
}
