import SwiftUI

struct EndingView: View {
    let rootVM: GameRootViewModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)
            Text("真エンディング")
                .font(.title.bold())
                .foregroundStyle(.white)
            Text("あなたは何度も嘘を見破った。\nしかし、自分自身についた嘘は\n見破れただろうか。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal)
            Spacer()
            Button {
                rootVM.returnToMenu()
            } label: {
                Text("はじめに戻る")
                    .font(.headline)
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .background(Color.yellow)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 24)
        .background(Color.black)
    }
}
