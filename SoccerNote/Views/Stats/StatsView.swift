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
