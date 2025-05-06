// SoccerNote/Views/AddRecord/QuickAddView.swift
import SwiftUI
import CoreData

struct QuickAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var activityViewModel: ActivityViewModel
    @StateObject private var matchViewModel: MatchViewModel
    @StateObject private var practiceViewModel: PracticeViewModel
    
    // 基本情報
    @State private var selectedType: ActivityType = .match
    @State private var date: Date
    @State private var location = ""
    @State private var notes = ""
    @State private var rating = 3
    
    // 試合情報
    @State private var opponent = ""
    @State private var score = ""
    @State private var goalsScored = 0
    @State private var assists = 0
    
    // 練習情報
    @State private var focus = ""
    @State private var duration = 60
    @State private var intensity = 3
    
    // UI状態管理
    @State private var currentStep = 0
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    // リマインダー設定
    @State private var setReminder = false
    @State private var reminderTime: Date
    
    init(date: Date? = nil) {
        let context = PersistenceController.shared.container.viewContext
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(viewContext: context))
        _matchViewModel = StateObject(wrappedValue: MatchViewModel(viewContext: context))
        _practiceViewModel = StateObject(wrappedValue: PracticeViewModel(viewContext: context))
        
        let initialDate = date ?? Date()
        self._date = State(initialValue: initialDate)
        
        // リマインダー時間のデフォルト設定（1時間前）
        self._reminderTime = State(initialValue: initialDate.addingTimeInterval(-3600))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // プログレスバー
                ProgressBar(currentStep: currentStep, totalSteps: 2)
                    .padding(.top)
                
                // ステップ内容
                ScrollView {
                    VStack(spacing: 20) {
                        // ステップに応じたコンテンツ
                        if currentStep == 0 {
                            // ステップ1: 基本情報
                            basicInfoSection
                        } else {
                            // ステップ2: 詳細情報（タイプに応じて表示切替）
                            if selectedType == .match {
                                matchDetailsSection
                            } else {
                                practiceDetailsSection
                            }
                        }
                    }
                    .padding()
                }
                
                // ナビゲーションボタン
                HStack {
                    // 戻るボタン
                    if currentStep > 0 {
                        Button(action: {
                            withAnimation {
                                currentStep -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("戻る")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .foregroundColor(AppDesign.primaryColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppDesign.primaryColor, lineWidth: 1)
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // 次へ/保存ボタン
                    Button(action: {
                        if currentStep < 1 {
                            // 入力チェック
                            if isCurrentStepValid {
                                withAnimation {
                                    currentStep += 1
                                }
                            } else {
                                errorMessage = currentStep == 0 ? "場所を入力してください" : ""
                                showingErrorAlert = true
                            }
                        } else {
                            // 保存処理
                            saveRecord()
                        }
                    }) {
                        HStack {
                            Text(currentStep < 1 ? "次へ" : "保存する")
                            Image(systemName: currentStep < 1 ? "chevron.right" : "checkmark")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(isCurrentStepValid ? AppDesign.primaryColor : Color.gray)
                        .cornerRadius(8)
                    }
                    .disabled(!isCurrentStepValid || isLoading)
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
            }
            .navigationTitle(currentStepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("入力エラー"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay(
                ZStack {
                    if isLoading {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("保存中...")
                                .foregroundColor(.white)
                                .padding(.top, 10)
                        }
                        .padding(30)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                    }
                    
                    if showingSuccessAlert {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("保存完了")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("記録が保存されました")
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                showingSuccessAlert = false
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("OK")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppDesign.primaryColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(30)
                        .frame(width: 280)
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    }
                }
            )
        }
    }
    
    // 基本情報セクション
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // タイプ選択
            VStack(alignment: .leading) {
                Text("記録タイプ")
                    .font(.headline)
                
                Picker("", selection: $selectedType) {
                    ForEach(ActivityType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // 日付選択
            VStack(alignment: .leading) {
                Text("日時")
                    .font(.headline)
                
                DatePicker("", selection: $date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // 場所入力
            VStack(alignment: .leading) {
                Text("場所")
                    .font(.headline)
                
                TextField("場所を入力", text: $location)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // 評価
            VStack(alignment: .leading) {
                Text("評価")
                    .font(.headline)
                
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 30))
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    rating = star
                                }
                            }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // メモ入力
            VStack(alignment: .leading) {
                Text("メモ (任意)")
                    .font(.headline)
                
                TextEditor(text: $notes)
                    .frame(height: 100)
                    .padding(4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            // リマインダー設定
            VStack(alignment: .leading) {
                Toggle("リマインダーを設定", isOn: $setReminder)
                    .padding(.vertical, 8)
                
                if setReminder {
                    DatePicker("リマインダー時間", selection: $reminderTime)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    // 試合詳細セクション
    private var matchDetailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 対戦相手
            VStack(alignment: .leading) {
                Text("対戦相手")
                    .font(.headline)
                
                TextField("対戦相手を入力", text: $opponent)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // スコア
            VStack(alignment: .leading) {
                Text("スコア")
                    .font(.headline)
                
                TextField("例: 2-1", text: $score)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // 得点
            VStack(alignment: .leading) {
                Text("得点数")
                    .font(.headline)
                
                HStack {
                    Button(action: {
                        if goalsScored > 0 {
                            goalsScored -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppDesign.primaryColor)
                    }
                    
                    Text("\(goalsScored)")
                        .font(.title)
                        .frame(width: 50)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        goalsScored += 1
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppDesign.primaryColor)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // アシスト
            VStack(alignment: .leading) {
                Text("アシスト数")
                    .font(.headline)
                
                HStack {
                    Button(action: {
                        if assists > 0 {
                            assists -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppDesign.primaryColor)
                    }
                    
                    Text("\(assists)")
                        .font(.title)
                        .frame(width: 50)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        assists += 1
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppDesign.primaryColor)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // 練習詳細セクション
    private var practiceDetailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 練習内容
            VStack(alignment: .leading) {
                Text("フォーカスエリア")
                    .font(.headline)
                
                TextField("例: パス練習、シュート練習など", text: $focus)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // 練習時間
            VStack(alignment: .leading) {
                Text("練習時間: \(duration)分")
                    .font(.headline)
                
                Slider(value: Binding(
                    get: { Double(duration) },
                    set: { duration = Int($0) }
                ), in: 15...240, step: 15)
                .accentColor(AppDesign.primaryColor)
                .padding(.vertical, 8)
            }
            
            // 練習強度
            VStack(alignment: .leading) {
                Text("練習強度")
                    .font(.headline)
                
                VStack {
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Circle()
                                .fill(index <= intensity ? AppDesign.primaryColor : Color.gray.opacity(0.3))
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    intensity = index
                                }
                        }
                    }
                    
                    HStack {
                        Text("軽い")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                        Spacer()
                            
                        Text("普通")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                        Spacer()
                            
                        Text("ハード")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // 現在のステップのタイトル
    private var currentStepTitle: String {
        if currentStep == 0 {
            return "基本情報"
        } else {
            return selectedType == .match ? "試合詳細" : "練習詳細"
        }
    }
    
    // 現在のステップが有効かどうか
    private var isCurrentStepValid: Bool {
        if currentStep == 0 {
            return !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } else {
            if selectedType == .match {
                return !opponent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                       !score.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            } else {
                return !focus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        }
    }
    
    // 記録保存処理（修正版）
    private func saveRecord() {
        isLoading = true
        
        // バックグラウンドコンテキストを使用してデータ保存
        let backgroundContext = PersistenceController.shared.newBackgroundContext()
        
        backgroundContext.perform {
            // 活動エンティティの作成
            let activity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: backgroundContext)
            activity.setValue(self.date, forKey: "date")
            activity.setValue(self.selectedType.rawValue, forKey: "type")
            activity.setValue(self.location, forKey: "location")
            activity.setValue(self.notes, forKey: "notes")
            activity.setValue(self.rating, forKey: "rating")
            activity.setValue(UUID(), forKey: "id")
            
            // 試合か練習かによって詳細情報を保存
            if self.selectedType == .match {
                let match = NSEntityDescription.insertNewObject(forEntityName: "Match", into: backgroundContext)
                match.setValue(self.opponent, forKey: "opponent")
                match.setValue(self.score, forKey: "score")
                match.setValue(self.goalsScored, forKey: "goalsScored")
                match.setValue(self.assists, forKey: "assists")
                match.setValue(90, forKey: "playingTime") // デフォルト値
                match.setValue(5, forKey: "performance") // デフォルト値
                match.setValue(UUID(), forKey: "id")
                match.setValue(activity, forKey: "activity")
            } else {
                let practice = NSEntityDescription.insertNewObject(forEntityName: "Practice", into: backgroundContext)
                practice.setValue(self.focus, forKey: "focus")
                practice.setValue(self.duration, forKey: "duration")
                practice.setValue(self.intensity, forKey: "intensity")
                practice.setValue("", forKey: "learnings")
                practice.setValue(UUID(), forKey: "id")
                practice.setValue(activity, forKey: "activity")
            }
            
            // データを保存
            do {
                try backgroundContext.save()
                
                // リマインダーが設定されていれば登録
                if self.setReminder {
                    DispatchQueue.main.async {
                        self.scheduleReminder()
                    }
                }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.showingSuccessAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "保存に失敗しました: \(error.localizedDescription)"
                    self.showingErrorAlert = true
                }
            }
        }
    }
    
    // リマインダーをスケジュール
    private func scheduleReminder() {
        let center = UNUserNotificationCenter.current()
        
        // 通知の許可を確認
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                // 通知コンテンツの作成
                let content = UNMutableNotificationContent()
                content.title = selectedType == .match ? "試合リマインダー" : "練習リマインダー"
                content.body = "\(location)での\(selectedType.rawValue)の時間です。"
                content.sound = UNNotificationSound.default
                
                // 通知をトリガーする時間コンポーネントを作成
                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                // リクエストを作成して追加
                let identifier = UUID().uuidString
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                center.add(request) { error in
                    if let error = error {
                        print("リマインダーの設定に失敗しました: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

// プログレスバーコンポーネント
struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Rectangle()
                    .fill(step <= currentStep ? AppDesign.primaryColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    QuickAddView()
}
