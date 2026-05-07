import SwiftUI

struct DefeatView: View {
    let viewModel: InterrogationViewModel
    let rootVM: GameRootViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            VStack(spacing: 10) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 70))
                    .foregroundStyle(.purple)
                Text(failureTitle)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Text("真相にあと一歩——再挑戦すれば\n見えなかった矛盾が見えてくる")
                    .multilineTextAlignment(.center)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.85))
            }

            if !viewModel.ownedEvidence.isEmpty {
                evidencePreview
            }

            VStack(spacing: 4) {
                Text("最終ゲージ").font(.caption).foregroundStyle(.secondary)
                Text("\(Int(viewModel.resultGauge * 100))%")
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundStyle(.orange)
            }

            Spacer()

            VStack(spacing: 10) {
                Button {
                    rootVM.retrySameCase()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("同じ事件に再挑戦（証拠は保持）")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                Button {
                    rootVM.returnToMenu()
                } label: {
                    Text("メニューへ")
                        .font(.callout)
                        .frame(maxWidth: .infinity).frame(height: 44)
                        .background(Color.gray.opacity(0.4))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 24)
        .background(Color.black)
    }

    private var failureTitle: String {
        if viewModel.vigilance >= VigilanceEngine.lossThreshold {
            return "容疑者が黙秘した"
        }
        return "ターン切れ"
    }

    private var evidencePreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("発見済みの証拠 \(viewModel.ownedEvidence.count) 件", systemImage: "doc.text.magnifyingglass")
                .font(.subheadline.bold())
                .foregroundStyle(.red)
            ForEach(viewModel.ownedEvidence.prefix(3)) { item in
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                    Text(item.title)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                    Spacer()
                }
            }
            if viewModel.ownedEvidence.count > 3 {
                Text("...他 \(viewModel.ownedEvidence.count - 3) 件")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text("次のループで「証拠提示」選択肢として使用できます。")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.top, 4)
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}
