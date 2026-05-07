import SwiftUI

struct TutorialView: View {
    let onClose: () -> Void
    @State private var pageIndex = 0

    private let pages: [TutorialPage] = [
        TutorialPage(
            icon: "person.fill.questionmark",
            iconColor: .blue,
            title: "あなたは検事",
            body: "嘘つきの容疑者から **6ターン以内** に自白を引き出してください。\n\n各ターン、3〜4 個の選択肢から質問を 1 つ選びます。"
        ),
        TutorialPage(
            icon: "rectangle.3.group.fill",
            iconColor: .orange,
            title: "選択肢には種類がある",
            body: """
            🔘 **中立** … 安全だが効果小
            🔍 **追求** … 標準的な質問
            🔥 **強気** … ハイリスク・ハイリターン
            📄 **証拠** … 大ヒット（要証拠アイテム）
            """
        ),
        TutorialPage(
            icon: "arrow.triangle.2.circlepath",
            iconColor: .purple,
            title: "1 ループ目では勝てなくてOK",
            body: """
            **重要**：1 ループ目は **証拠を集めるフェーズ** です。

            容疑者のアリバイの弱点に関連する質問を選ぶと、自動的に「証拠」が **捜査メモ** に蓄積されます。

            このフェーズは負けても次に持ち越せます。
            """
        ),
        TutorialPage(
            icon: "doc.text.magnifyingglass",
            iconColor: .red,
            title: "2 ループ目で証拠提示",
            body: """
            失敗後「同じ事件に再挑戦」を選ぶと、集めた証拠が引き継がれます。

            すると選択肢に **「証拠を提示：◯◯◯」**（赤）が現れる！

            これを選ぶと自白ゲージが **+50% 以上** 一気に上がります。2〜3 個提示すれば勝利。
            """
        ),
        TutorialPage(
            icon: "eye.fill",
            iconColor: .yellow,
            title: "警戒度に注意",
            body: """
            **強気**な質問を外したり、的外れな**証拠**を出すと、容疑者の **警戒度メーター**（黄色）が上昇します。

            **100% に到達すると即敗北**するので、序盤は控えめに行きましょう。
            """
        ),
        TutorialPage(
            icon: "trophy.fill",
            iconColor: .green,
            title: "ループが少ないほど高スコア",
            body: """
            1 ループでクリア = **パーフェクト** （最高スコア）
            ループするほど -300 点ずつペナルティ。

            10 事件をクリアすると **黒幕戦（8ターン）** が解禁。

            さあ、検事として真実を引き出せ！
            """
        )
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // page content
                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
                        TutorialPageView(page: page).tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // page indicator + buttons
                VStack(spacing: 16) {
                    HStack(spacing: 6) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == pageIndex ? Color.white : Color.white.opacity(0.25))
                                .frame(width: i == pageIndex ? 22 : 6, height: 6)
                                .animation(.easeInOut(duration: 0.2), value: pageIndex)
                        }
                    }

                    HStack {
                        Button("スキップ") {
                            onClose()
                        }
                        .foregroundStyle(.white.opacity(0.6))
                        Spacer()
                        Button {
                            if pageIndex < pages.count - 1 {
                                withAnimation { pageIndex += 1 }
                            } else {
                                onClose()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(pageIndex == pages.count - 1 ? "始める" : "次へ")
                                    .font(.headline)
                                Image(systemName: pageIndex == pages.count - 1 ? "play.fill" : "chevron.right")
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(pageIndex == pages.count - 1 ? Color.green : Color.blue)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct TutorialPage {
    let icon: String
    let iconColor: Color
    let title: String
    let body: String
}

private struct TutorialPageView: View {
    let page: TutorialPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 78))
                .foregroundStyle(page.iconColor)
            Text(page.title)
                .font(.title.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(.init(page.body))
                .font(.body)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
            Spacer()
            Spacer()
        }
    }
}
