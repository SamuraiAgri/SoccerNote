// SoccerNote/Views/Reminders/RemindersListView.swift
import SwiftUI
import UserNotifications

struct RemindersListView: View {
    @StateObject private var reminderViewModel = ReminderViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                if reminderViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if reminderViewModel.pendingReminders.isEmpty {
                    // リマインダーがない場合の表示
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("リマインダーがありません")
                            .font(.headline)
                        
                        Text("試合や練習のリマインダーを設定して、忘れずに準備しましょう")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingAddSheet = true
                        }) {
                            Label("リマインダーを追加", systemImage: "plus")
                                .padding()
                                .background(AppDesign.primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    // リマインダーリスト
                    List {
                        ForEach(reminderViewModel.pendingReminders, id: \.identifier) { request in
                            ReminderRow(request: request)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        reminderViewModel.cancelReminder(with: request.identifier)
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        reminderViewModel.fetchPendingReminders()
                    }
                }
            }
            .navigationTitle("リマインダー")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                QuickReminderView(reminderViewModel: reminderViewModel)
            }
            .onAppear {
                // 通知許可の確認
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    // 許可が得られなくても、リマインダー一覧は表示できるようにする
                    reminderViewModel.fetchPendingReminders()
                }
            }
            .alert(item: Binding<ReminderAlert?>(
                get: {
                    if let message = reminderViewModel.errorMessage {
                        return ReminderAlert(message: message)
                    }
                    return nil
                },
                set: { _ in
                    reminderViewModel.errorMessage = nil
                }
            )) { alert in
                Alert(
                    title: Text("エラー"),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// リマインダー行
struct ReminderRow: View {
    let request: UNNotificationRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // タイトルと時間
            HStack {
                Text(request.content.title)
                    .font(.headline)
                
                Spacer()
                
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let nextTriggerDate = trigger.nextTriggerDate() {
                    Text(formatDate(nextTriggerDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 内容
            Text(request.content.body)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // リマインダータイプアイコン
            HStack {
                if request.content.title.contains("試合") {
                    Image(systemName: "sportscourt.fill")
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "figure.walk")
                        .foregroundColor(AppDesign.primaryColor)
                }
                
                Text(getRelativeTimeString(for: request))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    // 日付のフォーマット
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 相対時間の表示
    private func getRelativeTimeString(for request: UNNotificationRequest) -> String {
        guard let trigger = request.trigger as? UNCalendarNotificationTrigger,
              let nextTriggerDate = trigger.nextTriggerDate() else {
            return ""
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: nextTriggerDate, relativeTo: Date())
    }
}

// クイックリマインダー追加ビュー
struct QuickReminderView: View {
    @Environment(\.presentationMode) var presentationMode
    let reminderViewModel: ReminderViewModel
    
    @State private var title = ""
    @State private var body = ""
    @State private var reminderType: ReminderType = .match
    @State private var reminderDate = Date().addingTimeInterval(3600) // 1時間後
    
    var body: some View {
        NavigationView {
            Form {
                // リマインダータイプ
                Section(header: Text("リマインダータイプ")) {
                    Picker("", selection: $reminderType) {
                        ForEach(ReminderType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // リマインダー情報
                Section(header: Text("リマインダー情報")) {
                    TextField("タイトル", text: $title)
                        .onChange(of: reminderType) { _, newValue in
                            // タイプが変更されたときにデフォルトタイトルを設定
                            if title.isEmpty || title == "試合リマインダー" || title == "練習リマインダー" {
                                title = newValue == .match ? "試合リマインダー" : "練習リマインダー"
                            }
                        }
                        .onAppear {
                            // 初期タイトルを設定
                            title = reminderType == .match ? "試合リマインダー" : "練習リマインダー"
                        }
                    
                    TextField("内容", text: $body)
                    
                    DatePicker("日時", selection: $reminderDate)
                }
                
                // 追加ボタン
                Section {
                    Button(action: {
                        addReminder()
                    }) {
                        Text("リマインダーを追加")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .disabled(title.isEmpty || body.isEmpty)
                }
            }
            .navigationTitle("リマインダー追加")
            .navigationBarItems(trailing: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // リマインダー追加処理
    private func addReminder() {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        // 通知トリガーを作成
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // 通知識別子を作成
        let identifier = "manual-reminder-\(UUID().uuidString)"
        
        // リクエストを作成
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // リクエストをスケジュール
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("リマインダーの追加に失敗しました: \(error.localizedDescription)")
                } else {
                    // 成功したら一覧を更新してシートを閉じる
                    self.reminderViewModel.fetchPendingReminders()
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

// リマインダータイプ
enum ReminderType: String, CaseIterable, Identifiable {
    case match = "試合"
    case practice = "練習"
    
    var id: String { self.rawValue }
}

// アラート表示用の識別可能な構造体
struct ReminderAlert: Identifiable {
    var id = UUID()
    var message: String
}
