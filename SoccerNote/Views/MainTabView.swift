// SoccerNote/Views/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var addSheetController = AddSheetController()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // ホームタブ（カレンダー＋その日の記録）
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(addSheetController)
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
                .tag(0)
            
            // 記録一覧タブ
            RecordListView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("記録", systemImage: "list.bullet")
                }
                .tag(1)
            
            // 分析タブ（統計＋目標を統合）
            AnalysisView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("分析", systemImage: "chart.bar")
                }
                .tag(2)
            
            // 設定タブ（新規追加）
            SettingsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(AppDesign.primaryColor)
        .sheet(isPresented: $addSheetController.isShowingAddSheet) {
            QuickAddView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

// 記録追加シートのコントローラー
class AddSheetController: ObservableObject {
    @Published var isShowingAddSheet = false
    @Published var preselectedDate: Date? = nil
    
    func showAddSheet(for date: Date? = nil) {
        self.preselectedDate = date
        isShowingAddSheet = true
    }
}

// プレビュー
#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
