// SoccerNote/Views/AddRecord/AddRecordView.swift
import SwiftUI
import CoreData

struct AddRecordView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var activityViewModel: ActivityViewModel
    
    @State private var selectedType: ActivityType = .match
    @State private var date = Date()
    @State private var location = ""
    @State private var notes = ""
    @State private var rating = 3
    
    // 試合用
    @State private var opponent = ""
    @State private var score = ""
    @State private var goalsScored = 0
    @State private var assists = 0
    @State private var playingTime = 90
    @State private var performance = 5
    
    // 練習用
    @State private var focus = ""
    @State private var duration = 60
    @State private var intensity = 3
    @State private var learnings = ""
    
    @State private var showingConfirmation = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 記録タイプ選択
                Section(header: Text("記録タイプ")) {
                    Picker("タイプ", selection: $selectedType) {
                        ForEach(ActivityType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 基本情報
                Section(header: Text("基本情報")) {
                    DatePicker("日時", selection: $date)
                    
                    TextField("場所", text: $location)
                    
                    TextField("メモ", text: $notes)
                        .frame(height: 100)
                    
                    HStack {
                        Text("評価")
                        Spacer()
                        StarRatingPicker(rating: $rating)
                    }
                }
                
                // 詳細情報（試合または練習）
                if selectedType == .match {
                    // 試合詳細
                    Section(header: Text("試合詳細")) {
                        TextField("対戦相手", text: $opponent)
                        
                        TextField("スコア (例: 2-1)", text: $score)
                        
                        Stepper("ゴール: \(goalsScored)", value: $goalsScored, in: 0...20)
                        
                        Stepper("アシスト: \(assists)", value: $assists, in: 0...20)
                        
                        Stepper("出場時間: \(playingTime)分", value: $playingTime, in: 0...120, step: 5)
                        
                        HStack {
                            Text("パフォーマンス評価")
                            Spacer()
                            Picker("", selection: $performance) {
                                ForEach(1...10, id: \.self) { rating in
                                    Text("\(rating)").tag(rating)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 50)
                        }
                    }
                } else {
                    // 練習詳細
                    Section(header: Text("練習詳細")) {
                        TextField("フォーカスエリア", text: $focus)
                        
                        Stepper("練習時間: \(duration)分", value: $duration, in: 0...300, step: 15)
                        
                        HStack {
                            Text("練習強度")
                            Spacer()
                            Picker("", selection: $intensity) {
                                ForEach(1...5, id: \.self) { intensity in
                                    Text("\(intensity)").tag(intensity)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        TextField("学んだこと", text: $learnings)
                            .frame(height: 100)
                    }
                }
                
                // 保存ボタン
                Section {
                    Button(action: {
                        saveRecord()
                    }) {
                        Text("記録を保存")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(AppDesign.primaryColor)
                            .cornerRadius(AppDesign.CornerRadius.medium)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("記録追加")
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text("保存完了"),
                    message: Text("記録が保存されました"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // バリデーション
    private var isFormValid: Bool {
        if location.isEmpty {
            return false
        }
        
        if selectedType == .match {
            return !opponent.isEmpty && !score.isEmpty
        } else {
            return !focus.isEmpty
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
            // 試合詳細の保存
            let matchViewModel = MatchViewModel(viewContext: viewContext)
            matchViewModel.saveMatch(
                activity: activity,
                opponent: opponent,
                score: score,
                goalsScored: goalsScored,
                assists: assists,
                playingTime: playingTime,
                performance: performance
            )
        } else {
            // 練習詳細の保存
            let practiceViewModel = PracticeViewModel(viewContext: viewContext)
            practiceViewModel.savePractice(
                activity: activity,
                focus: focus,
                duration: duration,
                intensity: intensity,
                learnings: learnings
            )
        }
        
        // フォームリセット
        resetForm()
        
        // 保存確認アラート
        showingConfirmation = true
    }
    
    // フォームリセット
    private func resetForm() {
        date = Date()
        location = ""
        notes = ""
        rating = 3
        
        opponent = ""
        score = ""
        goalsScored = 0
        assists = 0
        playingTime = 90
        performance = 5
        
        focus = ""
        duration = 60
        intensity = 3
        learnings = ""
    }
}
