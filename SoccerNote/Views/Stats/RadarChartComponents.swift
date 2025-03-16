// SoccerNote/Views/Stats/RadarChartComponents.swift
import SwiftUI

// 軸線を描画するコンポーネント
struct AxisLine: View {
    let center: CGPoint
    let radius: CGFloat
    let angle: CGFloat
    
    var body: some View {
        Path { path in
            path.move(to: center)
            path.addLine(to: CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            ))
        }
        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
    }
}

// データポイントを描画するコンポーネント
struct DataPoint: View {
    let center: CGPoint
    let radius: CGFloat
    let value: CGFloat
    let angle: CGFloat
    
    var body: some View {
        let position = CGPoint(
            x: center.x + radius * value * cos(angle),
            y: center.y + radius * value * sin(angle)
        )
        
        return Circle()
            .fill(Color.white)
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .stroke(Color.green, lineWidth: 2)
            )
            .position(position)
    }
}

// データポリゴンを描画するコンポーネント
struct DataPolygon: View {
    let center: CGPoint
    let radius: CGFloat
    let dataPoints: [CGFloat]
    
    var body: some View {
        let angles: [CGFloat] = (0..<5).map { CGFloat($0) * .pi * 2 / 5 - .pi / 2 }
        
        return ZStack {
            // 塗りつぶし部分
            Path { path in
                for i in 0..<dataPoints.count {
                    let point = CGPoint(
                        x: center.x + radius * dataPoints[i] * cos(angles[i]),
                        y: center.y + radius * dataPoints[i] * sin(angles[i])
                    )
                    
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.closeSubpath()
            }
            .fill(Color.green.opacity(0.5))
            
            // 輪郭線
            Path { path in
                for i in 0..<dataPoints.count {
                    let point = CGPoint(
                        x: center.x + radius * dataPoints[i] * cos(angles[i]),
                        y: center.y + radius * dataPoints[i] * sin(angles[i])
                    )
                    
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.closeSubpath()
            }
            .stroke(Color.green, lineWidth: 2)
        }
    }
}

// レーダーチャートの背景を描画するコンポーネント
struct RadarChartBackground: View {
    let center: CGPoint
    let radius: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(1...5, id: \.self) { i in
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    .frame(width: radius * 2 * CGFloat(i) / 5,
                           height: radius * 2 * CGFloat(i) / 5)
                    .position(center)
            }
            
            // 軸線
            ForEach(0..<5, id: \.self) { i in
                AxisLine(
                    center: center,
                    radius: radius,
                    angle: CGFloat(i) * .pi * 2 / 5 - .pi / 2
                )
            }
        }
    }
}
