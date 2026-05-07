import Foundation

struct VigilanceUpdate: Equatable, Sendable {
    let newVigilance: Double
    let delta: Double
}

/// Pure logic for the suspect's vigilance meter.
/// Vigilance rises when the player picks risky/wrong choices,
/// and decays slightly on neutral choices (to reward steady investigation).
enum VigilanceEngine {

    /// Returns the new vigilance after taking a choice with the given category and outcome.
    /// - Parameters:
    ///   - currentVigilance: Current value (0.0 ... 1.0).
    ///   - category: The choice category played.
    ///   - severity: The contradiction severity reported by the suspect's reply.
    ///   - difficulty: Case difficulty 1...5 (higher = vigilance grows faster).
    static func update(
        currentVigilance: Double,
        category: ChoiceCategory,
        severity: ContradictionSeverity,
        difficulty: Int
    ) -> VigilanceUpdate {
        let clampedDifficulty = max(1, min(5, difficulty))
        let difficultyMul = 1.0 + Double(clampedDifficulty - 1) * 0.10  // d1=1.0, d5=1.4

        // Base delta from category × outcome combination
        let base: Double
        switch category {
        case .neutral:
            // Neutral choices keep the suspect calm. Tiny decay if no contradiction surfaced.
            base = severity == .none ? -0.02 : 0.0
        case .pressing:
            // Pressing: small vigilance gain, larger if it backfires
            base = severity == .none ? 0.10 : 0.04
        case .aggressive:
            // Aggressive: always raises vigilance, but less if it lands
            base = severity == .none ? 0.20 : 0.08
        case .evidence:
            // Evidence: huge backfire if wrong, very small gain if it lands
            base = severity == .none ? 0.30 : 0.02
        }

        let delta = base * difficultyMul
        let newValue = max(0.0, min(1.0, currentVigilance + delta))
        return VigilanceUpdate(newVigilance: newValue, delta: newValue - currentVigilance)
    }

    /// Vigilance meter at or above this value triggers automatic loss
    /// (suspect refuses to talk further).
    static let lossThreshold: Double = 1.0
}
