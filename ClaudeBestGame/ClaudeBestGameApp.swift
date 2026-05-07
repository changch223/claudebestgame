import SwiftUI
import SwiftData

@main
struct ClaudeBestGameApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CaseRecord.self,
            SuspectRecord.self,
            InterrogationTurn.self,
            PlaySession.self,
            Progress.self,
            EvidenceItem.self,
            InvestigationNotebook.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // 古いスキーマでは Migration が必要だが、開発中はデータを破棄して新しい Container を作る
            do {
                let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: [inMemoryConfig])
            } catch {
                fatalError("ModelContainer 生成に失敗: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
