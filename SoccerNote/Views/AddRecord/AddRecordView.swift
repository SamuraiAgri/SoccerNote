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
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
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
            ZStack {
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
                            .onTapGesture {
                                // キーボードを閉じる
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    case 2:
                        // ステップ3: 詳細情報入力（タイプに応じて変化）
                        if selectedType == .match {
                            MatchDetailsView(
                                opponent: $opponent,
                                score: $score,
                                goalsScored: $goalsScored,
                                assists: $assists
                            )
                            .onTapGesture {
                                // キーボードを閉じる
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        } else {
                            PracticeDetailsView(
                                focus: $focus,
                                duration: $duration,
                                intensity: $intensity
                            )
                            .onTapGesture {
                                // キーボードを閉じる
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
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
                            .disabled(isLoading)
                        }
                        
                        Spacer()
                        
                        // 次へ/保存ボタン
                        Button(action: {
                            if currentStep < 2 {
                                withAnimation {
                                    validateCurrentStep()
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
                        .disabled(!isStepValid || isLoading)
                    }
                    .padding()
                }
                .navigationTitle(stepTitle)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()
                })
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("入力エラー"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .sheet(isPresented: $showingConfirmation) {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("保存完了")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("記録が保存されました")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingConfirmation = false
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("OK")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppDesign.primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                    .frame(width: 300, height: 250)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
                
                // ローディングオーバーレイ
                if isLoading {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    LoadingView()
                }
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
            // 入力検証の強化（空白スペースだけの入力も無効に）
            return ValidationRules.validateLocationInput(location)
        case 2:
            if selectedType == .match {
                return ValidationRules.validateOpponentInput(opponent) &&
                       ValidationRules.validateScoreInput(score)
            } else {
                return ValidationRules.validateFocusInput(focus)
            }
        default:
            return false
        }
    }
    
    // 現在のステップの検証
    private func validateCurrentStep() {
        switch currentStep {
        case 0:
            // タイプ選択は常に有効なので次のステップへ
            currentStep += 1
        case 1:
            if ValidationRules.validateLocationInput(location) {
                currentStep += 1
            } else {
                alertMessage = "場所は必須項目です。"
                showingAlert = true
            }
        case 2:
            // 最後のステップの検証は保存時に行う
            break
        default:
            break
        }
    }
    
    // 記録保存
    private func saveRecord() {
        // 入力検証（再チェック）
        guard isStepValid else {
            alertMessage = "必須項目を入力してください。"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        // 活動記録の保存
        guard let activity = activityViewModel.saveActivity(
            type: selectedType,
            date: date,
            location: location,
            notes: notes,
            rating: rating
        ) else {
            isLoading = false
            if let errorMessage = activityViewModel.errorMessage {
                alertMessage = errorMessage
                showingAlert = true
            }
            return
        }
        
        // 詳細情報の保存
        if selectedType == .match {
            // 試合詳細の保存
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
            
            if let errorMessage = matchViewModel.errorMessage {
                isLoading = false
                alertMessage = errorMessage
                showingAlert = true
                return
            }
        } else {
            // 練習詳細の保存
            practiceViewModel.savePractice(
                activity: activity,
                focus: focus,
                duration: duration,
                intensity: intensity,
                learnings: ""  // デフォルト値
            )
            
            if let errorMessage = practiceViewModel.errorMessage {
                isLoading = false
                alertMessage = errorMessage
                showingAlert = true
                return
            }
        }
        
        isLoading = false
        // 保存確認シート
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
                DatePickerField(date: $date, label: "日付")
                
                // 場所入力
                VStack(alignment: .leading) {
                    Text("場所")
                        .font(.headline)
                    
                    TextField("場所を入力", text: $location)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .onChange(of: location) { _, newValue in
                            // 入力文字数制限
                            if newValue.count > ValidationRules.maxLocationLength {
                                location = String(newValue.prefix(ValidationRules.maxLocationLength))
                            }
                        }
                }
                
                // メモ入力
                VStack(alignment: .leading) {
                    Text("メモ (任意)")
                        .font(.headline)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $notes)
                            .padding(4)
                            .frame(height: 100)
                            .onChange(of: notes) { _, newValue in
                                // 入力文字数制限
                                if newValue.count > ValidationRules.maxNotesLength {
                                    notes = String(newValue.prefix(ValidationRules.maxNotesLength))
                                }
                            }
                        
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
                        .onChange(of: opponent) { _, newValue in
                            // 入力文字数制限
                            if newValue.count > ValidationRules.maxOpponentLength {
                                opponent = String(newValue.prefix(ValidationRules.maxOpponentLength))
                            }
                        }
                }
                
                // スコア
                VStack(alignment: .leading) {
                    Text("スコア")
                        .font(.headline)
                    
                    TextField("例: 2-1", text: $score)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .onChange(of: score) { _, newValue in
                            // 入力文字数制限
                            if newValue.count > ValidationRules.maxScoreLength {
                                score = String(newValue.prefix(ValidationRules.maxScoreLength))
                            }
                        }
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
                            if goalsScored < ValidationRules.goalsRange.upperBound {
                                goalsScored += 1
                            }
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
                            if assists < ValidationRules.assistsRange.upperBound {
                                assists += 1
                            }
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
                        .onChange(of: focus) { _, newValue in
                            // 入力文字数制限
                            if newValue.count > ValidationRules.maxFocusLength {
                                focus = String(newValue.prefix(ValidationRules.maxFocusLength))
                            }
                        }
                }
                
                // 練習時間
                VStack(alignment: .leading) {
                    Text("練習時間")
                        .font(.headline)
                    
                    HStack {
                        Slider(value: Binding(
                            get: { Double(duration) },
                            set: { duration = Int($0) }
                        ), in: Double(ValidationRules.durationRange.lowerBound)...Double(ValidationRules.durationRange.upperBound), step: 15)
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
                        .font(.head
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
