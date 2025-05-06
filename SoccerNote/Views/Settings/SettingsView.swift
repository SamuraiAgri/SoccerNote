// SoccerNote/Views/Settings/SettingsView.swift
import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("teamName") private var teamName: String = ""
    @AppStorage("position") private var position: String = ""
    @AppStorage("darkModeOn") private var darkModeOn: Bool = false
    
    @State private var showingConfirmation = false
    @State private var confirmationMessage = ""
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            Form {
                // ユーザー情報セクション
                Section(header: Text("プレイヤー情報")) {
                    TextField("名前", text: $userName)
                    TextField("チーム名", text: $teamName)
                    TextField("ポジション", text: $position)
                }
                
                // アプリ設定セクション
                Section(header: Text("アプリ設定")) {
                    Toggle("ダークモード", isOn: $darkModeOn)
                        .onChange(of: darkModeOn) { _, newValue in
                            applyTheme(darkMode: newValue)
                        }
                }
                
                // データ管理セクション
                Section(header: Text("データ管理")) {
                    Button(action: {
                        confirmationMessage = "エクスポート機能は将来のアップデートで実装予定です。"
                        showingConfirmation = true
                    }) {
                        Label("データのエクスポート", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        confirmationMessage = "インポート機能は将来のアップデートで実装予定です。"
                        showingConfirmation = true
                    }) {
                        Label("データのインポート", systemImage: "square.and.arrow.down")
                    }
                    
                    Button(action: {
                        confirmationMessage = "すべてのデータを削除してもよろしいですか？この操作は元に戻せません。"
                        showingConfirmation = true
                    }) {
                        Label("データをリセット", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // アプリ情報セクション
                Section(header: Text("アプリ情報")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        confirmationMessage = "評価機能は将来のアップデートで実装予定です。"
                        showingConfirmation = true
                    }) {
                        Label("アプリを評価する", systemImage: "star")
                    }
                    
                    Button(action: {
                        confirmationMessage = "お問い合わせ機能は将来のアップデートで実装予定です。"
                        showingConfirmation = true
                    }) {
                        Label("お問い合わせ", systemImage: "envelope")
                    }
                }
            }
            .navigationTitle("設定")
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text("確認"),
                    message: Text(confirmationMessage),
                    primaryButton: .cancel(Text("キャンセル")),
                    secondaryButton: .destructive(Text("OK")) {
                        if confirmationMessage.contains("データをリセット") {
                            resetAllData()
                        }
                    }
                )
            }
        }
    }
    
    // ダークモード適用
    private func applyTheme(darkMode: Bool) {
        // システム設定に任せる場合はコメントアウト
        // UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkMode ? .dark : .light
    }
    
    // すべてのデータをリセット
    private func resetAllData() {
        let entities = ["Activity", "Match", "Practice", "Goal"]
        
        let backgroundContext = PersistenceController.shared.newBackgroundContext()
        
        backgroundContext.perform {
            for entityName in entities {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try backgroundContext.execute(batchDeleteRequest)
                } catch {
                    print("Entity \(entityName) のリセットに失敗: \(error)")
                }
            }
            
            do {
                try backgroundContext.save()
            } catch {
                print("コンテキストの保存に失敗: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
}
