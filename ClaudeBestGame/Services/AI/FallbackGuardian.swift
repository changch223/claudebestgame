import Foundation

/// Deterministic suspect responder used when Apple Foundation Models is
/// unavailable. Responds based on the chosen question category and the
/// presence of contradiction-trigger keywords / evidence terms in the question.
struct FallbackGuardian: Sendable {
    let fallbackCase: FallbackCase

    /// Generate a suspect reply for a chosen player question.
    func reply(to question: String, category: ChoiceCategory) -> String {
        let triggered = fallbackCase.contradictionKeywords.contains { question.contains($0) }
        switch category {
        case .neutral:
            return neutralReply(triggered: triggered)
        case .pressing:
            return pressingReply(triggered: triggered)
        case .aggressive:
            return aggressiveReply(triggered: triggered)
        case .evidence:
            return evidenceReply(question: question, triggered: triggered)
        }
    }

    // MARK: -

    private func neutralReply(triggered: Bool) -> String {
        let persona = fallbackCase.persona
        switch persona {
        case "stoic":        return triggered ? "...お答えしかねます" : "...特にありません"
        case "anxious":      return triggered ? "え、あの、その..." : "特に変わったことは..."
        case "aggressive":   return triggered ? "なんでそんなこと聞く！" : "普通だったよ"
        case "pitiful":      return triggered ? "なぜ私が責められるのか..." : "ただの日常です..."
        case "intellectual": return triggered ? "その質問の意図は？" : "標準的な範囲です"
        default:             return "...特にありません"
        }
    }

    private func pressingReply(triggered: Bool) -> String {
        if triggered {
            switch fallbackCase.persona {
            case "stoic":        return "...そのことはお話しできません"
            case "anxious":      return "そ、それは...違うんです..."
            case "aggressive":   return "言いがかりはやめろ！"
            case "pitiful":      return "誤解です...本当に..."
            case "intellectual": return "ご質問には論理的根拠がありません"
            default:             return "覚えていません"
            }
        } else {
            return "それは記録されているはずです"
        }
    }

    private func aggressiveReply(triggered: Bool) -> String {
        if triggered {
            switch fallbackCase.persona {
            case "stoic":        return "...弁護士を呼んでください"
            case "anxious":      return "ち、違います...違うんです..."
            case "aggressive":   return "うるさい！黙れ！"
            case "pitiful":      return "そんな言い方しないでください...涙が..."
            case "intellectual": return "感情的な詰問は不当です"
            default:             return "...答えられません"
            }
        } else {
            switch fallbackCase.persona {
            case "aggressive":   return "ふざけるな！"
            default:             return "...心外です"
            }
        }
    }

    private func evidenceReply(question: String, triggered: Bool) -> String {
        // 証拠提示は鋭い。容疑者は強く動揺するか、苦しい言い訳をする。
        if triggered {
            switch fallbackCase.persona {
            case "stoic":        return "...それは...説明がつきません..."
            case "anxious":      return "そんな...どうして...どうして！"
            case "aggressive":   return "黙れ！黙れ！認めない！"
            case "pitiful":      return "...もう、もう許して..."
            case "intellectual": return "...理論的には...反論ができません..."
            default:             return "...言葉が出ません..."
            }
        } else {
            return "そんな証拠は聞いていません"
        }
    }
}
