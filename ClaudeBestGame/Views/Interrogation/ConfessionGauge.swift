import SwiftUI

struct ConfessionGauge: View {
    let value: Double            // 0.0 ... 1.0
    let lastSeverity: ContradictionSeverity
    @State private var flash: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("自白ゲージ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundStyle(value >= 1.0 ? .red : .white)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1))
                    Capsule()
                        .fill(LinearGradient(
                            colors: [.red.opacity(0.7), .red, .pink],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * max(0, min(1, value)))
                        .animation(.easeOut(duration: 0.4), value: value)
                }
            }
            .frame(height: 14)
            .overlay(
                Capsule()
                    .stroke(Color.red, lineWidth: flash ? 3 : 0)
                    .opacity(flash ? 1 : 0)
            )
        }
        .onChange(of: lastSeverity) { _, new in
            guard new != .none else { return }
            withAnimation(.easeOut(duration: 0.15)) { flash = true }
            Task {
                try? await Task.sleep(for: .milliseconds(220))
                withAnimation(.easeOut(duration: 0.4)) { flash = false }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ConfessionGauge(value: 0.0, lastSeverity: .none)
        ConfessionGauge(value: 0.45, lastSeverity: .medium)
        ConfessionGauge(value: 0.95, lastSeverity: .large)
    }
    .padding()
    .background(Color.black)
}
