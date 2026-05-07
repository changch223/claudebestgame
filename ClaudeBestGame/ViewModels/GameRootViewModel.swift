import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class GameRootViewModel {
    var screen: GameScreen = .menu
    var showingTutorial: Bool = false
    private(set) var interrogationVM: InterrogationViewModel?
    private(set) var repository: ProgressRepository?

    private let tutorialKey = "claudebestgame.tutorial.seen.v2"

    func bind(repository: ProgressRepository) {
        self.repository = repository
        // Show tutorial on first launch
        if !UserDefaults.standard.bool(forKey: tutorialKey) {
            showingTutorial = true
        }
    }

    func progress() -> Progress? {
        repository?.load()
    }

    func showTutorial() { showingTutorial = true }
    func dismissTutorial() {
        UserDefaults.standard.set(true, forKey: tutorialKey)
        showingTutorial = false
    }

    /// Begin a fresh attempt for the next stage in the campaign.
    func startNextStage(isBoss: Bool = false) {
        guard let repository else { return }
        let stage = isBoss ? 11 : (progress()?.currentStage ?? 1)
        let vm = InterrogationViewModel(
            repository: repository,
            stageNumber: stage,
            isBossBattle: isBoss
        )
        interrogationVM = vm
        vm.begin(loopIndex: 0)
        screen = .interrogation
    }

    /// Restart the SAME case after a defeat (loop index increases).
    /// Notebook and evidence persist via SwiftData.
    func retrySameCase() {
        guard let repository,
              let prev = interrogationVM,
              let prevCase = prev.fallbackCase else { return }
        let nextLoop = prev.loopIndex + 1
        let vm = InterrogationViewModel(
            repository: repository,
            stageNumber: prevCase.stageNumber,
            isBossBattle: prev.maxTurns == 8
        )
        interrogationVM = vm
        vm.begin(loopIndex: nextLoop)
        screen = .interrogation
    }

    func showVictory() { screen = .victory }
    func showDefeat() { screen = .defeat }
    func showEnding() { screen = .ending }
    func returnToMenu() {
        interrogationVM = nil
        screen = .menu
    }
}
