// SoccerNote/Views/Settings/SettingsView.swift
import SwiftUI
import CoreData

struct SettingsView: View {
    // プレイヤー情報は残すが、オプション扱いに
    @AppStorage("playerInfoEnabled") private var playerInfoEnabled: Bool = false
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("teamName") private var teamName: String = ""
    @AppStorage("position") private var position: String = ""
    
    // リマインダー設定
    @AppStorage("defaultReminderEnabled") private var defaultReminderEnabled: Bool = false
    @AppStorage("matchReminderHours") private var matchReminderHours: Int = 24
    @AppStorage("practiceReminderHours") private var practiceReminderHours: Int = 3
    
    @State private var showingConfirmation = false
    @State private var confirmationMessage = ""
    @State private var showingReminders = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            Form {
                // プレイヤー情報（オプション）
                Section {
                    Toggle(isOn: $playerInfoEnabled) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(Color.appPrimary)
                                .font(.headline)
                            Text("プレイヤー情報を記録")
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.appPrimary))
                    
                    if playerInfoEnabled {
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.secondary)
                                .frame(width: 25)
                            TextField("名前", text: $userName)
                        }
                        
                        HStack {
                            Image(systemName: "shield")
                                .foregroundColor(.secondary)
                                .frame(width: 25)
                            TextField("チーム名", text: $teamName)
                        }
                        
                        HStack {
                            Image(systemName: "figure.soccer")
                                .foregroundColor(.secondary)
                                .frame(width: 25)
                            TextField("ポジション", text: $position)
                        }
                    }
                } header: {
                    Text("プロフィール")
                } footer: {
                    if playerInfoEnabled {
                        Text("個人の情報を記録することで、将来の分析に役立ちます")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // リマインダー設定
                Section {
                    Toggle(isOn: $defaultReminderEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(Color.appSecondary)
                                .font(.headline)
                            Text("デフォルトでリマインダーを設定")
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.appSecondary))
                    
                    if defaultReminderEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("試合前リマインダー")
                                Spacer()
                                Text("\(matchReminderHours)時間前")
                                    .foregroundColor(Color.appSecondary)
                                    .fontWeight(.semibold)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(matchReminderHours) },
                                set: { matchReminderHours = Int($0) }
                            ), in: 1...72, step: 1)
                            .accentColor(Color.appSecondary)
                        }
                        .padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("練習前リマインダー")
                                Spacer()
                                Text("\(practiceReminderHours)時間前")
                                    .foregroundColor(Color.appPrimary)
                                    .fontWeight(.semibold)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(practiceReminderHours) },
                                set: { practiceReminderHours = Int($0) }
                            ), in: 1...24, step: 1)
                            .accentColor(Color.appPrimary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        showingReminders = true
                    }) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard")
                                .foregroundColor(Color.appAccent)
                            Text("リマインダー管理")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("リマインダー設定")
                }
                
                // アプリ情報セクション - ダークモードを削除
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color.appAccent)
                            .frame(width: 25)
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        // レビュー画面への導線（実装時に追加）
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.appSecondary)
                                .frame(width: 25)
                            Text("アプリを評価する")
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("アプリ情報")
                }
                
                // データ管理セクション
                Section {
                    Button(action: resetConfirmation) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(Color.appError)
                                .frame(width: 25)
                            Text("すべてのデータをリセット")
                                .foregroundColor(Color.appError)
                        }
                    }
                } header: {
                    Text("データ管理")
                } footer: {
                    Text("すべてのデータを削除します。この操作は元に戻せません。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("設定")
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text("確認"),
                    message: Text(confirmationMessage),
                    primaryButton: .destructive(Text("リセット")) {
                        resetAllData()
                    },
                    secondaryButton: .cancel(Text("キャンセル"))
                )
            }
            .sheet(isPresented: $showingReminders) {
                NavigationView {
                    RemindersListView()
                }
            }
        }
    }
    
    // リセット確認
    private func resetConfirmation() {
        confirmationMessage = "すべてのデータを削除してもよろしいですか？この操作は元に戻せません。"
        showingConfirmation = true
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
        
        // リマインダーもリセット
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
