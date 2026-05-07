import SwiftUI

struct VictoryView: View {
    let viewModel: InterrogationViewModel
    let rootVM: GameRootViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                Text("自白を引き出した")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                if viewModel.loopIndex == 0 {
                    Text("✨ パーフェクト ✨")
                        .font(.headline)
                        .foregroundStyle(.yellow)
                } else {
                    Text("ループ \(viewModel.loopIndex + 1) でクリア")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let c = viewModel.fallbackCase {
                VStack(alignment: .leading, spacing: 8) {
                    Label("\(c.suspectName) の真実", systemImage: "person.fill.checkmark")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(c.trueMotive)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding()
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
            }

            VStack(spacing: 4) {
                Text("スコア")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.score)")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundStyle(.yellow)
                Text("残ターン \(viewModel.remainingTurns) / ループ \(viewModel.loopIndex + 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Button {
                rootVM.returnToMenu()
            } label: {
                Text("メニューへ")
                    .font(.headline)
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 24)
        .background(Color.black)
    }
}
