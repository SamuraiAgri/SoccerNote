// SoccerNote/Views/Reflection/GrowthInsightsView.swift
import SwiftUI
import CoreData

struct GrowthInsightsView: View {
    @StateObject private var reflectionViewModel: ReflectionViewModel
    @StateObject private var activityViewModel: ActivityViewModel
    @State private var selectedPeriod: InsightPeriod = .week
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _reflectionViewModel = StateObject(wrappedValue: ReflectionViewModel(viewContext: context))
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(viewContext: context))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 期間選択
                Picker("期間", selection: $selectedPeriod) {
                    ForEach(InsightPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // モチベーション推移
                moodTrendCard
                
                // 振り返りサマリー
                reflectionSummaryCard
                
                // よく出てくるキーワード
                keywordsCard
                
                // 活動統計
                activityStatsCard
                
                // 成長のヒント
                growthTipsCard
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("成長の記録")
    }
    
    // MARK: - モチベーション推移
    
    private var moodTrendCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("調子の推移")
                    .font(.headline)
                Spacer()
            }
            
            if moodData.isEmpty {
                emptyDataView(message: "データがありません")
            } else {
                MoodChart(data: moodData)
                    .frame(height: 150)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("平均調子")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", averageMood))
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(moodTrendEmoji)
                                .font(.title3)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("最高調子")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("🔥 \(maxMood)回")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - 振り返りサマリー
    
    private var reflectionSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.purple)
                Text("振り返りサマリー")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 20) {
                SummaryItem(
                    value: "\(periodReflections.count)",
                    label: "振り返り数",
                    color: .purple
                )
                
                SummaryItem(
                    value: "\(reflectionViewModel.streakDays())",
                    label: "連続日数",
                    color: .orange
                )
                
                SummaryItem(
                    value: "\(totalWords)",
                    label: "書いた文字数",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - キーワード
    
    private var keywordsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.green)
                Text("よく振り返っていること")
                    .font(.headline)
                Spacer()
            }
            
            if topKeywords.isEmpty {
                emptyDataView(message: "まだ振り返りが少ないです")
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(topKeywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(16)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - 活動統計
    
    private var activityStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sportscourt.fill")
                    .foregroundColor(.orange)
                Text("活動統計")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 20) {
                SummaryItem(
                    value: "\(periodMatchCount)",
                    label: "試合",
                    color: .orange
                )
                
                SummaryItem(
                    value: "\(periodPracticeCount)",
                    label: "練習",
                    color: .green
                )
                
                SummaryItem(
                    value: String(format: "%.1f", averageRating),
                    label: "平均評価",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - 成長のヒント
    
    private var growthTipsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("成長のヒント")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(growthTips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text(tip)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private func emptyDataView(message: String) -> some View {
        HStack {
            Spacer()
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var periodReflections: [NSManagedObject] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        }
        
        return reflectionViewModel.reflections.filter { reflection in
            guard let date = reflection.value(forKey: "date") as? Date else { return false }
            return date >= startDate
        }
    }
    
    private var moodData: [(date: Date, mood: Int)] {
        periodReflections.compactMap { reflection in
            guard let date = reflection.value(forKey: "date") as? Date,
                  let mood = reflection.value(forKey: "mood") as? Int else { return nil }
            return (date, mood)
        }.sorted { $0.date < $1.date }
    }
    
    private var averageMood: Double {
        guard !moodData.isEmpty else { return 0 }
        let total = moodData.reduce(0) { $0 + $1.mood }
        return Double(total) / Double(moodData.count)
    }
    
    private var maxMood: Int {
        moodData.filter { $0.mood == 5 }.count
    }
    
    private var moodTrendEmoji: String {
        if averageMood >= 4 { return "😊" }
        else if averageMood >= 3 { return "😐" }
        else { return "😕" }
    }
    
    private var totalWords: Int {
        periodReflections.reduce(0) { total, reflection in
            let fields = ["successes", "challenges", "learnings", "improvements", "nextGoal", "feelings"]
            let words = fields.compactMap { reflection.value(forKey: $0) as? String }.joined().count
            return total + words
        }
    }
    
    private var topKeywords: [String] {
        // 簡易的なキーワード抽出（実際のプロダクトではNLPを使用）
        let keywords = ["パス", "シュート", "ドリブル", "守備", "切り替え", "声出し", "コミュニケーション", "判断", "体力", "集中"]
        
        var counts: [String: Int] = [:]
        for reflection in periodReflections {
            let allText = ["successes", "challenges", "learnings", "improvements", "nextGoal"]
                .compactMap { reflection.value(forKey: $0) as? String }
                .joined(separator: " ")
            
            for keyword in keywords {
                if allText.contains(keyword) {
                    counts[keyword, default: 0] += 1
                }
            }
        }
        
        return counts.sorted { $0.value > $1.value }.prefix(5).map { $0.key }
    }
    
    private var periodActivities: [NSManagedObject] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        }
        
        return activityViewModel.activities.filter { activity in
            guard let date = activity.value(forKey: "date") as? Date else { return false }
            return date >= startDate
        }
    }
    
    private var periodMatchCount: Int {
        periodActivities.filter { ($0.value(forKey: "type") as? String) == "試合" }.count
    }
    
    private var periodPracticeCount: Int {
        periodActivities.filter { ($0.value(forKey: "type") as? String) == "練習" }.count
    }
    
    private var averageRating: Double {
        guard !periodActivities.isEmpty else { return 0 }
        let total = periodActivities.reduce(0) { $0 + (Int($1.value(forKey: "rating") as? Int16 ?? 0)) }
        return Double(total) / Double(periodActivities.count)
    }
    
    private var growthTips: [String] {
        var tips: [String] = []
        
        if reflectionViewModel.streakDays() > 0 {
            tips.append("素晴らしい！\(reflectionViewModel.streakDays())日連続で振り返りを書いています。この習慣を続けましょう！")
        } else {
            tips.append("毎日の振り返りを習慣にすると、成長が加速します。")
        }
        
        if averageMood >= 4 {
            tips.append("調子が良い状態が続いています。この調子を維持しましょう！")
        } else if averageMood < 3 {
            tips.append("調子が上がらない時期もあります。小さな成功を意識して記録してみましょう。")
        }
        
        if periodReflections.count < 3 {
            tips.append("振り返りの回数を増やすと、より深い気づきが得られます。")
        }
        
        tips.append("課題を具体的に書くと、改善策も見つけやすくなります。")
        
        return Array(tips.prefix(3))
    }
}

// MARK: - Supporting Views

enum InsightPeriod: String, CaseIterable {
    case week = "1週間"
    case month = "1ヶ月"
    case threeMonths = "3ヶ月"
}

struct MoodChart: View {
    let data: [(date: Date, mood: Int)]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let spacing = width / CGFloat(max(data.count - 1, 1))
            
            ZStack {
                // グリッド線
                ForEach(1..<5) { i in
                    Path { path in
                        let y = height - (CGFloat(i) / 5.0 * height)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                }
                
                // 折れ線
                if data.count > 1 {
                    Path { path in
                        for (index, item) in data.enumerated() {
                            let x = CGFloat(index) * spacing
                            let y = height - (CGFloat(item.mood) / 5.0 * height)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )
                }
                
                // データポイント
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let x = CGFloat(index) * spacing
                    let y = height - (CGFloat(item.mood) / 5.0 * height)
                    
                    Circle()
                        .fill(moodColor(item.mood))
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
    }
    
    private func moodColor(_ mood: Int) -> Color {
        switch mood {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .blue
        default: return .gray
        }
    }
}

struct SummaryItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        let maxContainerWidth = proposal.width ?? .infinity
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxContainerWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
            
            currentX += size.width + spacing
            maxWidth = max(maxWidth, currentX)
            lineHeight = max(lineHeight, size.height)
        }
        
        return (CGSize(width: maxWidth, height: currentY + lineHeight), frames)
    }
}

#Preview {
    NavigationView {
        GrowthInsightsView()
    }
}
