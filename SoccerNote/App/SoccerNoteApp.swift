import SwiftUI

@main
struct SoccerNoteApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // アプリ起動時にUIの外観を設定
        AppTabBarAppearance.setupAppearance()
        AppNavigationBarAppearance.setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
