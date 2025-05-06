// SoccerNote/Views/Records/ActivityDetailView.swift
import SwiftUI
import CoreData
import UserNotifications

struct ActivityDetailView: View {
    let activity: NSManagedObject
    
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var errorMessage: String? = nil
    @State private var showingErrorBanner = false
    @State private var isLoading = false
    
    // リマインダー機能のための状態変数
    @State private var hasReminder: Bool = false
    @State private var reminderTime: Date = Date()
    @State private var showingReminderSheet = false
    @State private var isCheckingReminder = true
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.medium) {
                    // ヘッダー
                    HStack {
                        VStack(alignment: .leading) {
                            Text(activityTypeText)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(formattedDate)
                                .font(.subheadline)
                                .foregroundColor(AppDesign.secondaryText)
                        }
                        
                        Spacer()
                        
                        // 評価スター
                        HStack {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= (activity.value(forKey: "rating") as? Int ?? 0) ? AppIcons.Rating.starFill : AppIcons.Rating.star)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // 基本情報
                    Group {
                        DetailRow(title: "場所", value: activity.value(forKey: "location") as? String ?? "")
                        
                        DetailRow(title: "メモ", value: activity.value(forKey: "notes") as? String ?? "")
                    }
                    
                    Divider()
                    
                    // 詳細情報（試合または練習）
                    if let type = activity.value(forKey: "type") as? String, type == "match" {
                        // 試合詳細を表示
                        if let matchDetails = fetchMatchDetails() {
                            Group {
                                DetailRow(title: "対戦相手", value: matchDetails.value(forKey: "opponent") as? String ?? "")
                                
                                DetailRow(title: "スコア", value: matchDetails.value(forKey: "score") as? String ?? "")
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("ゴール")
                                            .font(.headline)
                                        
                                        Text("\(matchDetails.value(forKey: "goalsScored") as? Int ?? 0)")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    VStack(alignment: .leading) {
                                        Text("アシスト")
                                            .font(.headline)
                                        
                                        Text("\(matchDetails.value(forKey: "assists") as? Int ?? 0)")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                DetailRow(title: "出場時間", value: "\(matchDetails.value(forKey: "playingTime") as? Int ?? 0)分")
                                
                                DetailRow(title: "パフォーマンス評価", value: "\(matchDetails.value(forKey: "performance") as? Int ?? 0)/10")
                            }
                        }
                    } else {
                        // 練習詳細を表示
                        if let practiceDetails = fetchPracticeDetails() {
                            Group {
                                DetailRow(title: "フォーカスエリア", value: practiceDetails.value(forKey: "focus") as? String ?? "")
                                
                                DetailRow(title: "練習時間", value: "\(practiceDetails.value(forKey: "duration") as? Int ?? 0)分")
                                
                                Text("練習強度")
                                    .font(.headline)
                                
                                HStack {
                                    ForEach(1...5, id: \.self) { index in
                                        Image(systemName: index <= (practiceDetails.value(forKey: "intensity") as? Int ?? 0) ? AppIcons.Rating.circleFill : AppIcons.Rating.circle)
                                            .foregroundColor(AppDesign.primaryColor)
                                    }
                                }
                                
                                DetailRow(title: "学んだこと", value: practiceDetails.value(forKey: "learnings") as? String ?? "")
                            }
                        }
                    }
                    
                    // リマインダーセクション
                    Group {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("リマインダー")
                                .font(.headline)
                            
                            if isCheckingReminder {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("確認中...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                HStack {
                                    if hasReminder {
                                        Image(systemName: "bell.fill")
                                            .foregroundColor(AppDesign.primaryColor)
                                        
                                        VStack(alignment: .leading) {
                                            Text("リマインダー設定済み")
                                                .font(.subheadline)
                                            
                                            Text(formattedReminderTime)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            showingReminderSheet = true
                                        }) {
                                            Text("編集")
                                                .font(.subheadline)
                                                .foregroundColor(AppDesign.primaryColor)
                                        }
                                        
                                        Button(action: {
                                            cancelReminder()
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    } else {
                                        Button(action: {
                                            showingReminderSheet = true
                                        }) {
                                            HStack {
                                                Image(systemName: "bell")
                                                Text("リマインダーを設定")
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(AppDesign.primaryColor)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // 削除ボタン
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("記録を削除")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.red)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 1)
                        )
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                }
                .padding()
                .alert(isPresented: $showingDeleteConfirmation) {
                    Alert(
                        title: Text("記録を削除"),
                        message: Text("この記録を削除してもよろしいですか？"),
                        primaryButton: .destructive(Text("削除")) {
                            deleteActivity()
                        },
                        secondaryButton: .cancel(Text("キャンセル"))
                    )
                }
            }
            
            // エラーバナー
            if let errorMessage = errorMessage, showingErrorBanner {
                VStack {
                    ErrorBanner(message: errorMessage) {
                        showingErrorBanner = false
                        self.errorMessage = nil
                    }
                    .padding(.top)
                    
                    Spacer()
                }
            }
            
            // ローディングオーバーレイ
            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                LoadingView()
            }
        }
        .navigationBarTitle("詳細", displayMode: .inline)
        .navigationBarItems(trailing: Button("編集") {
            showingEditSheet = true
        })
        .sheet(isPresented: $showingEditSheet) {
            // 編集画面を表示
            if let type = activity.value(forKey: "type") as? String, type == "match" {
                EditMatchView(activity: activity)
            } else {
                EditPracticeView(activity: activity)
            }
        }
        .sheet(isPresented: $showingReminderSheet) {
            ReminderEditSheet(isPresented: $showingReminderSheet, activity: activity, reminderTime: $reminderTime, hasReminder: $hasReminder)
        }
        .onAppear {
            checkForReminder()
        }
    }
    
    // 試合詳細の取得
    private func fetchMatchDetails() -> NSManagedObject? {
        guard let id = activity.value(forKey: "id") as? UUID else { return nil }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Match")
        request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let context = activity.managedObjectContext!
            let results = try context.fetch(request)
            return results.first
        } catch {
            self.errorMessage = "試合詳細の取得に失敗しました"
            self.showingErrorBanner = true
            print("試合詳細の取得に失敗: \(error)")
            return nil
        }
    }
    
    // 練習詳細の取得
    private func fetchPracticeDetails() -> NSManagedObject? {
        guard let id = activity.value(forKey: "id") as? UUID else { return nil }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Practice")
        request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let context = activity.managedObjectContext!
            let results = try context.fetch(request)
            return results.first
        } catch {
            self.errorMessage = "練習詳細の取得に失敗しました"
            self.showingErrorBanner = true
            print("練習詳細の取得に失敗: \(error)")
            return nil
        }
    }
    
    // 活動の削除
    private func deleteActivity() {
        isLoading = true
        
        let backgroundContext = PersistenceController.shared.newBackgroundContext()
        
        // objectIDがオプショナルでないのでガード文は削除し、直接使用
        let activityID = activity.objectID
        
        backgroundContext.perform {
            do {
                let activityToDelete = try backgroundContext.existingObject(with: activityID)
                backgroundContext.delete(activityToDelete)
                
                try backgroundContext.save()
                
                // 関連リマインダーも削除
                if let id = self.activity.value(forKey: "id") as? UUID {
                    ReminderManager.shared.cancelReminder(for: id)
                }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    // 詳細画面を閉じて一覧に戻る
                    self.presentationMode.wrappedValue.dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "活動の削除に失敗しました: \(error.localizedDescription)"
                    self.showingErrorBanner = true
                }
                print("活動の削除に失敗: \(error)")
            }
        }
    }
    
    // リマインダーの存在チェック
    private func checkForReminder() {
        isCheckingReminder = true
        
        guard let id = activity.value(forKey: "id") as? UUID else {
            isCheckingReminder = false
            return
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifier = "activity-reminder-\(id.uuidString)"
            
            if let reminderRequest = requests.first(where: { $0.identifier == identifier }),
               let trigger = reminderRequest.trigger as? UNCalendarNotificationTrigger,
               let nextTriggerDate = trigger.nextTriggerDate() {
                
                DispatchQueue.main.async {
                    self.hasReminder = true
                    self.reminderTime = nextTriggerDate
                    self.isCheckingReminder = false
                }
            } else {
                // リマインダーが見つからない場合はデフォルト時間を計算
                DispatchQueue.main.async {
                    if let date = self.activity.value(forKey: "date") as? Date {
                        // デフォルトでは1時間前に設定
                        self.reminderTime = date.addingTimeInterval(-3600)
                    }
                    self.hasReminder = false
                    self.isCheckingReminder = false
                }
            }
        }
    }
    
    // リマインダーの設定
    private func setReminder() {
        guard let id = activity.value(forKey: "id") as? UUID else { return }
        
        // まず既存のリマインダーをキャンセル
        let identifier = "activity-reminder-\(id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // 通知許可の確認
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                // リマインダーマネージャーを使用
                ReminderManager.shared.scheduleReminder(for: self.activity, at: self.reminderTime) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.errorMessage = "リマインダーの設定に失敗しました: \(error.localizedDescription)"
                            self.showingErrorBanner = true
                            self.hasReminder = false
                        } else {
                            self.hasReminder = true
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "通知の許可が必要です"
                    self.showingErrorBanner = true
                    self.hasReminder = false
                }
            }
        }
    }
    
    // リマインダーのキャンセル
    private func cancelReminder() {
        guard let id = activity.value(forKey: "id") as? UUID else { return }
        ReminderManager.shared.cancelReminder(for: id)
        hasReminder = false
    }
    
    // ヘルパープロパティ
    private var activityTypeText: String {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? "試合" : "練習"
    }
    
    private var formattedDate: String {
        let date = activity.value(forKey: "date") as? Date ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: reminderTime)
    }
}
