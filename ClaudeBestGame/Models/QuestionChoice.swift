import Foundation

enum ChoiceCategory: String, Codable, Sendable, CaseIterable {
    /// 中立的な情報収集。安全だがゲージはほぼ動かない。警戒度上昇なし。
    case neutral
    /// 鋭く突く質問。当たれば中ゲイン、外せば警戒度+。
    case pressing
    /// 攻撃的・煽る質問。当たれば大ゲイン、外せば警戒度++。
    case aggressive
    /// 証拠提示。所持証拠が必要。当たれば極大ゲイン、ハズレなら警戒度+++。
    case evidence

    var icon: String {
        switch self {
        case .neutral:    return "bubble.left"
        case .pressing:   return "magnifyingglass"
        case .aggressive: return "flame"
        case .evidence:   return "doc.text.magnifyingglass"
        }
    }

    var color: String {
        switch self {
        case .neutral:    return "gray"
        case .pressing:   return "blue"
        case .aggressive: return "orange"
        case .evidence:   return "red"
        }
    }

    var label: String {
        switch self {
        case .neutral:    return "中立"
        case .pressing:   return "追求"
        case .aggressive: return "強気"
        case .evidence:   return "証拠"
        }
    }
}

/// A single choice presented to the player on a turn.
/// Not persisted standalone; serialized into InterrogationTurn.chosenChoiceText
/// and reconstructed for analytics.
struct QuestionChoice: Identifiable, Equatable, Hashable, Sendable {
    let id: UUID
    let text: String
    let category: ChoiceCategory
    /// If non-nil, presenting this choice references a specific evidence item.
    let evidenceId: UUID?
    /// If true, this choice triggers a contradiction-strong effect when played correctly.
    let isCorrectPath: Bool

    init(
        id: UUID = UUID(),
        text: String,
        category: ChoiceCategory,
        evidenceId: UUID? = nil,
        isCorrectPath: Bool = false
    ) {
        self.id = id
        self.text = text
        self.category = category
        self.evidenceId = evidenceId
        self.isCorrectPath = isCorrectPath
    }
}
