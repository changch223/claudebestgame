import SwiftUI

struct QuestionChoicesView: View {
    let choices: [QuestionChoice]
    let isAwaitingReply: Bool
    let onSelect: (QuestionChoice) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(choices) { choice in
                ChoiceButton(
                    choice: choice,
                    isDisabled: isAwaitingReply,
                    onTap: { onSelect(choice) }
                )
            }
        }
        .padding(.horizontal, 12)
    }
}

private struct ChoiceButton: View {
    let choice: QuestionChoice
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: choice.category.icon)
                    .font(.body.bold())
                    .foregroundStyle(categoryColor)
                    .frame(width: 24, height: 24)
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 2) {
                    Text(choice.text)
                        .font(.body)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(choice.category.label)
                        .font(.caption2.bold())
                        .foregroundStyle(categoryColor)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(categoryColor.opacity(0.6), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1.0)
    }

    private var categoryColor: Color {
        switch choice.category {
        case .neutral:    return .gray
        case .pressing:   return .blue
        case .aggressive: return .orange
        case .evidence:   return .red
        }
    }
}
