// SoccerNote/Views/Goals/GoalsView.swift
import SwiftUI
import CoreData

struct GoalsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var goalViewModel: GoalViewModel
    
    @State private var showingAddGoalSheet = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _goalViewModel = StateObject(wrappedValue: GoalViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            List {
                // アクティブな目標
                Section(header: Text("進行中の目標")) {
                    if activeGoals.isEmpty {
                        Text("進行中の目標はありません")
                            .foregroundColor(AppDesign.secondaryText)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(activeGoals, id: \.self) { goal in
                            NavigationLink(destination: GoalDetailView(goal: goal, goalViewModel: goalViewModel)) {
                                GoalRow(goal: goal)
                            }
                        }
                        .onDelete(perform: deleteActiveGoal)
                    }
                }
                
                // 達成済みの目標
                Section(header: Text("達成済みの目標")) {
                    if completedGoals.isEmpty {
                        Text("達成済みの目標はありません")
                            .foregroundColor(AppDesign.secondaryText)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(completedGoals, id: \.self) { goal in
                            NavigationLink(destination: GoalDetailView(goal: goal, goalViewModel: goalViewModel)) {
                                GoalRow(goal: goal)
                            }
                        }
                        .onDelete(perform: deleteCompletedGoal)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("目標")
            .navigationBarItems(trailing: Button(action: {
                showingAddGoalSheet = true
            }) {
                Image(systemName: AppIcons.Function.add)
            })
            .sheet(isPresented: $showingAddGoalSheet) {
                AddGoalView(goalViewModel: goalViewModel)
            }
            .onAppear {
                goalViewModel.fetchGoals()
            }
        }
    }
    
    // アクティブな目標
    private var activeGoals: [NSManagedObject] {
        goalViewModel.goals.filter { goal in
            let isCompleted = goal.value(forKey: "isCompleted") as? Bool ?? false
            return !isCompleted
        }
    }
    
    // 達成済みの目標
    private var completedGoals: [NSManagedObject] {
        goalViewModel.goals.filter { goal in
            let isCompleted = goal.value(forKey: "isCompleted") as? Bool ?? false
            return isCompleted
        }
    }
    
    // アクティブな目標削除
    private func deleteActiveGoal(at offsets: IndexSet) {
        for index in offsets {
            let goal = activeGoals[index]
            goalViewModel.deleteGoal(goal)
        }
    }
    
    // 達成済み目標削除
    private func deleteCompletedGoal(at offsets: IndexSet) {
        for index in offsets {
            let goal = completedGoals[index]
            goalViewModel.deleteGoal(goal)
        }
    }
}

// SoccerNote/Views/Goals/GoalRow.swift
import SwiftUI
import CoreData

struct GoalRow: View {
    let goal: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(goal.value(forKey: "title") as? String ?? "")
                    .font(.headline)
                
                Spacer()
                
                Text(progressText)
                    .font(.caption)
                    .foregroundColor(progressColor)
            }
            
            Text(formattedDeadline)
                .font(.caption)
                .foregroundColor(AppDesign.secondaryText)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
        }
    }
    
    // ヘルパープロパティ
    private var progress: Double {
        Double(goal.value(forKey: "progress") as? Int ?? 0) / 100.0
    }
    
    private var progressText: String {
        "\(Int(progress * 100))%"
    }
    
    private var progressColor: Color {
        if progress < 0.3 {
            return .red
        } else if progress < 0.7 {
            return AppDesign.accentColor
        } else {
            return AppDesign.primaryColor
        }
    }
    
    private var formattedDeadline: String {
        let deadline = goal.value(forKey: "deadline") as? Date ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return "期限: \(formatter.string(from: deadline))"
    }
}

// SoccerNote/Views/Goals/AddGoalView.swift
import SwiftUI
import CoreData

