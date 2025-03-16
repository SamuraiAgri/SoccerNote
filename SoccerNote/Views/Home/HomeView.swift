// SoccerNote/Views/Home/HomeView.swift
import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var activityViewModel: ActivityViewModel
    @StateObject private var goalViewModel: GoalViewModel
    
    init() {
        // StateObjectの初期化をイニシャライザで行う
        let context = PersistenceController.shared.container.viewContext
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(viewContext: context))
        _goalViewModel = StateObject(wrappedValue: GoalViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.large) {
                    // ヘッダー部分
                    VStack(alignment: .leading) {
                        Text("SoccerNote")
                            .font(.appTitle())
                            .foregroundColor(AppDesign.primaryColor)
                        
                        Text("今日のパフォーマンスを記録しよう")
                            .font(.appCaption())
                            .foregroundColor(AppDesign.secondaryText)
                    }
                    .padding(.horizontal)
                    
                    // カレンダー表示
                    CalendarView()
                        .frame(height: 300)
                        .padding(.horizontal)
                    
                    // 最近の記録
                    VStack(alignment: .leading) {
                        Text("最近の記録")
                            .font(.appHeadline())
                            .padding(.horizontal)
                        
                        if activityViewModel.recentActivities.isEmpty {
                            EmptyStateView(
                                title: "記録がありません",
                                message: "「追加」タブから新しい記録を追加しましょう",
                                icon: "note.text"
                            )
                        } else {
                            ForEach(activityViewModel.recentActivities, id: \.self) { activity in
                                RecentActivityRow(activity: activity)
                            }
                        }
                    }
                    
                    // 目標進捗
                    VStack(alignment: .leading) {
                        Text("目標進捗")
                            .font(.appHeadline())
                            .padding(.horizontal)
                        
                        if goalViewModel.goals.isEmpty {
                            EmptyStateView(
                                title: "目標がありません",
                                message: "「目標」タブから新しい目標を設定しましょう",
                                icon: "flag"
                            )
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(goalViewModel.goals, id: \.self) { goal in
                                        GoalProgressCard(goal: goal)
                                            .frame(width: 200)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                activityViewModel.fetchActivities()
                goalViewModel.fetchGoals()
            }
        }
    }
}
