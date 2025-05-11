// SoccerNote/Views/Stats/PerformanceChartCard.swift
import SwiftUI
import CoreData

struct PerformanceChartCard: View {
    let period: StatsPeriod
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var performanceData: [Int] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("パフォーマンス推移")
                    .font(.headline)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("データを読み込み中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    Spacer()
                }
                .frame(height: 200)
            } else if !performanceData.isEmpty {
                // 実際のデータがある場合
                performanceChartView(data: performanceData)
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
        .onAppear {
            loadPerformanceData()
        }
    }
    
    // 実際のデータを読み込む
    private func loadPerformanceData() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // CoreDataからパフォーマンスデータを取得する処理
            // 例: 試合のパフォーマンス評価を取得
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Match")
            let sortDescriptor = NSSortDescriptor(key: "activity.date", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // 期間に応じたフィルタ条件を設定
            let calendar = Calendar.current
            let today = Date()
            var fromDate: Date?
            
            switch period {
            case .week:
                fromDate = calendar.date(byAdding: .day, value: -7, to: today)
            case .month:
                fromDate = calendar.date(byAdding: .month, value: -1, to: today)
            case .season:
                // シーズンは例えば4月〜翌年3月などに設定可能
                let month = calendar.component(.month, from: today)
                let year = calendar.component(.year, from: today)
                if month >= 4 { // 4月以降なら今年度のシーズン
                    fromDate = calendar.date(from: DateComponents(year: year, month: 4, day: 1))
                } else { // 1-3月なら前年度からのシーズン
                    fromDate = calendar.date(from: DateComponents(year: year-1, month: 4, day: 1))
                }
            case .all:
                // 全期間は日付フィルタなし
                fromDate = nil
            }
            
            // 日付でフィルタリング（全期間以外）
            if let fromDate = fromDate {
                let predicate = NSPredicate(format: "activity.date >= %@", fromDate as NSDate)
                fetchRequest.predicate = predicate
            }
            
            do {
                let matches = try viewContext.fetch(fetchRequest)
                
                // Matchオブジェクトからパフォーマンス値を抽出
                performanceData = matches.compactMap { match in
                    match.value(forKey: "performance") as? Int
                }
                
                isLoading = false
            } catch {
                print("パフォーマンスデータの取得に失敗: \(error)")
                isLoading = false
            }
        }
    }
    
    // パフォーマンスチャートビュー
    private func performanceChartView(data: [Int]) -> some View {
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
                        let stepWidth = width / CGFloat(data.count - 1 > 0 ? data.count - 1 : 1)
                        
                        let points = data.enumerated().map { (i, value) -> CGPoint in
                            let x = CGFloat(i) * stepWidth
                            let y = height - (CGFloat(value) / CGFloat(maxValue)) * height
                            return CGPoint(x: x, y: y)
                        }
                        
                        // パスを描画（データが少なくとも2点あれば線を描画）
                        if !points.isEmpty {
                            path.move(to: points[0])
                            for i in 1..<points.count {
                                path.addLine(to: points[i])
                            }
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
                        let stepWidth = width / CGFloat(data.count - 1 > 0 ? data.count - 1 : 1)
                        
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
                    // データ数に合わせたラベルを表示
                    ForEach(0..<min(getLabelsForPeriod().count, max(data.count, 1)), id: \.self) { index in
                        let labels = getLabelsForPeriod()
                        let labelIndex = min(index, labels.count - 1)
                        Text(labels[labelIndex])
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(height: 200)
    }
    
    // 期間に応じたラベル取得
    private func getLabelsForPeriod() -> [String] {
        switch period {
        case .week:
            return ["月", "火", "水", "木", "金", "土", "日"]
        case .month:
            return ["1週", "2週", "3週", "4週", "5週", "6週"]
        case .season:
            return ["4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月", "1月", "2月", "3月"]
        case .all:
            return ["過去", "1ヶ月前", "現在"]
        }
    }
}

struct PerformanceChartCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // データがない場合のプレビュー
            PerformanceChartCard(period: .month)
                .previewDisplayName("データなし")
        }
        .frame(height: 250)
        .previewLayout(.sizeThatFits)
        .padding()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
