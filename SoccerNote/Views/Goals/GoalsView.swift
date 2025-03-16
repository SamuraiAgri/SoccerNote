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
            VStack {
                if goalViewModel.goals.isEmpty {
                    VStack(spacing: 30) {
                        Spacer()
                        
                        VStack(spacing: 15) {
                            Image(systemName: "flag")
                                .font(.system(size: 50))
                                .foregroundColor(AppDesign.secondaryText)
                            
                            Text("目標が設定されていません")
                                .font(.headline)
                            
                            Text("目標を設定して、パフォーマンス向上に役立てましょう")
                                .font(.subheadline)
                                .foregroundColor(AppDesign.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            showingAddGoalSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("新しい目標を追加")
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(AppDesign.primaryColor)
                            .cornerRadius(AppDesign.CornerRadius.medium)
                        }
                        
                        Spacer()
                    }
                    .padding()
                } else {
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
                }
            }
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
