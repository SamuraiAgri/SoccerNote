// SoccerNote/Views/Home/HomeView.swift
import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var activityViewModel = ActivityViewModel(viewContext: PersistenceController.shared.container.viewContext)
    @StateObject private var reflectionViewModel = ReflectionViewModel(viewContext: PersistenceController.shared.container.viewContext)
    
    // タブ選択マネージャーを環境オブジェクトとして取得
    @EnvironmentObject private var tabSelectionManager: TabSelectionManager
    
    @State private var showingReflectionSheet = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 今日の振り返りカード
                    todayReflectionCard
                        .padding(.horizontal)
                    
                    // 統計サマリー
                    statsRow
                        .padding(.horizontal)
                    
                    // 最近の振り返り
                    recentReflectionsSection
                    
                    // 週間カレンダー（コンパクト版）
                    weekCalendarSection
                        .padding(.horizontal)
                    
                    // 最近の活動
                    recentActivitiesSection
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("サッカーノート")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingReflectionSheet = true }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                            .foregroundColor(AppDesign.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingReflectionSheet) {
                ReflectionAddView()
            }
            .onAppear {
                activityViewModel.fetchActivities()
                reflectionViewModel.fetchReflections()
            }
        }
    }
    
    // MARK: - 今日の振り返りカード
    
    private var todayReflectionCard: some View {
        let todayReflection = reflectionViewModel.reflections(for: Date()).first
        
        return VStack(spacing: 16) {
            if let reflection = todayReflection {
                // 今日の振り返りがある場合
                NavigationLink(destination: ReflectionDetailView(reflection: reflection, viewModel: reflectionViewModel)) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("今日の振り返り")
                                .font(.headline)
                            Spacer()
                            Text(moodEmoji(for: reflection))
                                .font(.title2)
                        }
                        
                        if let feelings = reflection.value(forKey: "feelings") as? String, !feelings.isEmpty {
                            Text(feelings)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        HStack {
                            Text("タップして詳細を見る")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // 今日の振り返りがない場合
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("今日の練習・試合を振り返ろう")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("📝")
                            .font(.system(size: 40))
                    }
                    
                    Button(action: { showingReflectionSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("振り返りを書く")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppDesign.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [AppDesign.primaryColor.opacity(0.1), AppDesign.primaryColor.opacity(0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - 統計行
    
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "連続記録",
                value: "\(reflectionViewModel.streakDays())",
                unit: "日",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "今月の振り返り",
                value: "\(reflectionViewModel.thisMonthReflectionCount())",
                unit: "回",
                icon: "book.fill",
                color: .blue
            )
            
            StatCard(
                title: "練習・試合",
                value: "\(thisMonthActivityCount)",
                unit: "回",
                icon: "sportscourt.fill",
                color: .green
            )
        }
    }
    
    // MARK: - 最近の振り返りセクション
    
    private var recentReflectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近の振り返り")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: ReflectionListView()) {
                    Text("すべて見る")
                        .font(.subheadline)
                        .foregroundColor(AppDesign.primaryColor)
                }
            }
            .padding(.horizontal)
            
            if reflectionViewModel.recentReflections.isEmpty {
                emptyReflectionState
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(reflectionViewModel.recentReflections, id: \.objectID) { reflection in
                            NavigationLink(destination: ReflectionDetailView(reflection: reflection, viewModel: reflectionViewModel)) {
                                ReflectionMiniCard(reflection: reflection)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var emptyReflectionState: some View {
        VStack(spacing: 8) {
            Image(systemName: "book.closed")
                .font(.title)
                .foregroundColor(.gray)
            Text("まだ振り返りがありません")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - 週間カレンダー
    
    private var weekCalendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今週の記録")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(weekDays, id: \.self) { date in
                    WeekDayCell(
                        date: date,
                        hasReflection: reflectionViewModel.reflections(for: date).count > 0,
                        hasActivity: activitiesFor(date).count > 0,
                        isToday: Calendar.current.isDateInToday(date)
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - 最近の活動セクション
    
    private var recentActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近の練習・試合")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            if activityViewModel.recentActivities.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "sportscourt")
                        .font(.title)
                        .foregroundColor(.gray)
                    Text("最近の活動はありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                VStack(spacing: 8) {
                    ForEach(activityViewModel.recentActivities.prefix(3), id: \.self) { activity in
                        NavigationLink(destination: ActivityDetailView(activity: activity)) {
                            CompactActivityRow(activity: activity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "おはよう！"
        case 12..<17: return "こんにちは！"
        default: return "お疲れさま！"
        }
    }
    
    private func moodEmoji(for reflection: NSManagedObject) -> String {
        let mood = reflection.value(forKey: "mood") as? Int ?? 3
        switch mood {
        case 1: return "😫"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "🔥"
        default: return "😐"
        }
    }
    
    private var thisMonthActivityCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        
        return activityViewModel.activities.filter { activity in
            guard let date = activity.value(forKey: "date") as? Date else { return false }
            return date >= startOfMonth
        }.count
    }
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)
        }
    }
    
    private func activitiesFor(_ date: Date) -> [NSManagedObject] {
        let calendar = Calendar.current
        return activityViewModel.activities.filter { activity in
            guard let activityDate = activity.value(forKey: "date") as? Date else { return false }
            return calendar.isDate(activityDate, inSameDayAs: date)
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ReflectionMiniCard: View {
    let reflection: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(moodEmoji)
                    .font(.title3)
            }
            
            if !feelings.isEmpty {
                Text(feelings)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(width: 160, height: 100)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
    
    private var formattedDate: String {
        guard let date = reflection.value(forKey: "date") as? Date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d(E)"
        return formatter.string(from: date)
    }
    
    private var moodEmoji: String {
        let mood = reflection.value(forKey: "mood") as? Int ?? 3
        switch mood {
        case 1: return "😫"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "🔥"
        default: return "😐"
        }
    }
    
    private var feelings: String {
        reflection.value(forKey: "feelings") as? String ?? ""
    }
}

struct WeekDayCell: View {
    let date: Date
    let hasReflection: Bool
    let hasActivity: Bool
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayOfWeek)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(dayNumber)
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : .primary)
                .frame(width: 32, height: 32)
                .background(isToday ? AppDesign.primaryColor : Color.clear)
                .clipShape(Circle())
            
            HStack(spacing: 2) {
                if hasReflection {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                }
                if hasActivity {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 8)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct CompactActivityRow: View {
    let activity: NSManagedObject
    
    var body: some View {
        HStack(spacing: 12) {
            // タイプアイコン
            Image(systemName: activityIcon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(activityColor)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activityTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 評価
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                Text("\(rating)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var activityType: String {
        activity.value(forKey: "type") as? String ?? "練習"
    }
    
    private var activityIcon: String {
        activityType == "試合" ? "sportscourt.fill" : "figure.run"
    }
    
    private var activityColor: Color {
        activityType == "試合" ? .orange : .green
    }
    
    private var activityTitle: String {
        if activityType == "試合" {
            if let matches = activity.value(forKey: "matches") as? Set<NSManagedObject>,
               let match = matches.first,
               let opponent = match.value(forKey: "opponent") as? String, !opponent.isEmpty {
                return "vs \(opponent)"
            }
            return "試合"
        } else {
            return "練習"
        }
    }
    
    private var formattedDate: String {
        guard let date = activity.value(forKey: "date") as? Date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: date)
    }
    
    private var rating: Int {
        Int(activity.value(forKey: "rating") as? Int16 ?? 0)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TabSelectionManager())
    }
}
