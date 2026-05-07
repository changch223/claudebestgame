import SwiftUI

struct DialogueLog: View {
    let messages: [DialogueMessage]
    let isAwaitingReply: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messages) { message in
                        MessageBubble(message: message).id(message.id)
                    }
                    if isAwaitingReply {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .onChange(of: messages.count) { _, _ in
                if let last = messages.last {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: isAwaitingReply) { _, awaiting in
                if awaiting {
                    withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                }
            }
        }
    }
}

private struct MessageBubble: View {
    let message: DialogueMessage

    var body: some View {
        HStack(alignment: .top) {
            if message.speaker == .player { Spacer(minLength: 32) }
            VStack(alignment: message.speaker == .player ? .trailing : .leading, spacing: 4) {
                speakerLine
                Text(message.text)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(bubbleBackground)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                if let severity = message.severity, severity != .none {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                        Text("矛盾検知 +\(Int(message.gaugeDelta * 100))%")
                    }
                    .font(.caption2.bold())
                    .foregroundStyle(.red)
                }
            }
            if message.speaker == .suspect { Spacer(minLength: 32) }
        }
    }

    @ViewBuilder
    private var speakerLine: some View {
        if message.speaker == .player, let cat = message.category {
            HStack(spacing: 4) {
                Image(systemName: cat.icon)
                Text("検事 ・ \(cat.label)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        } else {
            Text(message.speaker == .player ? "検事" : "容疑者")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var bubbleBackground: Color {
        if message.speaker == .player {
            switch message.category {
            case .neutral?:    return .gray.opacity(0.7)
            case .pressing?:   return .blue.opacity(0.85)
            case .aggressive?: return .orange.opacity(0.85)
            case .evidence?:   return .red.opacity(0.85)
            case .none:        return .blue.opacity(0.85)
            }
        } else {
            return .white.opacity(0.12)
        }
    }
}

private struct TypingIndicator: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(.white.opacity(phase == i ? 0.9 : 0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            Spacer()
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(300))
                phase = (phase + 1) % 3
            }
        }
    }
}
