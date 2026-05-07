import Foundation

/// Generates the 3-4 question choices presented to the player on each turn.
/// Currently fallback (deterministic) implementation; an AI-backed variant
/// using Apple Foundation Models can sit alongside this service later.
struct ChoiceGeneratorContext: Sendable {
    let turnIndex: Int           // 0..(maxTurns-1)
    let maxTurns: Int
    let vigilance: Double
    let confessionGauge: Double
    let evidenceItems: [(id: UUID, title: String, detail: String)]
    /// History of player+suspect text within the current loop (for repetition avoidance).
    let priorPlayerTexts: [String]
}

enum ChoiceGeneratorService {

    /// Generates 4 choices for the next turn based on the case and context.
    static func generate(
        for fallbackCase: FallbackCase,
        context: ChoiceGeneratorContext
    ) -> [QuestionChoice] {
        var generated: [QuestionChoice] = []

        // Base pool selection: opening for turn 0, pressing for mid game,
        // aggressive choices appear more frequently late game.
        let pool = fallbackCase.choicePool
        let primary: [FallbackChoice]
        let secondary: [FallbackChoice]
        switch context.turnIndex {
        case 0:
            primary = pool.opening
            secondary = pool.pressing
        case 1, 2:
            primary = pool.pressing
            secondary = pool.opening + pool.aggressive
        default:
            primary = pool.pressing + pool.aggressive
            secondary = pool.aggressive   // late game: drop opening entirely
        }

        // 1-2 primary choices (avoid repeats from prior turns)
        let primaryShuffled = primary.shuffled()
        for c in primaryShuffled {
            if generated.count >= 2 { break }
            if context.priorPlayerTexts.contains(c.text) { continue }
            generated.append(QuestionChoice(text: c.text, category: c.resolvedCategory))
        }

        // 1 secondary choice
        for c in secondary.shuffled() {
            if generated.count >= 3 { break }
            if context.priorPlayerTexts.contains(c.text) { continue }
            if generated.contains(where: { $0.text == c.text }) { continue }
            generated.append(QuestionChoice(text: c.text, category: c.resolvedCategory))
        }

        // 1 evidence-presenting choice if any evidence is owned and we have at least 1 turn left
        if let evidence = context.evidenceItems.first(where: { ev in
            !context.priorPlayerTexts.contains { $0.contains(ev.title) }
        }) {
            generated.append(QuestionChoice(
                text: "証拠を提示：\(evidence.title)",
                category: .evidence,
                evidenceId: evidence.id,
                isCorrectPath: true
            ))
        } else {
            // Fill with another aggressive choice if no evidence available
            for c in pool.aggressive.shuffled() {
                if generated.contains(where: { $0.text == c.text }) { continue }
                if context.priorPlayerTexts.contains(c.text) { continue }
                generated.append(QuestionChoice(text: c.text, category: c.resolvedCategory))
                break
            }
        }

        // Defensive fallback if everything was filtered out
        if generated.isEmpty {
            generated.append(QuestionChoice(text: "もう一度説明してください", category: .neutral))
        }
        // Cap at 4
        return Array(generated.prefix(4))
    }
}
