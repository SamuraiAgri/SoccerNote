// SoccerNote/Views/Analysis/AnalysisView.swift
import SwiftUI
import CoreData

struct AnalysisView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var matchViewModel: MatchViewModel
    @StateObject private var practiceViewModel: PracticeViewModel
    @StateObject private var goalViewModel: GoalViewModel
    
    // 期間フィルター
    @State private var selectedPeriod: StatsPeriod = .month
    @State private var showingAddGoalSheet = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _matchViewModel = StateObject(wrappedValue: MatchViewModel(viewContext: context))
        _practiceViewModel = StateObject(wrappedValue: PracticeViewModel(viewContext: context))
        _goalViewModel = StateObject(wrappedValue: GoalViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 期間選択セグメントコントロール
                    Picker("期間", selection: $selectedPeriod) {
                        ForEach(StatsPeriod.allCases) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // 1. 活動サマリーカード
                    ActivitySummaryCard(
                        matchCount: matchViewModel.matches.count,
                        practiceCount: practiceViewModel.practices.count,
                        period: selectedPeriod
                    )
                    .padding(.horizontal)
                    
                    // 2. 試合統計カード
                    let matchStats = matchViewModel.getStatistics()
                    MatchStatsQuickCard(
                        totalGoals: matchStats.totalGoals,
                        totalAssists: matchStats.totalAssists,
                        averagePerformance: matchStats.averagePerformance
                    )
                    .padding(.horizontal)
                    
                    // 3. 練習統計カード
                    let practiceStats = practiceViewModel.getStatistics()
                    PracticeStatsQuickCard(
                        totalDuration: practiceStats.totalDuration,
                        averageIntensity: practiceStats.averageIntensity
                    )
                    .padding(.horizontal)
                    
                    // 4. 目標セクション
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("目標管理")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                showingAddGoalSheet = true
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(AppDesign.primaryColor)
                            }
                        }
                        
                        if goalViewModel.goals.isEmpty {
                            // 目標がない場合
                            VStack(spacing: 16) {
                                Image(systemName: "flag")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("目標が設定されていません")
                                    .font(.subheadline)
                                
                                Button(action: {
                                    showingAddGoalSheet = true
                                }) {
                                    Text("目標を追加する")
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(AppDesign.primaryColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        } else {
                            // 目標表示
                            ForEach(goalViewModel.goals.prefix(3), id: \.self) { goal in
                                NavigationLink(destination: GoalDetailView(goal: goal, goalViewModel: goalViewModel)) {
                                    CompactGoalCard(goal: goal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // すべての目標へのリンク
                            if goalViewModel.goals.count > 3 {
                                NavigationLink(destination: GoalsListView(goalViewModel: goalViewModel)) {
                                    Text("すべての目標を表示")
                                        .font(.subheadline)
                                        .foregroundColor(AppDesign.primaryColor)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("分析")
            .sheet(isPresented: $showingAddGoalSheet) {
                SimplifiedAddGoalView(goalViewModel: goalViewModel)
            }
            .onAppear {
                matchViewModel.fetchMatches()
                practiceViewModel.fetchPractices()
                goalViewModel.fetchGoals()
            }
        }
    }
}

// 活動サマリーカード
struct ActivitySummaryCard: View {
    let matchCount: Int
    let practiceCount: Int
    let period: StatsPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(periodTitle)
                .font(.headline)
            
            HStack(spacing: 20) {
                // 試合数
                VStack {
                    Text("\(matchCount)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("試合")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // 区切り線
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                // 練習数
                VStack {
                    Text("\(practiceCount)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppDesign.primaryColor)
                    
                    Text("練習")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // 区切り線
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                // 総活動数
                VStack {
                    Text("\(matchCount + practiceCount)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("総活動")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 期間に応じたタイトル
    private var periodTitle: String {
        switch period {
        case .week:
            return "今週の活動"
        case .month:
            return "今月の活動"
        case .season:
            return "今シーズンの活動"
        case .all:
            return "全期間の活動"
        }
    }
}

// 試合統計カード
struct MatchStatsQuickCard: View {
    let totalGoals: Int
    let totalAssists: Int
    let averagePerformance: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sportscourt.fill")
                    .foregroundColor(.orange)
                
                Text("試合パフォーマンス")
                    .font(.headline)
            }
            
            VStack(spacing: 16) {
                // ゴールとアシスト
                HStack(spacing: 20) {
                    // ゴール
                    VStack {
                        Text("\(totalGoals)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("ゴール")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 区切り線
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 40)
                    
                    // アシスト
                    VStack {
                        Text("\(totalAssists)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("アシスト")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Divider()
                
                // 平均パフォーマンス
                HStack {
                    Text("平均パフォーマンス")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(String(format: "%.1f", averagePerformance))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("/ 10")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// 練習統計カード
struct PracticeStatsQuickCard: View {
    let totalDuration: Int
    let averageIntensity: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(AppDesign.primaryColor)
                
                Text("練習データ")
                    .font(.headline)
            }
            
            VStack(spacing: 16) {
                // 総練習時間
                HStack {
                    Text("総練習時間")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formattedDuration)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppDesign.primaryColor)
                }
                
                Divider()
                
                // 平均強度
                HStack {
                    Text("平均強度")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // 強度インジケーター
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { i in
                            Circle()
                                .fill(i <= Int(averageIntensity.rounded()) ? AppDesign.primaryColor : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                        
                        Text(String(format: "%.1f", averageIntensity))
                            .font(.headline)
                            .foregroundColor(AppDesign.primaryColor)
                            .padding(.leading, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 時間のフォーマット
    private var formattedDuration: String {
        let hours = totalDuration / 60
        let minutes = totalDuration % 60
        
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        } else {
            return "\(minutes)分"
        }
    }
}

// コンパクトな目標カード
struct CompactGoalCard: View {
    let goal: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.value(forKey: "title") as? String ?? "")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                // 完了/進行中アイコン
                if goal.value(forKey: "isCompleted") as? Bool ?? false {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if let deadline = goal.value(forKey: "deadline") as? Date,
                          let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day,
                          daysRemaining < 7 {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                }
            }
            
            // 進捗バー
            let progress = Double(goal.value(forKey: "progress") as? Int ?? 0) / 100.0
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor(progress)))
            
            HStack {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(progressColor(progress))
                
                Spacer()
                
                if let deadline = goal.value(forKey: "deadline") as? Date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    formatter.timeStyle = .none
                    
                    Text("期限: \(formatter.string(from: deadline))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
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
}

// 目標一覧画面
struct GoalsListView: View {
    let goalViewModel: GoalViewModel
    @State private var showingAddGoalSheet = false
    
    var body: some View {
        List {
            ForEach(goalViewModel.goals, id: \.self) { goal in
                NavigationLink(destination: GoalDetailView(goal: goal, goalViewModel: goalViewModel)) {
                    CompactGoalCard(goal: goal)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("目標一覧")
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
    }
}

#Preview {
    AnalysisView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
