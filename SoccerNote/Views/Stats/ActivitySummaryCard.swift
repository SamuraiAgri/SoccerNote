// SoccerNote/Views/Stats/ActivitySummaryCard.swift
import SwiftUI

struct ActivitySummaryCard: View {
    let matchCount: Int
    let practiceCount: Int
    let period: StatsPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(periodTitle)
                .font(.headline)
            
            HStack(spacing: 10) {
                // 試合数
                VStack {
                    Text("\(matchCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color.appSecondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "sportscourt.fill")
                            .font(.caption)
                            .foregroundColor(Color.appSecondary)
                        
                        Text("試合")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.appSecondary.opacity(0.1))
                .cornerRadius(10)
                
                // 練習数
                VStack {
                    Text("\(practiceCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color.appPrimary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.caption)
                            .foregroundColor(Color.appPrimary)
                        
                        Text("練習")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.appPrimary.opacity(0.1))
                .cornerRadius(10)
                
                // 総活動数
                VStack {
                    Text("\(matchCount + practiceCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color.appAccent)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(Color.appAccent)
                        
                        Text("総活動")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.appAccent.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.appShadow, radius: 3, x: 0, y: 2)
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

struct ActivitySummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivitySummaryCard(
            matchCount: 3,
            practiceCount: 5,
            period: .month
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
