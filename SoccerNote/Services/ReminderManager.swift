// SoccerNote/Services/ReminderManager.swift
import Foundation
import UserNotifications
import CoreData

class ReminderManager {
    static let shared = ReminderManager()
    
    private init() {}
    
    // 通知許可状態の確認
    func checkNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // アクティビティに対するリマインダーの設定
    func scheduleReminder(for activity: NSManagedObject, at reminderTime: Date, completion: @escaping (Error?) -> Void) {
        guard let id = activity.value(forKey: "id") as? UUID,
              let date = activity.value(forKey: "date") as? Date,
              let type = activity.value(forKey: "type") as? String,
              let location = activity.value(forKey: "location") as? String else {
            completion(NSError(domain: "com.oushin.SoccerNote", code: 1001, userInfo: [NSLocalizedDescriptionKey: "必要な情報が不足しています"]))
            return
        }
        
        // リマインダー時間が過去でないことを確認
        if reminderTime < Date() {
            completion(NSError(domain: "com.oushin.SoccerNote", code: 1002, userInfo: [NSLocalizedDescriptionKey: "リマインダー時間は未来の時間を指定してください"]))
            return
        }
        
        // 通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = type == "match" ? "試合リマインダー" : "練習リマインダー"
        content.body = "\(location)での\(type == "match" ? "試合" : "練習")の時間です。"
        content.sound = UNNotificationSound.default
        
        // アクティビティの詳細情報をユーザー情報として追加
        var userInfo: [String: Any] = [
            "activityId": id.uuidString,
            "activityType": type,
            "activityLocation": location,
            "activityDate": date.timeIntervalSince1970
        ]
        
        // 活動タイプに応じた追加情報
                if type == "match" {
                    // 試合の場合、対戦相手やスコアなどの情報を追加
                    if let match = getMatchDetails(for: activity) {
                        if let opponent = match.value(forKey: "opponent") as? String {
                            userInfo["opponent"] = opponent
                            content.subtitle = "vs \(opponent)"
                        }
                        
                        if let score = match.value(forKey: "score") as? String {
                            userInfo["score"] = score
                        }
                    }
                } else {
                    // 練習の場合、フォーカスエリアなどの情報を追加
                    if let practice = getPracticeDetails(for: activity) {
                        if let focus = practice.value(forKey: "focus") as? String {
                            userInfo["focus"] = focus
                            content.subtitle = "フォーカス: \(focus)"
                        }
                    }
                }
                
                content.userInfo = userInfo
                
                // カレンダートリガーの作成
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                // 通知リクエストの作成
                let identifier = "activity-reminder-\(id.uuidString)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                // 通知のスケジュール
                UNUserNotificationCenter.current().add(request) { error in
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            }
            
            // アクティビティに関連するリマインダーのキャンセル
            func cancelReminder(for activityId: UUID) {
                let identifier = "activity-reminder-\(activityId.uuidString)"
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            }
            
            // 保留中のリマインダーを取得
            func getPendingReminders(completion: @escaping ([UNNotificationRequest]) -> Void) {
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    // アクティビティ関連のリマインダーだけをフィルタリング
                    let activityReminders = requests.filter { request in
                        return request.identifier.starts(with: "activity-reminder-")
                    }
                    
                    DispatchQueue.main.async {
                        completion(activityReminders)
                    }
                }
            }
            
            // 試合詳細の取得
            private func getMatchDetails(for activity: NSManagedObject) -> NSManagedObject? {
                guard let id = activity.value(forKey: "id") as? UUID,
                      let context = activity.managedObjectContext else {
                    return nil
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "Match")
                request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
                request.fetchLimit = 1
                
                do {
                    let results = try context.fetch(request)
                    return results.first
                } catch {
                    print("試合詳細の取得に失敗: \(error)")
                    return nil
                }
            }
            
            // 練習詳細の取得
            private func getPracticeDetails(for activity: NSManagedObject) -> NSManagedObject? {
                guard let id = activity.value(forKey: "id") as? UUID,
                      let context = activity.managedObjectContext else {
                    return nil
                }
                
                let request = NSFetchRequest<NSManagedObject>(entityName: "Practice")
                request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
                request.fetchLimit = 1
                
                do {
                    let results = try context.fetch(request)
                    return results.first
                } catch {
                    print("練習詳細の取得に失敗: \(error)")
                    return nil
                }
            }
            
            // デフォルト設定に基づいたリマインダー時間の計算
            func calculateDefaultReminderTime(for activity: NSManagedObject) -> Date? {
                guard let date = activity.value(forKey: "date") as? Date,
                      let type = activity.value(forKey: "type") as? String else {
                    return nil
                }
                
                // ユーザー設定を取得
                let userDefaults = UserDefaults.standard
                let isReminderEnabled = userDefaults.bool(forKey: "defaultReminderEnabled")
                
                if !isReminderEnabled {
                    return nil
                }
                
                // 活動タイプに応じたリマインダー時間を計算
                let hoursBeforeActivity: Int
                if type == "match" {
                    hoursBeforeActivity = userDefaults.integer(forKey: "matchReminderHours")
                } else {
                    hoursBeforeActivity = userDefaults.integer(forKey: "practiceReminderHours")
                }
                
                // デフォルト値の設定（設定が見つからない場合）
                let reminderHours = hoursBeforeActivity > 0 ? hoursBeforeActivity : (type == "match" ? 24 : 3)
                
                // リマインダー時間の計算
                return date.addingTimeInterval(-Double(reminderHours) * 3600)
            }
        }
