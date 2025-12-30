// MainTabView.swift
import SwiftUI

// タブ選択を管理するクラス
class TabSelectionManager: ObservableObject {
    @Published var selectedTab = 0
}

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var tabSelectionManager = TabSelectionManager()
    @State private var showingReflectionSheet = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tabSelectionManager.selectedTab) {
                // 1. ホームタブ
                HomeView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(tabSelectionManager)
                    .tabItem {
                        Label("ホーム", systemImage: "house.fill")
                    }
                    .tag(0)
                
                // 2. 振り返りノートタブ
                ReflectionListView()
                    .environment(\.managedObjectContext, viewContext)
                    .tabItem {
                        Label("ノート", systemImage: "book.fill")
                    }
                    .tag(1)
                
                // 3. ダミータブ（中央のプラスボタン用）
                Color.clear
                    .tabItem {
                        Label("", systemImage: "")
                    }
                    .tag(2)
                
                // 4. 記録タブ
                QuickActivityAddView()
                    .environment(\.managedObjectContext, viewContext)
                    .tabItem {
                        Label("記録", systemImage: "sportscourt.fill")
                    }
                    .tag(3)
                
                // 5. 設定タブ
                SettingsView()
                    .environment(\.managedObjectContext, viewContext)
                    .tabItem {
                        Label("設定", systemImage: "gear")
                    }
                    .tag(4)
            }
            .accentColor(Color.appPrimary)
            
            // 中央の振り返りボタン
            Button(action: {
                HapticFeedback.medium()
                showingReflectionSheet = true
            }) {
                ZStack {
                    Circle()
                        .fill(AppDesign.primaryColor)
                        .frame(width: 56, height: 56)
                        .shadow(color: AppDesign.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .offset(y: -20)
        }
        .sheet(isPresented: $showingReflectionSheet) {
            ReflectionAddView()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

