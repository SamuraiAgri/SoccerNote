// SoccerNote/Views/AddRecord/AddRecordView.swift
import SwiftUI
import CoreData

struct AddRecordView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // 事前に選択された日付（オプション）
    var preselectedDate: Date?
    
    // ステップ管理
    @State private var currentStep = 0
    
    // 共通データ
    @State private var selectedType: ActivityType = .match
    @State private var date: Date
    @State private var location = ""
    @State private var notes = ""
    @State private var rating = 3
    
    // 試合データ
    @State private var opponent = ""
    @State private var score = ""
    @State private var goalsScored = 0
    @State private var assists = 0
    
    // 練習データ
    @State private var focus = ""
    @State private var duration = 60
    @State private var intensity = 3
    
    // 保存確認
    @State private var showingConfirmation = false
    
    // ViewModel
    private let activityViewModel: ActivityViewModel
    private let matchViewModel: MatchViewModel
    private let practiceViewModel: PracticeViewModel
    
    init(preselectedDate: Date? = nil) {
        self.preselectedDate = preselectedDate
        
        // 日付の初期値を設定
        self._date = State(initialValue: preselectedDate ?? Date())
        
        // ViewModelの初期化
        let context = PersistenceController.shared.container.viewContext
        self.activityViewModel = ActivityViewModel(viewContext: context)
        self.matchViewModel = MatchViewModel(viewContext: context)
        self.practiceViewModel = PracticeViewModel(viewContext: context)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // ステッププログレスバー
                StepProgressBar(currentStep: currentStep, totalSteps: 3)
                    .padding(.vertical)
                
                // ステップごとの画面
                switch currentStep {
                case 0:
                    // ステップ1: 記録タイプ選択
                    TypeSelectionView(selectedType: $selectedType)
                case 1:
                    // ステップ2: 基本情報入力
                    BasicInfoView(date: $date, location: $location, notes: $notes, rating: $rating)
                case 2:
                    // ステップ3: 詳細情報入力（タイプに応じて変化）
                    if selectedType == .match {
                        MatchDetailsView(
                            opponent: $opponent,
                            score: $score,
                            goalsScored: $goalsScored,
                            assists: $assists
                        )
                    } else {
                        PracticeDetailsView(
                            focus: $focus,
                            duration: $duration,
                            intensity: $intensity
                        )
                    }
                default:
                    EmptyView()
                }
                
                Spacer()
                
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
                            .padding()
                            .foregroundColor(AppDesign.primaryColor)
                        }
                    }
                    
                    Spacer()
                    
                    // 次へ/保存ボタン
                    Button(action: {
                        if currentStep < 2 {
                            withAnimation {
                                currentStep += 1
                            }
                        } else {
                            saveRecord()
                        }
                    }) {
                        HStack {
                            Text(currentStep < 2 ? "次へ" : "保存")
                            Image(systemName: currentStep < 2 ? "chevron.right" : "checkmark")
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(isStepValid ? AppDesign.primaryColor : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!isStepValid)
                }
                .padding()
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingConfirmation) {
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
    
    // 現在のステップのタイトル
    private var stepTitle: String {
        switch currentStep {
        case 0:
            return "記録タイプ選択"
        case 1:
            return "基本情報入力"
        case 2:
            return selectedType == .match ? "試合詳細" : "練習詳細"
        default:
            return "記録追加"
        }
    }
    
    // 現在のステップが有効かどうか
    private var isStepValid: Bool {
        switch currentStep {
        case 0:
            return true  // タイプ選択は常に有効
        case 1:
            return !location.isEmpty  // 場所は必須
        case 2:
            if selectedType == .match {
                return !opponent.isEmpty && !score.isEmpty
            } else {
                return !focus.isEmpty
            }
        default:
            return false
        }
    }
    
    // 記録保存
    private func saveRecord() {
        // 活動記録の保存
        guard let activity = activityViewModel.saveActivity(
            type: selectedType,
            date: date,
            location: location,
            notes: notes,
            rating: rating
        ) else {
            return
        }
        
        // 詳細情報の保存
        if selectedType == .match {
            // 試合詳細の保存（シンプル化）
            matchViewModel.saveMatch(
                activity: activity,
                opponent: opponent,
                score: score,
                goalsScored: goalsScored,
                assists: assists,
                playingTime: 90, // デフォルト値
                performance: 5,  // デフォルト値
                photos: nil
            )
        } else {
            // 練習詳細の保存（シンプル化）
            practiceViewModel.savePractice(
                activity: activity,
                focus: focus,
                duration: duration,
                intensity: intensity,
                learnings: ""  // デフォルト値
            )
        }
        
        // 保存確認アラート
        showingConfirmation = true
    }
}

// ステッププログレスバー
struct StepProgressBar: View {
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

// ステップ1: タイプ選択ビュー
struct TypeSelectionView: View {
    @Binding var selectedType: ActivityType
    
    var body: some View {
        VStack(spacing: 20) {
            Text("記録タイプを選択してください")
                .font(.headline)
                .padding(.bottom)
            
            // 試合選択ボタン
            Button(action: {
                selectedType = .match
            }) {
                HStack {
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 24))
                        .frame(width: 40)
                    
                    VStack(alignment: .leading) {
                        Text("試合")
                            .font(.headline)
                        
                        Text("対戦相手、スコア、得点などを記録")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if selectedType == .match {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppDesign.primaryColor)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedType == .match ? AppDesign.primaryColor : Color.gray.opacity(0.3), lineWidth: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // 練習選択ボタン
            Button(action: {
                selectedType = .practice
            }) {
                HStack {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 24))
                        .frame(width: 40)
                    
                    VStack(alignment: .leading) {
                        Text("練習")
                            .font(.headline)
                        
                        Text("練習内容、時間、強度などを記録")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if selectedType == .practice {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppDesign.primaryColor)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedType == .practice ? AppDesign.primaryColor : Color.gray.opacity(0.3), lineWidth: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
    }
}

// ステップ2: 基本情報入力ビュー
struct BasicInfoView: View {
    @Binding var date: Date
    @Binding var location: String
    @Binding var notes: String
    @Binding var rating: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 日付選択
                VStack(alignment: .leading) {
                    Text("日付")
                        .font(.headline)
                    
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        .padding(.vertical, 8)
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
                
                // メモ入力
                VStack(alignment: .leading) {
                    Text("メモ (任意)")
                        .font(.headline)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $notes)
                            .padding(4)
                            .frame(height: 100)
                        
                        if notes.isEmpty {
                            Text("メモを入力")
                                .foregroundColor(Color.gray.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.top, 8)
                        }
                    }
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
                                    rating = star
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding()
        }
    }
}

// ステップ3A: 試合詳細入力ビュー
struct MatchDetailsView: View {
    @Binding var opponent: String
    @Binding var score: String
    @Binding var goalsScored: Int
    @Binding var assists: Int
    
    var body: some View {
        ScrollView {
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
            .padding()
        }
    }
}

// ステップ3B: 練習詳細入力ビュー
struct PracticeDetailsView: View {
    @Binding var focus: String
    @Binding var duration: Int
    @Binding var intensity: Int
    
    var body: some View {
        ScrollView {
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
                    Text("練習時間")
                        .font(.headline)
                    
                    HStack {
                        Slider(value: Binding(
                            get: { Double(duration) },
                            set: { duration = Int($0) }
                        ), in: 15...180, step: 15)
                        .accentColor(AppDesign.primaryColor)
                        
                        Text("\(duration)分")
                            .frame(width: 60)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
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
                .padding()
            }
        }
    }
}
