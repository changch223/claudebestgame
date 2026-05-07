import Foundation

enum ContradictionSeverity: String, Codable, CaseIterable, Sendable {
    case none
    case small
    case medium
    case large

    /// Base gauge increase before any modifiers
    var baseDelta: Double {
        switch self {
        case .none:   return 0.00
        case .small:  return 0.06
        case .medium: return 0.16
        case .large:  return 0.32
        }
    }
}

struct GaugeUpdate: Equatable, Sendable {
    let newGauge: Double
    let delta: Double
}

/// Pure logic. Combines severity, category multiplier, difficulty, and vigilance.
enum ConfessionGaugeEngine {

    /// d=1 → 1.0, d=5 → 0.6
    static func difficultyMultiplier(_ difficulty: Int) -> Double {
        let clamped = max(1, min(5, difficulty))
        return 1.0 - Double(clamped - 1) * 0.10
    }

    /// Choice category modifies how strongly a contradiction translates into gauge gain.
    /// - Neutral: only modest gains even when right.
    /// - Pressing: standard.
    /// - Aggressive: amplified gains, but heavy vigilance penalty (handled separately).
    /// - Evidence: massive amplifier when correct.
    static func categoryMultiplier(_ category: ChoiceCategory) -> Double {
        switch category {
        case .neutral:    return 0.6
        case .pressing:   return 1.0
        case .aggressive: return 1.2
        case .evidence:   return 1.8
        }
    }

    /// Vigilance penalty: high vigilance suspects are harder to crack.
    /// vig=0.0 → 1.0, vig=1.0 → 0.4
    static func vigilancePenalty(_ vigilance: Double) -> Double {
        let v = max(0, min(1, vigilance))
        return 1.0 - v * 0.6
    }

    static func update(
        currentGauge: Double,
        severity: ContradictionSeverity,
        category: ChoiceCategory,
        difficulty: Int,
        vigilance: Double
    ) -> GaugeUpdate {
        let delta = severity.baseDelta
            * difficultyMultiplier(difficulty)
            * categoryMultiplier(category)
            * vigilancePenalty(vigilance)
        let newGauge = min(1.0, max(0.0, currentGauge + delta))
        return GaugeUpdate(newGauge: newGauge, delta: delta)
    }

    /// Backwards-compatible signature used by older tests / call sites.
    static func update(
        currentGauge: Double,
        severity: ContradictionSeverity,
        difficulty: Int
    ) -> GaugeUpdate {
        update(
            currentGauge: currentGauge,
            severity: severity,
            category: .pressing,   // legacy default
            difficulty: difficulty,
            vigilance: 0.0
        )
    }
}
