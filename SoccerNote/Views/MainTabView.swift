// MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1. ホームタブ
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(0)
            
            // 2. 記録追加タブ
            SimpleRecordAddView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("記録", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            // 3. 分析タブ（統計と目標を統合）
            AnalysisView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("分析", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            // 4. 設定タブ
            SettingsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(Color.appPrimary)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
