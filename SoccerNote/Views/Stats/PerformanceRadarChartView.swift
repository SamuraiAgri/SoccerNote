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

#Preview {
    PerformanceRadarChartView()
}
