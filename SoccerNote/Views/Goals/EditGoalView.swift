// SoccerNote/Views/Goals/EditGoalView.swift
import SwiftUI
import CoreData

struct EditGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    let goal: NSManagedObject
    let goalViewModel: GoalViewModel
    
    @State private var title: String
    @State private var description: String
    @State private var deadline: Date
    @State private var progress: Int
    @State private var isCompleted: Bool
    @State private var toast: ToastData?
    
    init(goal: NSManagedObject, goalViewModel: GoalViewModel) {
        self.goal = goal
        self.goalViewModel = goalViewModel
        
        _title = State(initialValue: goal.value(forKey: "title") as? String ?? "")
        _description = State(initialValue: goal.value(forKey: "goalDescription") as? String ?? "")
        _deadline = State(initialValue: goal.value(forKey: "deadline") as? Date ?? Date())
        _progress = State(initialValue: goal.value(forKey: "progress") as? Int ?? 0)
        _isCompleted = State(initialValue: goal.value(forKey: "isCompleted") as? Bool ?? false)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("目標情報")) {
                    TextField("タイトル", text: $title)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("説明")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    DatePicker("期限", selection: $deadline, displayedComponents: .date)
                }
                
                Section(header: Text("進捗")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("進捗: \(progress)%")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text(progressLabel)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(progressColor.opacity(0.2))
                                .foregroundColor(progressColor)
                                .cornerRadius(8)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(progress) },
                            set: { progress = Int($0) }
                        ), in: 0...100, step: 5)
                        .accentColor(progressColor)
                        .onChange(of: progress) { _, _ in
                            HapticFeedback.selection()
                        }
                        
                        ProgressView(value: Double(progress) / 100.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    }
                    
                    Toggle("達成済みとしてマーク", isOn: $isCompleted)
                        .onChange(of: isCompleted) { _, newValue in
                            HapticFeedback.light()
                            if newValue {
                                progress = 100
                            }
                        }
                }
                
                Section {
                    Button(action: {
                        HapticFeedback.medium()
                        saveGoal()
                    }) {
                        HStack {
                            Spacer()
                            Text("変更を保存")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("目標を編集")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    HapticFeedback.light()
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .toast($toast)
        }
    }
    
    private var progressLabel: String {
        switch progress {
        case 0..<25:
            return "開始"
        case 25..<50:
            return "進行中"
        case 50..<75:
            return "順調"
        case 75..<100:
            return "もう少し"
        case 100:
            return "完了"
        default:
            return ""
        }
    }
    
    private var progressColor: Color {
        switch progress {
        case 0..<25:
            return .red
        case 25..<50:
            return .orange
        case 50..<75:
            return .blue
        case 75..<100:
            return .green
        case 100:
            return .green
        default:
            return .gray
        }
    }
    
    private func saveGoal() {
        goalViewModel.updateGoal(
            goal,
            title: title,
            description: description,
            deadline: deadline,
            progress: progress,
            isCompleted: isCompleted
        )
        
        HapticFeedback.success()
        toast = ToastData(type: .success, message: "目標を更新しました")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
