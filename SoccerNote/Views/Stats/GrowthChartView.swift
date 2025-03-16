// SoccerNote/Views/Stats/GrowthChartView.swift
import SwiftUI

struct GrowthChartView: View {
    let period: StatsPeriod
    
    // サンプルデータ - 実際の実装では動的に変更する
    let values = [10, 25, 15, 40, 30, 55]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("成長推移")
                    .font(.headline)
                
                Spacer()
                
                Text(periodText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // グラフの説明
            HStack {
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 12, height: 4)
                    
                    Text("総合評価")
                        .font(.caption)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text("45%向上")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding(.bottom, 8)
            
            // グラフ
            ZStack(alignment: .leading) {
                // 水平線とY軸ラベル
                VStack(spacing: 35) {
                    ForEach([100, 75, 50, 25, 0].reversed(), id: \.self) { value in
                        HStack {
                            Text("\(value)")
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                                .frame(width: 20, alignment: .trailing)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 1)
                        }
                    }
                }
                
                // グラフ線
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width - 25
                        let height = geometry.size.height
                        let maxValue = 100.0
                        let step = width / CGFloat(values.count - 1)
                        
                        let points = values.enumerated().map { (i, value) -> CGPoint in
                            let x = CGFloat(i) * step + 25
                            let y = height - CGFloat(value) / CGFloat(maxValue) * height
                            return CGPoint(x: x, y: y)
                        }
                        
                        path.move(to: points[0])
                        for i in 1..<points.count {
                            path.addLine(to: points[i])
                        }
                    }
                    .stroke(Color.orange, lineWidth: 2.5)
                    
                    // データポイント
                    ForEach(0..<values.count, id: \.self) { i in
                        let width = geometry.size.width - 25
                        let height = geometry.size.height
                        let maxValue = 100.0
                        let step = width / CGFloat(values.count - 1)
                        
                        let x = CGFloat(i) * step + 25
                        let y = height - CGFloat(values[i]) / CGFloat(maxValue) * height
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .overlay(
                                Circle()
                                    .stroke(Color.orange, lineWidth: 2)
                            )
                            .position(x: x, y: y)
                    }
                }
                .frame(height: 140)
            }
            
            // X軸ラベル
            HStack {
                Text("") // 軸ラベル用の余白
                    .frame(width: 25)
                
                ForEach(getXAxisLabels(), id: \.self) { label in
                    Text(label)
                        .font(.system(size: 10))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 説明テキスト
            Text("このグラフは総合的なパフォーマンスの変化を表しています。")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // X軸ラベル（期間に応じて変更）
    private func getXAxisLabels() -> [String] {
        switch period {
        case .week:
            return ["月", "火", "水", "木", "金", "土", "日"]
        case .month:
            return ["1週", "2週", "3週", "4週", "5週", "6週"]
        case .season:
            return ["4月", "5月", "6月", "7月", "8月", "9月"]
        case .all:
            return ["前期", "中期", "後期", "次期", "来期", "将来"]
        }
    }
    
    // 期間表示テキスト
    private var periodText: String {
        switch period {
        case .week:
            return "今週の成長"
        case .month:
            return "今月の成長"
        case .season:
            return "今シーズンの成長"
        case .all:
            return "全期間の成長"
        }
    }
}

#Preview {
    GrowthChartView(period: .month)
}
