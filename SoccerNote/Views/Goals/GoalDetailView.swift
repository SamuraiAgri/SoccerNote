import SwiftUI
import CoreData

struct GoalDetailView: View {
    let goal: NSManagedObject
    let goalViewModel: GoalViewModel
    
    @State private var isEditing = false
    @State private var progress: Double
    @State private var isCompleted: Bool
    @State private var showingEditSheet = false
    @State private var toast: ToastData?
    
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
                                .onChange(of: progress) { _, _ in
                                    HapticFeedback.selection()
                                }
                            
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
                                .onChange(of: isCompleted) { _, newValue in
                                    HapticFeedback.light()
                                    if newValue {
                                        progress = 1.0
                                    }
                                }
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
                
                Text(goal.value(forKey: "goalDescription") as? String ?? "")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppDesign.secondaryBackground)
                    .cornerRadius(AppDesign.CornerRadius.medium)
            }
            .padding()
        }
        .navigationTitle("目標詳細")
        .navigationBarItems(trailing: Button(action: {
            HapticFeedback.light()
            showingEditSheet = true
        }) {
            Text("編集")
        })
        .sheet(isPresented: $showingEditSheet) {
            EditGoalView(goal: goal, goalViewModel: goalViewModel)
        }
        .toast($toast)
        .onAppear {
            // 目標データを再読み込み
            progress = Double(goal.value(forKey: "progress") as? Int ?? 0) / 100.0
            isCompleted = goal.value(forKey: "isCompleted") as? Bool ?? false
        }
    }
    
    // 進捗更新
    private func updateProgress() {
        HapticFeedback.medium()
        let progressValue = Int(progress * 100)
        goalViewModel.updateGoalProgress(goal, progress: progressValue, isCompleted: isCompleted)
        toast = ToastData(type: .success, message: "進捗を更新しました")
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
