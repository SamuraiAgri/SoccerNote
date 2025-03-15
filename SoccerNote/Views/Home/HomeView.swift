// SoccerNote/Views/Home/HomeView.swift
import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var activityViewModel: ActivityViewModel
    @StateObject private var goalViewModel: GoalViewModel
    
    init() {
        // StateObjectの初期化をイニシャライザで行う
        let context = PersistenceController.shared.container.viewContext
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(viewContext: context))
        _goalViewModel = StateObject(wrappedValue: GoalViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.large) {
                    // ヘッダー部分
                    VStack(alignment: .leading) {
                        Text("SoccerNote")
                            .font(.appTitle())
                            .foregroundColor(AppDesign.primaryColor)
                        
                        Text("今日のパフォーマンスを記録しよう")
                            .font(.appCaption())
                            .foregroundColor(AppDesign.secondaryText)
                    }
                    .padding(.horizontal)
                    
                    // カレンダー表示
                    CalendarView()
                        .frame(height: 300)
                        .padding(.horizontal)
                    
                    // 最近の記録
                    VStack(alignment: .leading) {
                        Text("最近の記録")
                            .font(.appHeadline())
                            .padding(.horizontal)
                        
                        if activityViewModel.recentActivities.isEmpty {
                            EmptyStateView(
                                title: "記録がありません",
                                message: "「追加」タブから新しい記録を追加しましょう",
                                icon: "note.text"
                            )
                        } else {
                            ForEach(activityViewModel.recentActivities, id: \.self) { activity in
                                RecentActivityRow(activity: activity)
                            }
                        }
                    }
                    
                    // 目標進捗
                    VStack(alignment: .leading) {
                        Text("目標進捗")
                            .font(.appHeadline())
                            .padding(.horizontal)
                        
                        if goalViewModel.goals.isEmpty {
                            EmptyStateView(
                                title: "目標がありません",
                                message: "「目標」タブから新しい目標を設定しましょう",
                                icon: "flag"
                            )
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(goalViewModel.goals, id: \.self) { goal in
                                        GoalProgressCard(goal: goal)
                                            .frame(width: 200)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                activityViewModel.fetchActivities()
                goalViewModel.fetchGoals()
            }
        }
    }
}

// SoccerNote/Views/Home/RecentActivityRow.swift
import SwiftUI
import CoreData

struct RecentActivityRow: View {
    let activity: NSManagedObject
    
    var body: some View {
        NavigationLink(destination: ActivityDetailView(activity: activity)) {
            HStack {
                // アクティビティタイプのアイコン
                ZStack {
                    Circle()
                        .fill(activityTypeColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: activityTypeIcon)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading) {
                    Text(activityTypeText)
                        .font(.appHeadline())
                    
                    Text(formattedDate)
                        .font(.appCaption())
                        .foregroundColor(AppDesign.secondaryText)
                }
                
                Spacer()
                
                // 評価スター
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= (activity.value(forKey: "rating") as? Int ?? 0) ? AppIcons.Rating.starFill : AppIcons.Rating.star)
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(AppDesign.secondaryBackground)
            .cornerRadius(AppDesign.CornerRadius.medium)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // ヘルパープロパティ
    private var activityTypeText: String {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? "試合" : "練習"
    }
    
    private var activityTypeIcon: String {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? AppIcons.Activity.match : AppIcons.Activity.practice
    }
    
    private var activityTypeColor: Color {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? AppDesign.secondaryColor : AppDesign.primaryColor
    }
    
    private var formattedDate: String {
        let date = activity.value(forKey: "date") as? Date ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

// SoccerNote/Views/Home/GoalProgressCard.swift
import SwiftUI
import CoreData

struct GoalProgressCard: View {
    let goal: NSManagedObject
    
    var body: some View {
        NavigationLink(destination: GoalDetailView(goal: goal, goalViewModel: GoalViewModel(viewContext: goal.managedObjectContext!))) {
            VStack(alignment: .leading) {
                Text(goal.value(forKey: "title") as? String ?? "")
                    .font(.appHeadline())
                    .lineLimit(1)
                
                Text(formattedDeadline)
                    .font(.caption)
                    .foregroundColor(AppDesign.secondaryText)
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .padding(.vertical, 5)
                
                Text("\(progress * 100, specifier: "%.0f")%")
                    .font(.caption)
                    .foregroundColor(progressColor)
            }
            .padding()
            .background(AppDesign.secondaryBackground)
            .cornerRadius(AppDesign.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // ヘルパープロパティ
    private var progress: Double {
        Double(goal.value(forKey: "progress") as? Int ?? 0) / 100.0
    }
    
    private var progressColor: Color {
        if progress < 0.3 {
            return .red
        } else if progress < 0.7 {
            return AppDesign.accentColor
        } else {
            return AppDesign.primaryColor
        }
    }
    
    private var formattedDeadline: String {
        let deadline = goal.value(forKey: "deadline") as? Date ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return "期限: \(formatter.string(from: deadline))"
    }
}

// SoccerNote/Views/Home/CalendarView.swift
import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            // カレンダーヘッダー
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppDesign.primaryColor)
                }
                
                Spacer()
                
                Text(monthYearText)
                    .font(.appHeadline())
                
                Spacer()
                
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppDesign.primaryColor)
                }
            }
            .padding(.bottom)
            
            // 曜日ヘッダー
            HStack {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(day == "日" ? .red : AppDesign.primaryText)
                }
            }
            
            // 日付グリッド
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { date in
                    if date.isPlaceholder {
                        Text("")
                            .frame(maxWidth: .infinity, minHeight: 35)
                    } else {
                        CalendarDayView(date: date.date, isSelected: Calendar.current.isDate(date.date, inSameDayAs: selectedDate))
                            .onTapGesture {
                                selectedDate = date.date
                            }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(AppDesign.CornerRadius.medium)
        .shadow(radius: 1)
    }
    
    // ヘルパープロパティとメソッド
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: selectedDate)
    }
    
    private var daysInMonth: [CalendarDay] {
        let calendar = Calendar.current
        
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        guard let monthRange = calendar.range(of: .day, in: .month, for: selectedDate),
              let firstDayOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let placeholderDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days = [CalendarDay]()
        
        // 前月のプレースホルダー
        for _ in 0..<placeholderDays {
            days.append(CalendarDay(date: Date(), isPlaceholder: true))
        }
        
        // 当月の日付
        for day in 1...monthRange.count {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                days.append(CalendarDay(date: date, isPlaceholder: false))
            }
        }
        
        return days
    }
}

// カレンダー日付表示用
struct CalendarDay: Hashable {
    let date: Date
    let isPlaceholder: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(isPlaceholder)
    }
    
    static func == (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        return lhs.date == rhs.date && lhs.isPlaceholder == rhs.isPlaceholder
    }
}

// カレンダー日表示
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? AppDesign.primaryColor : Color.clear)
                .frame(width: 35, height: 35)
            
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : dayTextColor)
        }
        .frame(maxWidth: .infinity, minHeight: 35)
    }
    
    // 日曜日や今日の日付の色分け
    private var dayTextColor: Color {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        if calendar.isDateInToday(date) {
            return AppDesign.secondaryColor
        } else if weekday == 1 { // 日曜日
            return .red
        } else {
            return AppDesign.primaryText
        }
    }
}
