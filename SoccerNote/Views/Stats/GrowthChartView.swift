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

#Preview {
    GrowthChartView(period: .month)
}
