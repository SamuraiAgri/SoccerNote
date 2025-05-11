// SoccerNote/Views/Analysis/AnalysisView.swift
import SwiftUI
import CoreData

struct AnalysisView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var matchViewModel: MatchViewModel
    @StateObject private var practiceViewModel: PracticeViewModel
    @StateObject private var goalViewModel: GoalViewModel
    
    @State private var selectedPeriod: StatsPeriod = .month
    @State private var selectedTab: Int = 0
    @State private var showingAddGoalSheet = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _matchViewModel = StateObject(wrappedValue: MatchViewModel(viewContext: context))
        _practiceViewModel = StateObject(wrappedValue: PracticeViewModel(viewContext: context))
        _goalViewModel = StateObject(wrappedValue: GoalViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 統計/目標タブセレクター
                Picker("表示", selection: $selectedTab) {
                    Text("統計").tag(0)
                    Text("目標").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    // 統計タブ
                    ScrollView {
                        VStack(spacing: 16) {
                            // 期間選択
                            Picker("期間", selection: $selectedPeriod) {
                                ForEach(StatsPeriod.allCases) { period in
                                    Text(period.displayName).tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            
                            // 統計カード
                            let matchStats = matchViewModel.getStatistics()
                            let practiceStats = practiceViewModel.getStatistics()
                            
                            ActivitySummaryCard(
                                matchCount: matchViewModel.matches.count,
                                practiceCount: practiceViewModel.practices.count,
                                period: selectedPeriod
                            )
                            .padding(.horizontal)
                            
                            PerformanceStatsCard(
                                totalGoals: matchStats.totalGoals,
                                totalAssists: matchStats.totalAssists,
                                averagePerformance: matchStats.averagePerformance,
                                totalPracticeMinutes: practiceStats.totalDuration,
                                averageIntensity: practiceStats.averageIntensity
                            )
                            .padding(.horizontal)
                            
                            PerformanceChartCard(
                                period: selectedPeriod,
                                performanceData: [7, 5, 8, 6, 9, 7] // サンプルデータ
                            )
                            .frame(height: 250)
                            .padding(.horizontal)
                        }
                        .padding(.bottom)
                    }
                } else {
                    // 目標タブ
                    ZStack {
                        if goalViewModel.isLoading {
                            ProgressView()
                        } else if goalViewModel.goals.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                
                                Text("目標がありません")
                                    .font(.headline)
                                
                                Text("目標を設定して、成長を記録しましょう")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    showingAddGoalSheet = true
                                }) {
                                    Text("目標を追加")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.appPrimary)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                        } else {
                            // 目標リスト
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(goalViewModel.goals, id: \.self) { goal in
                                        NavigationLink(destination: GoalDetailView(goal: goal, goalViewModel: goalViewModel)) {
                                            GoalCardView(goal: goal)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                        
                        // 追加ボタン
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    showingAddGoalSheet = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 60)
                                        .background(Color.appPrimary)
                                        .clipShape(Circle())
                                        .shadow(color: Color.appShadow, radius: 4, x: 0, y: 2)
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
            .navigationTitle("分析")
            .onAppear {
                matchViewModel.fetchMatches()
                practiceViewModel.fetchPractices()
                goalViewModel.fetchGoals()
            }
            .sheet(isPresented: $showingAddGoalSheet) {
                SimplifiedAddGoalView(goalViewModel: goalViewModel)
            }
        }
    }
}

// ActivitySummaryCardの定義を削除 (ActivitySummaryCard.swiftに移動)

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