struct AddGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    let goalViewModel: GoalViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var deadline = Date().addingTimeInterval(60*60*24*30) // 30日後
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("目標情報")) {
                    TextField("タイトル", text: $title)
                    
                    TextField("詳細", text: $description)
                        .frame(height: 100)
                    
                    DatePicker("期限", selection: $deadline, displayedComponents: .date)
                }
                
                Section {
                    Button(action: saveGoal) {
                        Text("目標を保存")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(AppDesign.primaryColor)
                            .cornerRadius(AppDesign.CornerRadius.medium)
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

// SoccerNote/Views/Goals/GoalDetailView.swift
import SwiftUI
import CoreData

struct GoalDetailView: View {
    let goal: NSManagedObject
    let goalViewModel: GoalViewModel
    
    @State private var isEditing = false
    @State private var progress: Double
    @State private var isCompleted: Bool
    
    init(goal: NSManagedObject, goalViewModel: GoalViewModel) {
        self.goal = goal
        self.goalViewModel = goalViewModel
        self._progress = State(initialValue: Double(goal.value(forKey: "progress") as? Int ?? 0) / 100.0)
        self._isCompleted = State(initialValue: goal.value(forKey: "isCompleted") as? Bool ?? false)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // 基本情報
                VStack(alignment: .leading, spacing: 5) {
                    Text(goal.value(forKey: "title") as? String ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(formattedDeadline)
                        .font(.subheadline)
                        .foregroundColor(AppDesign.secondaryText)
                    
                    if let creationDate = goal.value(forKey: "creationDate") as? Date {
                        Text("作成日: \(formattedDate(creationDate))")
                            .font(.caption)
                            .foregroundColor(AppDesign.secondaryText)
                    }
                }
                
                Divider()
                
                // 進捗状況
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("進捗状況")
                            .font(.headline)
                        
                        Spacer()
                        
                        if isEditing {
                            Button("完了") {
                                updateProgress()
                                isEditing = false
                            }
                            .foregroundColor(AppDesign.primaryColor)
                        } else {
                            Button("編集") {
                                isEditing = true
                            }
                        }
                    }
                    
                    if isEditing {
                        VStack {
                            Slider(value: $progress)
                                .accentColor(AppDesign.primaryColor)
                            
                            HStack {
                                Text("0%")
                                Spacer()
                                Text("50%")
                                Spacer()
                                Text("100%")
                            }
                            .font(.caption)
                            .foregroundColor(AppDesign.secondaryText)
                            
                            Toggle("目標達成", isOn: $isCompleted)
                                .toggleStyle(SwitchToggleStyle(tint: AppDesign.primaryColor))
                        }
                    } else {
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                        
                        HStack {
                            Text("\(Int(progress * 100))%")
                                .font(.headline)
                                .foregroundColor(progressColor)
                            
                            Spacer()
                            
                            if isCompleted {
                                Label("達成済み", systemImage: AppIcons.Status.checkmark)
                                    .foregroundColor(AppDesign.primaryColor)
                            } else {
                                Label("進行中", systemImage: AppIcons.Status.clock)
                                    .foregroundColor(AppDesign.accentColor)
                            }
                        }
                    }
                }
                
                Divider()
                
                // 詳細
                Text("詳細")
                    .font(.headline)
                
                Text(goal.value(forKey: "description") as? String ?? "")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppDesign.secondaryBackground)
                    .cornerRadius(AppDesign.CornerRadius.medium)
            }
            .padding()
        }
        .navigationTitle("目標詳細")
    }
    
    // 進捗更新
    private func updateProgress() {
        let progressValue = Int(progress * 100)
        goalViewModel.updateGoalProgress(goal, progress: progressValue, isCompleted: isCompleted)
    }
    
    // ヘルパープロパティ
    private var progressColor: Color {
        if progress < 0.3 {
            return .red
        } else if progress < 0.7 {
            return AppDesign.accentColor
        } else {
            return AppDesign.primaryColor
        }
    }
    
    private var formattedDeadline: String {
        let deadline = goal.value(forKey: "deadline") as? Date ?? Date()
        return "目標期限: \(formattedDate(deadline))"
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
