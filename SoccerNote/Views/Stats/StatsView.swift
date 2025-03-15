// SoccerNote/Views/Stats/StatsView.swift
import SwiftUI
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var matchViewModel: MatchViewModel
    @StateObject private var practiceViewModel: PracticeViewModel
    
    // グラフ表示期間
    @State private var selectedPeriod: StatsPeriod = .month
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _matchViewModel = StateObject(wrappedValue: MatchViewModel(viewContext: context))
        _practiceViewModel = StateObject(wrappedValue: PracticeViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.large) {
                    // 期間選択
                    Picker("期間", selection: $selectedPeriod) {
                        ForEach(StatsPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // 試合統計
                    MatchStatsCard(matchViewModel: matchViewModel)
                    
                    // 練習統計
                    PracticeStatsCard(practiceViewModel: practiceViewModel)
                    
                    // パフォーマンスレーダーチャート
                    PerformanceRadarChartView()
                        .frame(height: 300)
                        .padding(.horizontal)
                    
                    // 成長グラフ
                    GrowthChartView(period: selectedPeriod)
                        .frame(height: 250)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("統計")
            .onAppear {
                matchViewModel.fetchMatches()
                practiceViewModel.fetchPractices()
            }
        }
    }
}

// 統計期間
enum StatsPeriod: String, CaseIterable, Identifiable {
    case week = "週間"
    case month = "月間"
    case season = "シーズン"
    case all = "全期間"
    
    var id: String { self.rawValue }
}

// SoccerNote/Views/Stats/MatchStatsCard.swift
import SwiftUI

struct MatchStatsCard: View {
    let matchViewModel: MatchViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("試合統計")
                .font(.appHeadline())
                .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: AppDesign.CornerRadius.medium)
                    .fill(AppDesign.secondaryBackground)
                
                VStack(spacing: 15) {
                    // 試合数、得点、アシスト
                    HStack {
                        StatItem(title: "試合数", value: "\(matchViewModel.matches.count)")
                        Divider()
                        
                        let stats = matchViewModel.getStatistics()
                        
                        StatItem(title: "得点", value: "\(stats.totalGoals)")
                        Divider()
                        
                        StatItem(title: "アシスト", value: "\(stats.totalAssists)")
                    }
                    .frame(height: 60)
                    
                    Divider()
                    
                    // 平均評価
                    HStack {
                        Text("平均パフォーマンス")
                            .font(.headline)
                            .foregroundColor(AppDesign.secondaryText)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", matchViewModel.getStatistics().averagePerformance))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppDesign.secondaryColor)
                        
                        Text("/ 10")
                            .font(.callout)
                            .foregroundColor(AppDesign.secondaryText)
                    }
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }
}

// SoccerNote/Views/Stats/PracticeStatsCard.swift
import SwiftUI

struct PracticeStatsCard: View {
    let practiceViewModel: PracticeViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("練習統計")
                .font(.appHeadline())
                .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: AppDesign.CornerRadius.medium)
                    .fill(AppDesign.secondaryBackground)
                
                VStack(spacing: 15) {
                    // 練習回数と総時間
                    HStack {
                        StatItem(title: "練習回数", value: "\(practiceViewModel.practices.count)")
                        Divider()
                        
                        let stats = practiceViewModel.getStatistics()
                        let totalHours = stats.totalDuration / 60
                        let remainingMinutes = stats.totalDuration % 60
                        
                        StatItem(title: "総練習時間", value: "\(totalHours)時間\(remainingMinutes)分")
                    }
                    .frame(height: 60)
                    
                    Divider()
                    
                    // 平均強度
                    HStack {
                        Text("平均強度")
                            .font(.headline)
                            .foregroundColor(AppDesign.secondaryText)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", practiceViewModel.getStatistics().averageIntensity))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppDesign.primaryColor)
                        
                        Text("/ 5")
                            .font(.callout)
                            .foregroundColor(AppDesign.secondaryText)
                    }
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }
}

// SoccerNote/Views/Stats/StatItem.swift
import SwiftUI

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(AppDesign.secondaryText)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
    }
}

// SoccerNote/Views/Stats/PerformanceRadarChartView.swift
import SwiftUI

struct PerformanceRadarChartView: View {
    // 実際のアプリではSwiftUIのPath等を使って描画する
    // ここではプレースホルダーとしてシンプルな表示にしている
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("パフォーマンス分析")
                .font(.appHeadline())
            
            Spacer()
            
            ZStack {
                // 背景の円
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                
                // 五角形
                Path { path in
                    let center = CGPoint(x: 150, y: 150)
                    let radius: CGFloat = 100
                    let angles = [0, 72, 144, 216, 288].map { CGFloat($0) * .pi / 180 }
                    
                    let points = angles.map { angle in
                        CGPoint(
                            x: center.x + radius * 0.7 * cos(angle),
                            y: center.y + radius * 0.7 * sin(angle)
                        )
                    }
                    
                    path.move(to: points[0])
                    for point in points[1...] {
                        path.addLine(to: point)
                    }
                    path.closeSubpath()
                }
                .fill(AppDesign.primaryColor.opacity(0.5))
                
                // 軸ラベル
                VStack {
                    Text("得点力")
                        .font(.caption)
                        .offset(y: -100)
                    
                    HStack {
                        Text("スピード")
                            .font(.caption)
                            .offset(x: -80, y: -30)
                        
                        Spacer()
                        
                        Text("テクニック")
                            .font(.caption)
                            .offset(x: 80, y: -30)
                    }
                    .frame(width: 200)
                    
                    Spacer()
                    
                    HStack {
                        Text("守備力")
                            .font(.caption)
                            .offset(x: -60, y: 30)
                        
                        Spacer()
                        
                        Text("スタミナ")
                            .font(.caption)
                            .offset(x: 60, y: 30)
                    }
                    .frame(width: 200)
                }
                .frame(width: 300, height: 300)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppDesign.secondaryBackground)
        .cornerRadius(AppDesign.CornerRadius.medium)
    }
}

// SoccerNote/Views/Stats/GrowthChartView.swift
import SwiftUI

struct GrowthChartView: View {
    let period: StatsPeriod
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("成長推移")
                .font(.appHeadline())
            
            Spacer()
            
            // グラフのプレースホルダー（実際のアプリではSwiftUIのPath等で描画）
            Path { path in
                let width: CGFloat = 300
                let height: CGFloat = 150
                let points: [CGPoint] = [
                    CGPoint(x: 0, y: height),
                    CGPoint(x: width * 0.2, y: height * 0.8),
                    CGPoint(x: width * 0.4, y: height * 0.9),
                    CGPoint(x: width * 0.6, y: height * 0.5),
                    CGPoint(x: width * 0.8, y: height * 0.7),
                    CGPoint(x: width, y: height * 0.3)
                ]
                
                path.move(to: points[0])
                for point in points[1...] {
                    path.addLine(to: point)
                }
            }
            .stroke(AppDesign.secondaryColor, lineWidth: 2)
            
            // X軸
            HStack {
                ForEach(0..<6) { i in
                    Text(getXAxisLabel(index: i))
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(AppDesign.secondaryBackground)
        .cornerRadius(AppDesign.CornerRadius.medium)
    }
    
    // X軸ラベル（期間に応じて変更）
    func getXAxisLabel(index: Int) -> String {
        switch period {
        case .week:
            let days = ["月", "火", "水", "木", "金", "土", "日"]
            return days[index % 7]
        case .month:
            return "\(index + 1)週"
        case .season:
            return "\(index + 1)月"
        case .all:
            return "\(index + 1)期"
        }
    }
}
