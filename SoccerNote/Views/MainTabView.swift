// SoccerNote/Views/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(0)
            
            RecordListView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("記録", systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            AddRecordView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("追加", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            StatsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            GoalsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("目標", systemImage: "flag.fill")
                }
                .tag(4)
        }
        .accentColor(AppDesign.primaryColor)
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
