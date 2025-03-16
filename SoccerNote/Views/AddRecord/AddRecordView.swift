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
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 記録タイプ選択
                    VStack(alignment: .leading) {
                        Text("記録タイプ")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Picker("タイプ", selection: $selectedType) {
                            ForEach(ActivityType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(AppDesign.CornerRadius.medium)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // 基本情報
                    VStack(alignment: .leading, spacing: 15) {
                        Text("基本情報")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        HStack {
                            Text("日時")
                                .frame(width: 80, alignment: .leading)
                            
                            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                        }
                        
                        HStack {
                            Text("場所")
                                .frame(width: 80, alignment: .leading)
                            
                            TextField("場所を入力", text: $location)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("メモ")
                            
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        HStack {
                            Text("評価")
                                .frame(width: 80, alignment: .leading)
                            
                            StarRatingPicker(rating: $rating)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(AppDesign.CornerRadius.medium)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // 詳細情報（試合または練習）
                    if selectedType == .match {
                        // 試合詳細
                        VStack(alignment: .leading, spacing: 15) {
                            Text("試合詳細")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            HStack {
                                Text("対戦相手")
                                    .frame(width: 80, alignment: .leading)
                                
                                TextField("チーム名", text: $opponent)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            HStack {
                                Text("スコア")
                                    .frame(width: 80, alignment: .leading)
                                
                                TextField("例: 2-1", text: $score)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            HStack {
                                Text("ゴール")
                                    .frame(width: 80, alignment: .leading)
                                
                                Spacer()
                                
                                HStack {
                                    Button(action: {
                                        if goalsScored > 0 {
                                            goalsScored -= 1
                                        }
                                    }) {
                                        Text("-")
                                            .frame(width: 40, height: 40)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(5)
                                    }
                                    
                                    Text("\(goalsScored)")
                                        .frame(width: 40, alignment: .center)
                                    
                                    Button(action: {
                                        goalsScored += 1
                                    }) {
                                        Text("+")
                                            .frame(width: 40, height: 40)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(5)
                                    }
                                }
                            }
                            
                            // 以下同様にアシスト、出場時間などのUI
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(AppDesign.CornerRadius.medium)
                        .padding(.horizontal)
                        .padding(.top)
                    } else {
                        // 練習詳細UI
                    }
                    
                    // 保存ボタン
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
                    .padding()
                    .padding(.bottom, 50)  // タブバーの高さ分余白を取る
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("記録追加")
            .navigationBarTitleDisplayMode(.inline)
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
