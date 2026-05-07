import SwiftUI

struct EvidenceCard: View {
    let title: String
    let detail: String
    let discoveredAtLoop: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundStyle(.red)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Spacer()
                Text("Loop \(discoveredAtLoop + 1)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(detail)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(12)
        .background(Color.red.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
