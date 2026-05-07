import SwiftUI
import SwiftData

enum GameScreen: Equatable {
    case menu
    case interrogation
    case victory
    case defeat
    case ending
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var rootVM = GameRootViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            content
                .preferredColorScheme(.dark)
                .animation(.easeInOut(duration: 0.3), value: rootVM.screen)
        }
        .task {
            rootVM.bind(repository: ProgressRepository(context: modelContext))
        }
        .fullScreenCover(isPresented: Binding(
            get: { rootVM.showingTutorial },
            set: { newValue in
                if !newValue { rootVM.dismissTutorial() }
            }
        )) {
            TutorialView(onClose: { rootVM.dismissTutorial() })
        }
    }

    @ViewBuilder
    private var content: some View {
        switch rootVM.screen {
        case .menu:
            MenuView(rootVM: rootVM)
                .transition(.opacity)
        case .interrogation:
            if let interrogationVM = rootVM.interrogationVM {
                InterrogationView(viewModel: interrogationVM, rootVM: rootVM)
                    .transition(.opacity)
            }
        case .victory:
            if let interrogationVM = rootVM.interrogationVM {
                VictoryView(viewModel: interrogationVM, rootVM: rootVM)
                    .transition(.opacity)
            }
        case .defeat:
            if let interrogationVM = rootVM.interrogationVM {
                DefeatView(viewModel: interrogationVM, rootVM: rootVM)
                    .transition(.opacity)
            }
        case .ending:
            EndingView(rootVM: rootVM)
                .transition(.opacity)
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [
            CaseRecord.self, SuspectRecord.self, InterrogationTurn.self,
            PlaySession.self, Progress.self, EvidenceItem.self, InvestigationNotebook.self
        ], inMemory: true)
}
