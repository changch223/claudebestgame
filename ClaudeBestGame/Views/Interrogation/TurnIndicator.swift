import SwiftUI

struct TurnIndicator: View {
    let current: Int       // 0-indexed turn already used
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(fill(for: i))
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle().stroke(.white.opacity(0.3), lineWidth: 0.5)
                    )
            }
            Spacer()
            Text("\(min(current, total)) / \(total)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private func fill(for index: Int) -> Color {
        if index < current {
            return .red.opacity(0.6)
        } else if index == current {
            return .white
        } else {
            return .white.opacity(0.15)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        TurnIndicator(current: 0, total: 6)
        TurnIndicator(current: 3, total: 6)
        TurnIndicator(current: 6, total: 6)
    }
    .padding()
    .background(Color.black)
}
