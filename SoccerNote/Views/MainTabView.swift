// SoccerNote/Views/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: Int = 0
    
    // 記録追加シートの表示状態
    @State private var showingAddSheet = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 記録タブ（メインのホーム画面として機能）
            RecordsHomeView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("記録", systemImage: "calendar")
                }
                .tag(0)
            
            // 目標タブ
            GoalsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("目標", systemImage: "flag")
                }
                .tag(1)
            
            // 統計タブ
            StatsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("統計", systemImage: "chart.bar")
                }
                .tag(2)
        }
        .accentColor(AppDesign.primaryColor)
        .sheet(isPresented: $showingAddSheet) {
            AddRecordView()
                .environment(\.managedObjectContext, viewContext)
        }
        // 全体にEnvironmentValueとして記録追加シートの表示状態を渡す
        .environmentObject(AddSheetController())
    }
}

// 記録追加シートのコントローラー
class AddSheetController: ObservableObject {
    @Published var isShowingAddSheet = false
    
    func showAddSheet() {
        isShowingAddSheet = true
    }
}

// プレビュー
#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
