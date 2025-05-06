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
