import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("ホーム", systemImage: AppIcons.Tab.home)
                }
            
            RecordListView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("記録", systemImage: AppIcons.Tab.records)
                }
            
            AddRecordView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("追加", systemImage: AppIcons.Tab.add)
                }
            
            StatsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("統計", systemImage: AppIcons.Tab.stats)
                }
            
            GoalsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("目標", systemImage: AppIcons.Tab.goals)
                }
        }
        .accentColor(AppDesign.primaryColor)
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
