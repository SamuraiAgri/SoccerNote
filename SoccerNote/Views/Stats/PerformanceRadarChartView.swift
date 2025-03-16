// SoccerNote/Views/Stats/PerformanceRadarChartView.swift
import SwiftUI

struct PerformanceRadarChartView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // ヘッダー
            Text("パフォーマンス分析")
                .font(.headline)
            
            Text("各スキルの評価（5段階中）")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // シンプルな代替ビュー
            SimpleRadarChart()
                .frame(height: 280)
                .padding(.vertical, 10)
            
            // 凡例
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                
                Text("あなたのデータ")
                    .font(.caption)
                
                Spacer()
                
                Text("タップして詳細を表示")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct SimpleRadarChart: View {
    var body: some View {
        // 簡略化された静的なレーダーチャート
        Image(systemName: "pentagon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color.green.opacity(0.5))
            .overlay(
                Image(systemName: "pentagon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.green)
                    .blendMode(.sourceAtop)
            )
            .padding(40)
            .background(
                VStack {
                    // 上部ラベル
                    Text("得点力")
                        .font(.caption)
                        .padding(.bottom, 70)
                    
                    HStack {
                        // 左側ラベル
                        Text("スタミナ")
                            .font(.caption)
                            .padding(.trailing, 40)
                        
                        Spacer()
                        
                        // 右側ラベル
                        Text("スピード")
                            .font(.caption)
                            .padding(.leading, 40)
                    }
                    
                    Spacer()
                    
                    HStack {
                        // 左下ラベル
                        Text("守備力")
                            .font(.caption)
                            .padding(.trailing, 40)
                        
                        Spacer()
                        
                        // 右下ラベル
                        Text("テクニック")
                            .font(.caption)
                            .padding(.leading, 40)
                    }
                    
                    Spacer()
                }
            )
            .overlay(
                // 同心円
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: 200)
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: 150)
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: 100)
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: 50)
                }
            )
    }
}

// プレビュー
#Preview {
    PerformanceRadarChartView()
}
