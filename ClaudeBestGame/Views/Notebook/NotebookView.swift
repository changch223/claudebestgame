import SwiftUI

struct NotebookView: View {
    let viewModel: NotebookViewModel
    var onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    if viewModel.evidence.isEmpty {
                        emptyEvidence
                    } else {
                        evidenceSection
                    }

                    if !viewModel.summaryLines.isEmpty {
                        notebookSection
                    }

                    if !viewModel.flaggedQuotes.isEmpty {
                        flaggedSection
                    }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("捜査メモ")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Text(viewModel.caseTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    private var emptyEvidence: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("証拠なし", systemImage: "doc.text.magnifyingglass")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            Text("尋問中に矛盾点を見つけると、ここに証拠が記録されます。\n次のループで「証拠提示」選択肢として使えます。")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("証拠 (\(viewModel.evidence.count))", systemImage: "doc.text.magnifyingglass")
                .font(.headline)
                .foregroundStyle(.red)
            ForEach(viewModel.evidence) { item in
                EvidenceCard(
                    title: item.title,
                    detail: item.detail,
                    discoveredAtLoop: item.discoveredAtLoop
                )
            }
        }
    }

    private var notebookSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("メモ", systemImage: "note.text")
                .font(.headline)
                .foregroundStyle(.yellow)
            ForEach(Array(viewModel.summaryLines.enumerated()), id: \.offset) { _, line in
                HStack(alignment: .top, spacing: 6) {
                    Text("•").foregroundStyle(.yellow)
                    Text(line).foregroundStyle(.white.opacity(0.9))
                }
                .font(.callout)
            }
        }
    }

    private var flaggedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("怪しい発言", systemImage: "quote.opening")
                .font(.headline)
                .foregroundStyle(.orange)
            ForEach(Array(viewModel.flaggedQuotes.enumerated()), id: \.offset) { _, quote in
                Text("「\(quote)」")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
}
