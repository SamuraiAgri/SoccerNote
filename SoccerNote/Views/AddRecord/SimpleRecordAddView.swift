// SoccerNote/Views/AddRecord/SimpleRecordAddView.swift
import SwiftUI
import CoreData

struct SimpleRecordAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var activityType: ActivityType = .match
    @State private var date = Date()
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
    
    @State private var isLoading = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                // 基本情報セクション
                Section(header: Text("基本情報")) {
                    // タイプ選択をピッカーからより視覚的なボタンに変更
                    HStack(spacing: 15) {
                        matchTypeButton
                        practiceTypeButton
                    }
                    .padding(.bottom, 8)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                    
                    DatePicker("日時", selection: $date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .accentColor(
                            activityType == .match ? Color.appSecondary : Color.appPrimary
                        )
                    
                    VStack {
                        TextField("場所", text: $location)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                    
                    starRatingView
                    
                    if !notes.isEmpty || activityType == .practice {
                        notesField
                    }
                }
                
                // 活動タイプに応じたセクション
                if activityType == .match {
                    matchDetailsSection
                } else {
                    practiceDetailsSection
                }
                
                // 保存ボタン
                Section {
                    Button(action: saveRecord) {
                        saveButtonContent
                    }
                    .disabled(!isFormValid || isLoading)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                }
            }
            .navigationTitle("記録追加")
            .alert(isPresented: $showSuccess) {
                Alert(
                    title: Text("保存完了"),
                    message: Text("記録が保存されました"),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // 試合タイプボタン
    private var matchTypeButton: some View {
        Button(action: {
            withAnimation {
                activityType = .match
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 24))
                Text("試合")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(activityType == .match ? Color.appSecondary.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(activityType == .match ? Color.appSecondary : Color.gray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(activityType == .match ? Color.appSecondary : Color.clear, lineWidth: 2)
            )
        }
    }
    
    // 練習タイプボタン
    private var practiceTypeButton: some View {
        Button(action: {
            withAnimation {
                activityType = .practice
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 24))
                Text("練習")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(activityType == .practice ? Color.appPrimary.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(activityType == .practice ? Color.appPrimary : Color.gray)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(activityType == .practice ? Color.appPrimary : Color.clear, lineWidth: 2)
            )
        }
    }
    
    // 星評価ビュー
    private var starRatingView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("評価")
                .font(.headline)
            
            HStack {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(index <= rating ? .yellow : .gray)
                        .font(.system(size: 24))
                        .onTapGesture {
                            withAnimation(.spring()) {
                                rating = index
                            }
                        }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // メモフィールド
    private var notesField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("メモ (任意)")
                .font(.headline)
            
            TextEditor(text: $notes)
                .frame(height: 100)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.vertical, 8)
    }
    
    // 試合詳細セクション
    private var matchDetailsSection: some View {
        Section(header: Text("試合情報")) {
            VStack {
                TextField("対戦相手", text: $opponent)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .listRowInsets(EdgeInsets())
            .padding(.horizontal)
            
            VStack {
                TextField("スコア (例: 2-1)", text: $score)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .listRowInsets(EdgeInsets())
            .padding(.horizontal)
            
            goalsStepperView
            
            assistsStepperView
        }
    }
    
    // ゴールステッパー
    private var goalsStepperView: some View {
        HStack {
            Text("得点")
            Spacer()
            HStack {
                Button(action: {
                    if goalsScored > 0 {
                        goalsScored -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(Color.appSecondary)
                        .font(.system(size: 24))
                }
                
                Text("\(goalsScored)")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 40, alignment: .center)
                
                Button(action: {
                    goalsScored += 1
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color.appSecondary)
                        .font(.system(size: 24))
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // アシストステッパー
    private var assistsStepperView: some View {
        HStack {
            Text("アシスト")
            Spacer()
            HStack {
                Button(action: {
                    if assists > 0 {
                        assists -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(Color.appSecondary)
                        .font(.system(size: 24))
                }
                
                Text("\(assists)")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 40, alignment: .center)
                
                Button(action: {
                    assists += 1
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color.appSecondary)
                        .font(.system(size: 24))
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // 練習詳細セクション
    private var practiceDetailsSection: some View {
        Section(header: Text("練習情報")) {
            VStack {
                TextField("フォーカスエリア", text: $focus)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .listRowInsets(EdgeInsets())
            .padding(.horizontal)
            
            durationSliderView
            
            intensitySelectionView
        }
    }
    
    // 練習時間スライダー
    private var durationSliderView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("練習時間: \(duration)分")
                Spacer()
                Text(formattedDuration)
                    .foregroundColor(Color.appPrimary)
                    .fontWeight(.bold)
            }
            
            Slider(value: Binding(
                get: { Double(duration) },
                set: { duration = Int($0) }
            ), in: 15...240, step: 15)
            .accentColor(Color.appPrimary)
        }
        .padding(.vertical, 8)
    }
    
    // 強度選択ビュー
    private var intensitySelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("練習強度")
                .font(.headline)
            
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { i in
                    Button(action: {
                        intensity = i
                    }) {
                        ZStack {
                            Circle()
                                .fill(i <= intensity ? Color.appPrimary : Color.gray.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(i == intensity ? Color.appPrimary : Color.clear, lineWidth: 2)
                                        .padding(-4)
                                )
                            
                            Text("\(i)")
                                .foregroundColor(i <= intensity ? .white : .gray)
                                .fontWeight(.bold)
                        }
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
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
    }
    
    // 保存ボタンの内容
    private var saveButtonContent: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            } else {
                saveButtonLabel
            }
        }
    }
    
    // 保存ボタンのラベル
    private var saveButtonLabel: some View {
        Text("記録を保存")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(.vertical, 15)
            .background(
                saveButtonBackground
            )
            .cornerRadius(12)
            .shadow(
                color: isFormValid ?
                (activityType == .match ? Color.appSecondary.opacity(0.4) : Color.appPrimary.opacity(0.4)) :
                Color.clear,
                radius: 5, x: 0, y: 3
            )
    }
    
    // 保存ボタンの背景
    private var saveButtonBackground: some View {
        Group {
            if isFormValid {
                LinearGradient(
                    gradient: Gradient(colors: [
                        activityType == .match ? Color.appSecondary : Color.appPrimary,
                        activityType == .match ? Color.appSecondary.opacity(0.8) : Color.appPrimary.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                Color.gray
            }
        }
    }
    
    private var isFormValid: Bool {
        if activityType == .match {
            return !location.isEmpty && !opponent.isEmpty && !score.isEmpty
        } else {
            return !location.isEmpty && !focus.isEmpty
        }
    }
    
    private var formattedDuration: String {
        let hours = duration / 60
        let minutes = duration % 60
        
        if hours > 0 {
            return "\(hours)時間\(minutes > 0 ? "\(minutes)分" : "")"
        } else {
            return "\(minutes)分"
        }
    }
    
    private func saveRecord() {
        isLoading = true
        
        // バックグラウンドで保存処理を実行
        DispatchQueue.global(qos: .userInitiated).async {
            let context = PersistenceController.shared.newBackgroundContext()
            
            context.performAndWait {
                // 活動の保存
                let activity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: context)
                activity.setValue(UUID(), forKey: "id")
                activity.setValue(date, forKey: "date")
                activity.setValue(activityType.rawValue, forKey: "type")
                activity.setValue(location, forKey: "location")
                activity.setValue(notes, forKey: "notes")
                activity.setValue(rating, forKey: "rating")
                
                // 活動タイプに応じた詳細情報の保存
                if activityType == .match {
                    let match = NSEntityDescription.insertNewObject(forEntityName: "Match", into: context)
                    match.setValue(UUID(), forKey: "id")
                    match.setValue(opponent, forKey: "opponent")
                    match.setValue(score, forKey: "score")
                    match.setValue(goalsScored, forKey: "goalsScored")
                    match.setValue(assists, forKey: "assists")
                    match.setValue(90, forKey: "playingTime") // デフォルト値
                    match.setValue(rating, forKey: "performance") // 評価と同じ値をデフォルトに
                    match.setValue(activity, forKey: "activity")
                } else {
                    let practice = NSEntityDescription.insertNewObject(forEntityName: "Practice", into: context)
                    practice.setValue(UUID(), forKey: "id")
                    practice.setValue(focus, forKey: "focus")
                    practice.setValue(duration, forKey: "duration")
                    practice.setValue(intensity, forKey: "intensity")
                    practice.setValue(notes, forKey: "learnings")
                    practice.setValue(activity, forKey: "activity")
                }
                
                do {
                    try context.save()
                    
                    // メインスレッドで UI 更新
                    DispatchQueue.main.async {
                        isLoading = false
                        showSuccess = true
                    }
                } catch {
                    print("保存エラー: \(error)")
                    DispatchQueue.main.async {
                        isLoading = false
                    }
                }
            }
        }
    }
}

struct SimpleRecordAddView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleRecordAddView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
