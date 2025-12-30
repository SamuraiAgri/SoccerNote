// SoccerNote/Views/AddRecord/QuickActivityAddView.swift
import SwiftUI
import CoreData

struct QuickActivityAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var activityViewModel: ActivityViewModel
    @StateObject private var reflectionViewModel: ReflectionViewModel
    
    // 活動タイプ
    @State private var selectedType = "練習"
    @State private var date = Date()
    @State private var location = ""
    @State private var rating = 3
    
    // 試合情報（簡略化）
    @State private var opponent = ""
    @State private var score = ""
    
    // 練習情報（簡略化）
    @State private var focus = ""
    @State private var duration = 60
    
    // 振り返り（簡易版）
    @State private var quickNote = ""
    @State private var addReflection = false
    
    // UI状態
    @State private var toast: ToastData?
    @State private var showingSuccess = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(viewContext: context))
        _reflectionViewModel = StateObject(wrappedValue: ReflectionViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // タイプ選択（大きなボタン）
                    typeSelectionSection
                    
                    // 基本情報
                    basicInfoSection
                    
                    // タイプ別情報
                    if selectedType == "試合" {
                        matchInfoSection
                    } else {
                        practiceInfoSection
                    }
                    
                    // 簡易振り返り
                    quickReflectionSection
                    
                    // 保存ボタン
                    saveButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(selectedType == "試合" ? "試合を記録" : "練習を記録")
            .navigationBarTitleDisplayMode(.inline)
            .toast($toast)
            .overlay(
                Group {
                    if showingSuccess {
                        successOverlay
                    }
                }
            )
        }
    }
    
    // MARK: - Sections
    
    private var typeSelectionSection: some View {
        HStack(spacing: 12) {
            TypeButton(
                title: "練習",
                icon: "figure.run",
                color: .green,
                isSelected: selectedType == "練習"
            ) {
                HapticFeedback.selection()
                selectedType = "練習"
            }
            
            TypeButton(
                title: "試合",
                icon: "sportscourt.fill",
                color: .orange,
                isSelected: selectedType == "試合"
            ) {
                HapticFeedback.selection()
                selectedType = "試合"
            }
        }
    }
    
    private var basicInfoSection: some View {
        VStack(spacing: 16) {
            // 日付
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                DatePicker("", selection: $date, displayedComponents: [.date])
                    .labelsHidden()
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // 場所
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                TextField("場所（例：学校グラウンド）", text: $location)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // 評価（シンプルな星）
            VStack(alignment: .leading, spacing: 8) {
                Text("今日の出来は？")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.title)
                            .foregroundColor(index <= rating ? .yellow : .gray.opacity(0.4))
                            .onTapGesture {
                                HapticFeedback.selection()
                                withAnimation(.spring(response: 0.2)) {
                                    rating = index
                                }
                            }
                    }
                    
                    Spacer()
                    
                    Text(ratingText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private var matchInfoSection: some View {
        VStack(spacing: 16) {
            // 対戦相手
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                TextField("対戦相手", text: $opponent)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // スコア
            HStack {
                Image(systemName: "number")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                TextField("スコア（例：2-1）", text: $score)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private var practiceInfoSection: some View {
        VStack(spacing: 16) {
            // 練習内容
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                TextField("練習内容（例：シュート練習）", text: $focus)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // 時間
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                Text("練習時間")
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Picker("", selection: $duration) {
                    Text("30分").tag(30)
                    Text("60分").tag(60)
                    Text("90分").tag(90)
                    Text("120分").tag(120)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private var quickReflectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(AppDesign.primaryColor)
                Text("ひとこと振り返り")
                    .font(.headline)
            }
            
            TextEditor(text: $quickNote)
                .frame(minHeight: 80)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    Group {
                        if quickNote.isEmpty {
                            Text("今日の良かったこと、課題などを書こう")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
            
            // 詳細な振り返りへの誘導
            Button(action: {
                // 保存してから振り返り画面へ
                addReflection = true
                saveActivity()
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle")
                    Text("詳しく振り返りを書く")
                        .font(.subheadline)
                }
                .foregroundColor(AppDesign.primaryColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var saveButton: some View {
        Button(action: {
            saveActivity()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("記録を保存")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppDesign.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("記録しました！")
                    .font(.title3)
                    .fontWeight(.bold)
                
                if addReflection {
                    Text("続けて振り返りを書きましょう")
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    showingSuccess = false
                    if addReflection {
                        // 振り返り画面を表示（親ビューで処理）
                    }
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
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
    
    // MARK: - Helpers
    
    private var ratingText: String {
        switch rating {
        case 1: return "改善が必要"
        case 2: return "まあまあ"
        case 3: return "普通"
        case 4: return "良かった"
        case 5: return "最高！"
        default: return ""
        }
    }
    
    private func saveActivity() {
        let type = selectedType == "試合" ? ActivityType.match : ActivityType.practice
        
        guard let activity = activityViewModel.saveActivity(
            type: type,
            date: date,
            location: location.isEmpty ? "未設定" : location,
            notes: quickNote,
            rating: rating
        ) else {
            toast = ToastData(type: .error, message: "保存に失敗しました")
            return
        }
        
        // タイプ別の追加情報を保存
        if selectedType == "試合" {
            saveMatchDetails(for: activity)
        } else {
            savePracticeDetails(for: activity)
        }
        
        HapticFeedback.success()
        showingSuccess = true
        
        // フォームをリセット
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if !addReflection {
                resetForm()
            }
            showingSuccess = false
        }
    }
    
    private func saveMatchDetails(for activity: NSManagedObject) {
        let backgroundContext = PersistenceController.shared.newBackgroundContext()
        
        backgroundContext.performAndWait {
            let bgActivity = backgroundContext.object(with: activity.objectID)
            let match = NSEntityDescription.insertNewObject(forEntityName: "Match", into: backgroundContext)
            
            match.setValue(UUID(), forKey: "id")
            match.setValue(opponent, forKey: "opponent")
            match.setValue(score, forKey: "score")
            match.setValue(0, forKey: "goalsScored")
            match.setValue(0, forKey: "assists")
            match.setValue(rating, forKey: "performance")
            match.setValue(bgActivity, forKey: "activity")
            
            try? backgroundContext.save()
        }
    }
    
    private func savePracticeDetails(for activity: NSManagedObject) {
        let backgroundContext = PersistenceController.shared.newBackgroundContext()
        
        backgroundContext.performAndWait {
            let bgActivity = backgroundContext.object(with: activity.objectID)
            let practice = NSEntityDescription.insertNewObject(forEntityName: "Practice", into: backgroundContext)
            
            practice.setValue(UUID(), forKey: "id")
            practice.setValue(focus, forKey: "focus")
            practice.setValue(duration, forKey: "duration")
            practice.setValue(rating, forKey: "intensity")
            practice.setValue(quickNote, forKey: "learnings")
            practice.setValue(bgActivity, forKey: "activity")
            
            try? backgroundContext.save()
        }
    }
    
    private func resetForm() {
        location = ""
        opponent = ""
        score = ""
        focus = ""
        quickNote = ""
        rating = 3
        duration = 60
        date = Date()
    }
}

// MARK: - Supporting Views

struct TypeButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? color.opacity(0.15) : Color(.systemBackground))
            .foregroundColor(isSelected ? color : .secondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    QuickActivityAddView()
}
