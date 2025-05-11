// MainTabView.swift
import SwiftUI

// タブ選択を管理するクラス
class TabSelectionManager: ObservableObject {
    @Published var selectedTab = 0
}

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var tabSelectionManager = TabSelectionManager()
    
    var body: some View {
        TabView(selection: $tabSelectionManager.selectedTab) {
            // 1. ホームタブ
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(tabSelectionManager)
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
