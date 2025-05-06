// SoccerNote/ViewModels/ReminderViewModel.swift
import Foundation
import UserNotifications
import CoreData
import Combine

class ReminderViewModel: ObservableObject {
    @Published var pendingReminders: [UNNotificationRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchPendingReminders()
    }
    
    // 保留中のリマインダーを取得
    func fetchPendingReminders() {
        isLoading = true
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            DispatchQueue.main.async {
                self?.pendingReminders = requests
                self?.isLoading = false
            }
        }
    }
    
    // アクティビティ用のリマインダーを設定
    func scheduleReminder(for activity: NSManagedObject, at reminderTime: Date) {
        // 通知の許可を確認
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if granted {
                self?.createAndScheduleReminder(for: activity, at: reminderTime)
            } else {
                DispatchQueue.main.async {
                    self?.errorMessage = "通知の許可が必要です。設定アプリから許可してください。"
                }
            }
        }
    }
    
    // リマインダーを作成してスケジュールする
    private func createAndScheduleReminder(for activity: NSManagedObject, at reminderTime: Date) {
        guard let id = activity.value(forKey: "id") as? UUID,
              let date = activity.value(forKey: "date") as? Date,
              let type = activity.value(forKey: "type") as? String,
              let location = activity.value(forKey: "location") as? String else {
            return
        }
        
        // 通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = type == "match" ? "試合リマインダー" : "練習リマインダー"
        content.body = "\(location)での\(type == "match" ? "試合" : "練習")の時間です。"
        content.sound = UNNotificationSound.default
        
        // 通知識別子を作成（アクティビティIDを使用）
        let identifier = "reminder-\(id.uuidString)"
        
        // 通知トリガーを作成
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // リクエストを作成
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // リクエストをスケジュール
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "リマインダーの設定に失敗しました: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self?.fetchPendingReminders()
                }
            }
        }
    }
    
    // リマインダーをキャンセル
    func cancelReminder(with identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        fetchPendingReminders()
    }
    
    // アクティビティIDに基づいてリマインダーをキャンセル
    func cancelReminder(for activityID: UUID) {
        let identifier = "reminder-\(activityID.uuidString)"
        cancelReminder(with: identifier)
    }
    
    // すべてのリマインダーをキャンセル
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        fetchPendingReminders()
    }
}
