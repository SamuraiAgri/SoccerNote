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

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return MatchStatsCard(matchViewModel: MatchViewModel(viewContext: context))
}
