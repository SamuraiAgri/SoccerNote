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

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return PracticeStatsCard(practiceViewModel: PracticeViewModel(viewContext: context))
}
