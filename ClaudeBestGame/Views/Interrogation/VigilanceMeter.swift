import SwiftUI

struct VigilanceMeter: View {
    let value: Double  // 0.0 ... 1.0

    private var color: Color {
        if value >= 0.75 { return .red }
        if value >= 0.4  { return .orange }
        return .yellow
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "eye.fill")
                .font(.caption2)
                .foregroundStyle(color)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * max(0, min(1, value)))
                        .animation(.easeOut(duration: 0.4), value: value)
                }
            }
            .frame(height: 6)
            Text("\(Int(value * 100))%")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(color)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        VigilanceMeter(value: 0.1)
        VigilanceMeter(value: 0.5)
        VigilanceMeter(value: 0.9)
    }
    .padding()
    .background(Color.black)
}
