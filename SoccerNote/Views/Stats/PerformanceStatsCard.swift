// SoccerNote/Views/Stats/PerformanceStatsCard.swift
import SwiftUI

struct PerformanceStatsCard: View {
    let totalGoals: Int
    let totalAssists: Int
    let averagePerformance: Double
    let totalPracticeMinutes: Int
    let averageIntensity: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("パフォーマンス統計")
                .font(.headline)
            
            HStack(spacing: 20) {
                // 試合統計
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "sportscourt.fill")
                            .foregroundColor(Color.appSecondary)
                        Text("試合")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("得点:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(totalGoals)")
                                .font(.headline)
                                .foregroundColor(Color.appSecondary)
                        }
                        
                        HStack {
                            Text("アシスト:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(totalAssists)")
                                .font(.headline)
                                .foregroundColor(Color.appSecondary)
                        }
                        
                        HStack {
                            Text("平均評価:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.1f", averagePerformance))
                                .font(.headline)
                                .foregroundColor(Color.appSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.appSecondary.opacity(0.1))
                .cornerRadius(8)
                
                // 練習統計
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(Color.appPrimary)
                        Text("練習")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("総時間:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formattedDuration)
                                .font(.headline)
                                .foregroundColor(Color.appPrimary)
                        }
                        
                        HStack {
                            Text("平均強度:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.1f", averageIntensity))
                                .font(.headline)
                                .foregroundColor(Color.appPrimary)
                        }
                        
                        // 空白行（バランスのため）
                        HStack {
                            Text("")
                                .font(.caption)
                                .foregroundColor(.clear)
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.appPrimary.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.appShadow, radius: 3, x: 0, y: 2)
    }
    
    // 時間のフォーマット
    private var formattedDuration: String {
        let hours = totalPracticeMinutes / 60
        let minutes = totalPracticeMinutes % 60
        
        if hours > 0 {
            return "\(hours)時間\(minutes > 0 ? "\(minutes)分" : "")"
        } else {
            return "\(minutes)分"
        }
    }
}

struct PerformanceStatsCard_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceStatsCard(
            totalGoals: 12,
            totalAssists: 8,
            averagePerformance: 7.5,
            totalPracticeMinutes: 450,
            averageIntensity: 3.8
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
