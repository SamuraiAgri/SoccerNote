// SoccerNote/Views/Goals/GoalsView.swift
import SwiftUI
import CoreData

struct GoalsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var goalViewModel: GoalViewModel
    
    @State private var showingAddGoalSheet = false
    @State private var selectedGoalSort: GoalSortOption = .deadline
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _goalViewModel = StateObject(wrappedValue: GoalViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ソートオプション
                HStack {
                    Text("並び替え")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: $selectedGoalSort) {
                        ForEach(GoalSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Spacer()
                }
                .padding()
                
                // 目標リスト
                if goalViewModel.goals.isEmpty {
                    // 目標がない場合の表示
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "flag")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("目標が設定されていません")
                            .font(.headline)
                        
                        Text("目標を設定して、パフォーマンス向上に役立てましょう")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingAddGoalSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("目標を追加")
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(AppDesign.primaryColor)
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    // 目標リスト表示
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(sortedGoals, id: \.self) { goal in
                                NavigationLink(destination: SimplifiedGoalDetailView(goal: goal, goalViewModel: goalViewModel)) {
                                    SimplifiedGoalCard(goal: goal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("目標管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGoalSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoalSheet) {
                SimplifiedAddGoalView(goalViewModel: goalViewModel)
            }
            .onAppear {
                goalViewModel.fetchGoals()
            }
        }
    }
    
    // ソート済み目標リスト
    private var sortedGoals: [NSManagedObject] {
        switch selectedGoalSort {
        case .deadline:
            // 期限でソート
            return goalViewModel.goals.sorted { first, second in
                guard let firstDate = first.value(forKey: "deadline") as? Date,
                      let secondDate = second.value(forKey: "deadline") as? Date else {
                    return false
                }
                return firstDate < secondDate
            }
        case .progress:
            // 進捗率でソート
            return goalViewModel.goals.sorted { first, second in
                guard let firstProgress = first.value(forKey: "progress") as? Int,
                      let secondProgress = second.value(forKey: "progress") as? Int else {
                    return false
                }
                return firstProgress > secondProgress
            }
        case .creation:
            // 作成順でソート
            return goalViewModel.goals.sorted { first, second in
                guard let firstDate = first.value(forKey: "creationDate") as? Date,
                      let secondDate = second.value(forKey: "creationDate") as? Date else {
                    return false
                }
                return firstDate > secondDate
            }
        }
    }
}

// 目標ソートオプション
enum GoalSortOption: String, CaseIterable, Identifiable {
    case deadline = "期限順"
    case progress = "進捗順"
    case creation = "作成順"
    
    var id: String { self.rawValue }
}

// シンプル化された目標カード
struct SimplifiedGoalCard: View {
    let goal: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 目標タイトルと進捗ステータス
            HStack {
                Text(goal.value(forKey: "title") as? String ?? "")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                // 完了/進行中アイコン
                if goal.value(forKey: "isCompleted") as? Bool ?? false {
                    Label("達成", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Label("進行中", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            // 期限表示
            if let deadline = goal.value(forKey: "deadline") as? Date {
                Text("期限: \(formattedDate(deadline))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 進捗バー
            VStack(alignment: .leading, spacing: 4) {
                let progress = Double(goal.value(forKey: "progress") as? Int ?? 0) / 100.0
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor(progress)))
                
                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(progressColor(progress))
                    
                    Spacer()
                    
                    // 残り日数表示
                    if let daysRemaining = daysRemaining, !isCompleted {
                        Text("残り\(daysRemaining)日")
                            .font(.caption)
                            .foregroundColor(daysRemaining < 7 ? .red : .secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 進捗に応じた色
    private func progressColor(_ progress: Double) -> Color {
        if progress < 0.3 {
            return .red
        } else if progress < 0.7 {
            return .orange
        } else {
            return .green
        }
    }
    
    // 日付フォーマット
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 残り日数計算
    private var daysRemaining: Int? {
        guard let deadline = goal.value(forKey: "deadline") as? Date else {
            return nil
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadlineDay = calendar.startOfDay(for: deadline)
        
        return calendar.dateComponents([.day], from: today, to: deadlineDay).day
    }
    
    // 完了フラグ
    private var isCompleted: Bool {
        return goal.value(forKey: "isCompleted") as? Bool ?? false
    }
}

// シンプル化した目標詳細画面
struct SimplifiedGoalDetailView: View {
    let goal: NSManagedObject
    let goalViewModel: GoalViewModel
    
    @State private var isEditing = false
    @State private var progress: Double
    @State private var isCompleted: Bool
    @State private var showingDeleteConfirmation = false
    
    init(goal: NSManagedObject, goalViewModel: GoalViewModel) {
        self.goal = goal
        self.goalViewModel = goalViewModel
        self._progress = State(initialValue: Double(goal.value(forKey: "progress") as? Int ?? 0) / 100.0)
        self._isCompleted = State(initialValue: goal.value(forKey: "isCompleted") as? Bool ?? false)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 基本情報
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.value(forKey: "title") as? String ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let deadline = goal.value(forKey: "deadline") as? Date {
                        Text("期限: \(formattedDate(deadline))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let creationDate = goal.value(forKey: "creationDate") as? Date {
                        Text("作成日: \(formattedDate(creationDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // 進捗管理
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("進捗状況")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            isEditing.toggle()
                        }) {
                            Text(isEditing ? "完了" : "編集")
                                .font(.subheadline)
                                .foregroundColor(AppDesign.primaryColor)
                        }
                    }
                    
                    if isEditing {
                        // 編集モード
                        VStack {
                            Slider(value: $progress)
                                .accentColor(progressColor(progress))
                            
                            HStack {
                                Text("0%")
                                Spacer()
                                Text("50%")
                                Spacer()
                                Text("100%")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Toggle("目標達成", isOn: $isCompleted)
                                .padding(.top, 8)
                            
                            Button(action: {
                                updateProgress()
                            }) {
                                Text("更新")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppDesign.primaryColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        // 表示モード
                        VStack(spacing: 8) {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: progressColor(progress)))
                            
                            HStack {
                                Text("\(Int(progress * 100))%")
                                    .font(.headline)
                                    .foregroundColor(progressColor(progress))
                                
                                Spacer()
                                
                                if isCompleted {
                                    Label("達成済み", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else if let daysRemaining = daysRemaining {
                                    Label("残り\(daysRemaining)日", systemImage: "clock")
                                        .foregroundColor(daysRemaining < 7 ? .red : .blue)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // 目標詳細
                VStack(alignment: .leading, spacing: 8) {
                    Text("詳細")
                        .font(.headline)
                    
                    Text(goal.value(forKey: "goalDescription") as? String ?? "")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // 削除ボタン
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Label("目標を削除", systemImage: "trash")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                .padding(.top, 16)
            }
            .padding()
        }
        .navigationTitle("目標詳細")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingDeleteConfirmation) {
            Alert(
                title: Text("目標を削除"),
                message: Text("この目標を削除してもよろしいですか？"),
                primaryButton: .destructive(Text("削除")) {
                    goalViewModel.deleteGoal(goal)
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
    }
    
    // 進捗更新
    private func updateProgress() {
        let progressValue = Int(progress * 100)
        goalViewModel.updateGoalProgress(goal, progress: progressValue, isCompleted: isCompleted)
        isEditing = false
    }
    
    // 進捗に応じた色
    private func progressColor(_ progress: Double) -> Color {
        if progress < 0.3 {
            return .red
        } else if progress < 0.7 {
            return .orange
        } else {
            return .green
        }
    }
    
    // 日付フォーマット
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 残り日数計算
    private var daysRemaining: Int? {
        guard let deadline = goal.value(forKey: "deadline") as? Date else {
            return nil
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadlineDay = calendar.startOfDay(for: deadline)
        
        return calendar.dateComponents([.day], from: today, to: deadlineDay).day
    }
}

// シンプル化した目標追加画面
struct SimplifiedAddGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    let goalViewModel: GoalViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var deadline = Date().addingTimeInterval(60*60*24*30) // 30日後
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("目標情報")) {
                    TextField("目標タイトル", text: $title)
                    
                    VStack(alignment: .leading) {
                        Text("詳細説明")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    DatePicker("達成期限", selection: $deadline, displayedComponents: .date)
                }
                
                Section {
                    Button(action: saveGoal) {
                        Text("目標を保存")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(title.isEmpty ? Color.gray : AppDesign.primaryColor)
                            .cornerRadius(10)
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("目標追加")
            .navigationBarItems(trailing: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // 目標保存
    private func saveGoal() {
        goalViewModel.saveGoal(
            title: title,
            description: description,
            deadline: deadline
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

// プレビュー
#Preview {
    GoalsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
