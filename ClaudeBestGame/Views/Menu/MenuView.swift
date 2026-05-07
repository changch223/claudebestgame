import SwiftUI

struct MenuView: View {
    let rootVM: GameRootViewModel
    @State private var bossPulse: Bool = false

    var body: some View {
        let progress = rootVM.progress()
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 8) {
                Text("白い嘘")
                    .font(.system(size: 56, weight: .black))
                    .foregroundStyle(.white)
                Text("Loops of Truth")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .tracking(2)
            }

            VStack(spacing: 14) {
                Button {
                    rootVM.startNextStage(isBoss: false)
                } label: {
                    menuLabel(
                        title: nextStageTitle(progress),
                        subtitle: "6ターンで自白を引き出せ",
                        color: .blue
                    )
                }

                if let progress, progress.bossUnlocked {
                    Button {
                        rootVM.startNextStage(isBoss: true)
                    } label: {
                        menuLabel(
                            title: progress.bossCleared ? "黒幕戦（再戦）" : "黒幕戦",
                            subtitle: "8ターン・最高難度",
                            color: .red
                        )
                        .scaleEffect(bossPulse ? 1.02 : 1.0)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                            bossPulse.toggle()
                        }
                    }
                } else {
                    menuLabel(
                        title: "黒幕戦（ロック中）",
                        subtitle: "10事件クリアで解禁",
                        color: .gray.opacity(0.4)
                    )
                }
            }
            .padding(.horizontal)

            Spacer()

            if let progress {
                statsView(progress: progress)
                    .padding(.bottom, 24)
            }
        }
        .background(Color.black)
    }

    private func nextStageTitle(_ progress: Progress?) -> String {
        guard let progress else { return "事件 1" }
        if progress.currentStage > 10 { return "事件 10（クリア済み）" }
        return "事件 \(progress.currentStage)"
    }

    private func statsView(progress: Progress) -> some View {
        VStack(spacing: 4) {
            Text("クリア: \(progress.totalCleared) / 10  ・  パーフェクト: \(progress.perfectClears)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("累計ループ: \(progress.totalLoops)  ・  ハイスコア: \(progress.highScoreOverall)")
                .font(.caption)
                .foregroundStyle(.yellow)
        }
    }

    private func menuLabel(title: String, subtitle: String, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 16).padding(.vertical, 16)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
