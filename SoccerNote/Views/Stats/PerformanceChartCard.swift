// SoccerNote/Views/Stats/PerformanceChartCard.swift
import SwiftUI

struct PerformanceChartCard: View {
    let period: StatsPeriod
    let performanceData: [Int]?
    
    // デフォルト値はnilを許容するように変更
    init(period: StatsPeriod, performanceData: [Int]? = nil) {
        self.period = period
        self.performanceData = performanceData
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("パフォーマンス推移")
                .font(.headline)
            
            if let data = performanceData, !data.isEmpty {
                // 既存のグラフ表示コード
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
                                let stepWidth = width / CGFloat(data.count - 1)
                                
                                let points = data.enumerated().map { (i, value) -> CGPoint in
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
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.appAccent, Color.appAccent.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 3
                            )
                            
                            // データポイント
                            ForEach(0..<data.count, id: \.self) { i in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let maxValue = 10.0
                                let stepWidth = width / CGFloat(data.count - 1)
                                
                                let x = CGFloat(i) * stepWidth
                                let y = height - (CGFloat(data[i]) / CGFloat(maxValue)) * height
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.appAccent, lineWidth: 2)
                                    )
                                    .shadow(color: Color.appShadow, radius: 2, x: 0, y: 1)
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
                .frame(height: 200)
            } else {
                // データがない場合のビュー
                VStack(spacing: 20) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 50))
                        .foregroundColor(Color.gray.opacity(0.5))
                    
                    Text("まだデータがありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("活動を記録すると、ここにパフォーマンスの推移が表示されます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.appShadow, radius: 3, x: 0, y: 2)
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

struct PerformanceChartCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // データがある場合のプレビュー
            PerformanceChartCard(
                period: .month,
                performanceData: [7, 5, 8, 6, 9, 7]
            )
            .previewDisplayName("データあり")
            
            // データがない場合のプレビュー
            PerformanceChartCard(
                period: .month,
                performanceData: nil
            )
            .previewDisplayName("データなし")
        }
        .frame(height: 250)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
