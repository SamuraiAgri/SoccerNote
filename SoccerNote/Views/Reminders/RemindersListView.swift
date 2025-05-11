// RemindersListView.swift
import SwiftUI
import UserNotifications

struct RemindersListView: View {
    @StateObject private var reminderViewModel = ReminderViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
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
                }
                .padding()
            } else {
                // リマインダーリスト
                List {
                    ForEach(reminderViewModel.pendingReminders, id: \.identifier) { request in
                        ReminderRowView(request: request)
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
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("完了")
                }
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
        .onAppear {
            reminderViewModel.fetchPendingReminders()
        }
    }
}

// リマインダー行
struct ReminderRowView: View {
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
                    Text(formattedDate(nextTriggerDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 内容
            Text(request.content.body)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    // 日付のフォーマット
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct RemindersListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RemindersListView()
        }
    }
}
