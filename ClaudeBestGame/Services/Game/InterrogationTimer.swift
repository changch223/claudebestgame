import Foundation

@MainActor
@Observable
final class InterrogationTimer {
    private(set) var remainingSeconds: Double = 60.0
    private(set) var totalSeconds: Double = 60.0
    private(set) var isRunning: Bool = false

    private var startedAt: Date?
    private var pausedRemainder: Double?
    private var task: Task<Void, Never>?

    /// Start the countdown from the given duration.
    func start(seconds: Double) {
        stop()
        totalSeconds = seconds
        remainingSeconds = seconds
        startedAt = Date()
        isRunning = true
        run()
    }

    /// Pause the timer; preserves remaining time so resume continues from there.
    func pause() {
        guard isRunning, let start = startedAt else { return }
        let elapsed = Date().timeIntervalSince(start)
        pausedRemainder = max(0, totalSeconds - elapsed)
        remainingSeconds = pausedRemainder ?? 0
        isRunning = false
        task?.cancel()
        task = nil
        startedAt = nil
    }

    /// Resume from paused state.
    func resume() {
        guard !isRunning, let remainder = pausedRemainder else { return }
        totalSeconds = remainder
        startedAt = Date()
        isRunning = true
        pausedRemainder = nil
        run()
    }

    /// Stop and reset.
    func stop() {
        task?.cancel()
        task = nil
        isRunning = false
        startedAt = nil
        pausedRemainder = nil
    }

    private func run() {
        task = Task { @MainActor [weak self] in
            while let self, self.isRunning, let start = self.startedAt {
                let elapsed = Date().timeIntervalSince(start)
                self.remainingSeconds = max(0, self.totalSeconds - elapsed)
                if self.remainingSeconds <= 0 {
                    self.isRunning = false
                    break
                }
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }

    /// Has the timer expired?
    var isExpired: Bool { remainingSeconds <= 0 }
}
