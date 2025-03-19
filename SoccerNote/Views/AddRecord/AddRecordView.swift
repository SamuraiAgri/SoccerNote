// SoccerNote/Views/AddRecord/AddRecordView.swift
// 記録追加のコンポーネント
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
