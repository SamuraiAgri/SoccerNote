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
                VStack(alignment: .leading, spacing: 15) {
                    // 期間選択
                    VStack(alignment: .leading, spacing: 8) {
                        Text("表示期間")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Picker("期間", selection: $selectedPeriod) {
                            ForEach(StatsPeriod.allCases) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                    
                    // 試合統計
                    VStack(alignment: .leading, spacing: 12) {
                        Text("試合統計")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // 試合数、得点、アシスト
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("試合数")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                                        Text("\(matchViewModel.matches.count)")
                                            .font(.system(size: 20, weight: .bold))
                                        
                                        Text("試合")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color.white)
                                
                                Divider()
                                
                                let stats = matchViewModel.getStatistics()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("得点")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(stats.totalGoals)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.orange)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color.white)
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("アシスト")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(stats.totalAssists)")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.orange)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color.white)
                            }
                            
                            Divider()
                                .padding(0)
                            
                            // 平均パフォーマンス
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("平均パフォーマンス")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                                        Text(String(format: "%.1f", matchViewModel.getStatistics().averagePerformance))
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.orange)
                                        
                                        Text("/ 10")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                // スター表示
                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { i in
                                        Image(systemName: i <= Int(matchViewModel.getStatistics().averagePerformance / 2) ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .background(Color.white)
                        }
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .padding(.horizontal)
                    }
                    
                    // 練習統計
                    VStack(alignment: .leading, spacing: 12) {
                        Text("練習統計")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // 練習回数と時間
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("練習回数")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                                        Text("\(practiceViewModel.practices.count)")
                                            .font(.system(size: 20, weight: .bold))
                                        
                                        Text("回")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color.white)
                                
                                Divider()
                                
                                let stats = practiceViewModel.getStatistics()
                                let totalHours = stats.totalDuration / 60
                                let remainingMinutes = stats.totalDuration % 60
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("総練習時間")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(totalHours)時間\(remainingMinutes)分")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color.white)
                            }
                            
                            Divider()
                                .padding(0)
                            
                            // 平均強度
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("平均強度")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                                        Text(String(format: "%.1f", practiceViewModel.getStatistics().averageIntensity))
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.green)
                                        
                                        Text("/ 5")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                // 強度表示
                                HStack(spacing: 4) {
                                    ForEach(1...5, id: \.self) { i in
                                        Circle()
                                            .fill(i <= Int(practiceViewModel.getStatistics().averageIntensity) ? Color.green : Color.gray.opacity(0.3))
                                            .frame(width: 12, height: 12)
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .background(Color.white)
                        }
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .padding(.horizontal)
                    }
                    
                    // 成長推移
                    GrowthChartView(period: selectedPeriod)
                        .padding(.horizontal)
                        .padding(.bottom)
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
