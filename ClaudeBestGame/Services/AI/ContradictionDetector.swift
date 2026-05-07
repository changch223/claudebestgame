import Foundation

struct DetectedContradiction: Sendable {
    let severity: ContradictionSeverity
    let reason: String
}

/// Fallback (deterministic) contradiction detector.
/// Phase 5 will introduce an AI-backed version that runs alongside this.
enum ContradictionDetector {

    /// Detect contradictions for the new choice-based gameplay.
    /// - Parameters:
    ///   - playerQuestion: text of the chosen question
    ///   - suspectReply:   text of the suspect's reply
    ///   - category:       category of the chosen question
    ///   - contradictionKeywords: keyword list from the case JSON
    ///   - priorTurns:     prior question/reply pairs (currently unused but reserved)
    static func detect(
        playerQuestion: String,
        suspectReply: String,
        category: ChoiceCategory,
        contradictionKeywords: [String],
        priorTurns: [(question: String, reply: String)]
    ) -> DetectedContradiction {
        let combined = playerQuestion + " " + suspectReply

        // Count unique keyword hits.
        var seen: Set<String> = []
        for keyword in contradictionKeywords where combined.contains(keyword) {
            seen.insert(keyword)
        }
        let hits = seen.count

        // Evasion markers in the reply itself.
        let evasionMarkers = ["...", "覚えていません", "知りません", "答えかねます", "違うんです"]
        let evasionHits = evasionMarkers.filter { suspectReply.contains($0) }.count
        let evasionBonus = evasionHits >= 2 ? 1 : 0

        // Category-driven sensitivity.
        // - evidence choices treat any hit as immediately strong (because the player named a fact)
        // - aggressive choices upgrade severity by one level when hits happen
        // - neutral choices downgrade by one level
        var raw = hits + evasionBonus
        switch category {
        case .evidence:
            if hits > 0 { raw = max(raw, 3) }
        case .aggressive:
            if hits > 0 { raw += 1 }
        case .pressing:
            break
        case .neutral:
            raw = max(0, raw - 1)
        }

        let severity: ContradictionSeverity
        let reason: String
        switch raw {
        case 0:
            severity = .none
            reason = "矛盾は見られない"
        case 1:
            severity = .small
            reason = "些細な不一致または曖昧な返答"
        case 2:
            severity = .medium
            reason = "明確な矛盾の兆候"
        default:
            severity = .large
            reason = "致命的な矛盾"
        }
        return DetectedContradiction(severity: severity, reason: reason)
    }

    /// Backwards-compatible legacy entry point used by older tests
    /// and by any path that hasn't migrated to category-aware detection.
    static func detect(
        playerQuestion: String,
        suspectReply: String,
        contradictionKeywords: [String],
        priorTurns: [(question: String, reply: String)]
    ) -> DetectedContradiction {
        detect(
            playerQuestion: playerQuestion,
            suspectReply: suspectReply,
            category: .pressing,
            contradictionKeywords: contradictionKeywords,
            priorTurns: priorTurns
        )
    }
}
