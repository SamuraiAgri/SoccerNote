// SoccerNote/Views/Stats/StatsView.swift
import SwiftUI
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var matchViewModel: MatchViewModel
    @StateObject private var practiceViewModel: PracticeViewModel
    
    // 期間フィルター
    @State private var selectedPeriod: StatsPeriod = .month
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _matchViewModel = StateObject(wrappedValue: MatchViewModel(viewContext: context))
        _practiceViewModel = StateObject(wrappedValue: PracticeViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 期間選択セグメントコントロール
                    Picker("期間", selection: $selectedPeriod) {
                        ForEach(StatsPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // ここで各種カードを表示
                    SimplifiedSummaryCard(
                        matchCount: matchViewModel.matches.count,
                        practiceCount: practiceViewModel.practices.count,
                        period: selectedPeriod
                    )
                    .padding(.horizontal)
                    
                    let matchStats = matchViewModel.getStatistics()
                    SimplifiedMatchStatsCard(
                        totalGoals: matchStats.totalGoals,
                        totalAssists: matchStats.totalAssists,
                        averagePerformance: matchStats.averagePerformance
                    )
                    .padding(.horizontal)
                    
                    let practiceStats = practiceViewModel.getStatistics()
                    SimplifiedPracticeStatsCard(
                        totalDuration: practiceStats.totalDuration,
                        averageIntensity: practiceStats.averageIntensity
                    )
                    .padding(.horizontal)
                    
                    SimplifiedProgressChart(period: selectedPeriod)
                        .frame(height: 220)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("統計")
            .onAppear {
                matchViewModel.fetchMatches()
                practiceViewModel.fetchPractices()
            }
        }
    }
    
    // シーズンの日付範囲を取得
    func getSeasonDateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let currentDate = Date()
        let year = calendar.component(.year, from: currentDate)
        
        // 4月1日から翌年3月31日までをシーズンとする
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = 4
        startComponents.day = 1
        
        var endComponents = DateComponents()
        endComponents.year = year + 1
        endComponents.month = 3
        endComponents.day = 31
        
        let startDate = calendar.date(from: startComponents) ?? currentDate
        let endDate = calendar.date(from: endComponents) ?? currentDate
        
        if currentDate < startDate {
            return (
                calendar.date(byAdding: .year, value: -1, to: startDate) ?? currentDate,
                calendar.date(byAdding: .year, value: -1, to: endDate) ?? currentDate
            )
        }
        
        return (startDate, endDate)
    }
}

// サマリーカード
struct SimplifiedSummaryCard: View {
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
                        .foregroundColor(.green)
                    
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
        .cornerRadius(10)
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
struct SimplifiedMatchStatsCard: View {
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
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// 練習統計カード
struct SimplifiedPracticeStatsCard: View {
    let totalDuration: Int
    let averageIntensity: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(.green)
                
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
                        .foregroundColor(.green)
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
                                .fill(i <= Int(averageIntensity.rounded()) ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                        
                        Text(String(format: "%.1f", averageIntensity))
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.leading, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
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

// シンプル化された進捗チャート
struct SimplifiedProgressChart: View {
    let period: StatsPeriod
    
    // サンプルデータ（実際のアプリでは動的なデータを使用）
    let performanceData = [7, 5, 8, 6, 9, 7]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("パフォーマンス推移")
                .font(.headline)
            
            // シンプルなチャート
            GeometryReader { geometry in
                VStack {
                    // チャート本体
                    ZStack(alignment: .leading) {
                        // 水平線（目盛り）
                        VStack(spacing: geometry.size.height / 4) {
                            ForEach(0..<4, id: \.self) { i in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 1)
                            }
                        }
                        
                        // データライン
                        Path { path in
                            let width = geometry.size.width
                            let height = geometry.size.height
                            let maxValue = 10.0 // 最大値
                            let stepWidth = width / CGFloat(performanceData.count - 1)
                            
                            let points = performanceData.enumerated().map { (i, value) -> CGPoint in
                                let x = CGFloat(i) * stepWidth
                                let y = height - (CGFloat(value) / CGFloat(maxValue)) * height
                                return CGPoint(x: x, y: y)
                            }
                            
                            // パスを描画
                            path.move(to: points[0])
                            for i in 1..<points.count {
                                path.addLine(to: points[i])
                            }
                        }
                        .stroke(Color.blue, lineWidth: 2)
                        
                        // データポイント
                        ForEach(0..<performanceData.count, id: \.self) { i in
                            let width = geometry.size.width
                            let height = geometry.size.height
                            let maxValue = 10.0
                            let stepWidth = width / CGFloat(performanceData.count - 1)
                            
                            let x = CGFloat(i) * stepWidth
                            let y = height - (CGFloat(performanceData[i]) / CGFloat(maxValue)) * height
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                                .position(x: x, y: y)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // X軸ラベル
                    HStack {
                        ForEach(getLabelsForPeriod(), id: \.self) { label in
                            Text(label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 期間に応じたラベル取得
    private func getLabelsForPeriod() -> [String] {
        switch period {
        case .week:
            return ["月", "火", "水", "木", "金", "土"]
        case .month:
            return ["1週", "2週", "3週", "4週", "5週", "6週"]
        case .season:
            return ["4月", "5月", "6月", "7月", "8月", "9月"]
        case .all:
            return ["前期", "中期", "後期", "次期", "来期", "将来"]
        }
    }
}

#Preview {
    StatsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
