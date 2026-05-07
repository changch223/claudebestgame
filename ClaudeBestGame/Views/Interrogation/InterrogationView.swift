import SwiftUI

struct InterrogationView: View {
    let viewModel: InterrogationViewModel
    let rootVM: GameRootViewModel

    @State private var showingNotebook = false
    @State private var showingEvidenceFlash = false
    @State private var flashTitle: String = ""

    var body: some View {
        VStack(spacing: 12) {
            header
            if let c = viewModel.fallbackCase {
                SuspectAvatar(
                    name: c.suspectName,
                    job: c.suspectJob,
                    age: c.suspectAge,
                    persona: c.persona
                )
                .padding(.horizontal, 12)
                if viewModel.turnIndex == 0 && viewModel.loopIndex == 0 {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                        Text("アリバイの中の不自然な点を質問で突け")
                            .font(.caption2.bold())
                            .foregroundStyle(.yellow)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(Color.yellow.opacity(0.1))
                    .clipShape(Capsule())
                    .padding(.horizontal, 12)
                }
            }
            DialogueLog(
                messages: viewModel.messages,
                isAwaitingReply: viewModel.isAwaitingReply
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 6) {
                ConfessionGauge(
                    value: viewModel.gauge,
                    lastSeverity: viewModel.lastSeverity
                )
                VigilanceMeter(value: viewModel.vigilance)
            }
            .padding(.horizontal, 12)

            QuestionChoicesView(
                choices: viewModel.currentChoices,
                isAwaitingReply: viewModel.isAwaitingReply,
                onSelect: { choice in
                    Task { await viewModel.play(choice: choice) }
                }
            )
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.black)
        .overlay(alignment: .top) {
            if showingEvidenceFlash {
                evidenceFlash
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onChange(of: viewModel.endedAt) { _, endedAt in
            guard endedAt != nil else { return }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(400))
                if viewModel.didWin { rootVM.showVictory() } else { rootVM.showDefeat() }
            }
        }
        .onChange(of: viewModel.newlyDiscoveredEvidence.count) { _, count in
            guard count > 0,
                  let first = viewModel.newlyDiscoveredEvidence.first else { return }
            flashTitle = first.title
            withAnimation(.easeOut(duration: 0.2)) { showingEvidenceFlash = true }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(2000))
                withAnimation(.easeIn(duration: 0.4)) { showingEvidenceFlash = false }
            }
        }
        .sheet(isPresented: $showingNotebook) {
            NotebookView(
                viewModel: NotebookViewModel(
                    notebook: viewModel.notebook,
                    evidence: viewModel.ownedEvidence,
                    caseTitle: viewModel.fallbackCase.map { "\($0.suspectName) — \($0.caseType)" } ?? "事件"
                ),
                onClose: { showingNotebook = false }
            )
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                if let c = viewModel.fallbackCase {
                    Text("事件 \(c.stageNumber) ・ 難易度 \(c.difficulty)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if viewModel.loopIndex > 0 {
                    Text("ループ \(viewModel.loopIndex + 1)")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(Color.purple.opacity(0.4))
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
                }
                Button {
                    showingNotebook = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "book.closed.fill")
                        Text("\(viewModel.ownedEvidence.count)")
                            .font(.caption2.bold())
                    }
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
                }
            }
            TurnIndicator(current: viewModel.turnIndex, total: viewModel.maxTurns)
        }
        .padding(.horizontal, 12)
    }

    private var evidenceFlash: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.text.magnifyingglass")
                .foregroundStyle(.white)
            Text("証拠発見: \(flashTitle)")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Color.red.opacity(0.85))
        .clipShape(Capsule())
        .shadow(color: .red.opacity(0.5), radius: 8)
    }
}
