// SoccerNote/Views/Calendar/CalendarTabView.swift
import SwiftUI
import CoreData

struct CalendarTabView: View {
    @StateObject private var activityViewModel: ActivityViewModel
    @StateObject private var reflectionViewModel: ReflectionViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingReflectionSheet = false
    @State private var showingActivitySheet = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(viewContext: context))
        _reflectionViewModel = StateObject(wrappedValue: ReflectionViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 大きなカレンダー
                    MonthCalendarView(
                        selectedDate: $selectedDate,
                        currentMonth: $currentMonth,
                        activityViewModel: activityViewModel,
                        reflectionViewModel: reflectionViewModel
                    )
                    .padding()
                    
                    // 選択日の詳細
                    selectedDayDetails
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("カレンダー")
            .sheet(isPresented: $showingReflectionSheet) {
                ReflectionAddView(initialDate: selectedDate)
            }
            .sheet(isPresented: $showingActivitySheet) {
                SimpleRecordAddView(initialDate: selectedDate)
            }
            .bannerAd(position: .bottom)
        }
        .onAppear {
            activityViewModel.fetchActivities()
            reflectionViewModel.fetchReflections()
        }
    }
    
    // MARK: - 選択日の詳細
    
    private var selectedDayDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 日付ヘッダー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedSelectedDate)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(dayOfWeek)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 日付の統計
                HStack(spacing: 16) {
                    if hasReflection {
                        Label("\(reflectionCount)", systemImage: "book.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    if hasActivity {
                        Label("\(activityCount)", systemImage: "sportscourt.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Divider()
            
            // アクションボタン
            HStack(spacing: 12) {
                if !hasReflection {
                    Button(action: { showingReflectionSheet = true }) {
                        Label("振り返りを追加", systemImage: "book.fill")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(AppDesign.primaryColor)
                            .cornerRadius(8)
                    }
                }
                
                Button(action: { showingActivitySheet = true }) {
                    Label("活動を追加", systemImage: "sportscourt.fill")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            
            Divider()
            
            // 振り返り
            if let reflection = selectedDayReflection {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.blue)
                        Text("振り返り")
                            .font(.headline)
                        Spacer()
                        Text(moodEmoji(for: reflection))
                            .font(.title2)
                    }
                    
                    if let feelings = reflection.value(forKey: "feelings") as? String, !feelings.isEmpty {
                        Text(feelings)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                    
                    NavigationLink(destination: ReflectionDetailView(reflection: reflection, viewModel: reflectionViewModel)) {
                        Text("詳細を見る")
                            .font(.caption)
                            .foregroundColor(AppDesign.primaryColor)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            
            // 活動リスト
            if !selectedDayActivities.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "sportscourt.fill")
                            .foregroundColor(.green)
                        Text("練習・試合")
                            .font(.headline)
                    }
                    
                    ForEach(selectedDayActivities, id: \.objectID) { activity in
                        NavigationLink(destination: ActivityDetailView(activity: activity)) {
                            CompactActivityRow(activity: activity)
                        }
                    }
                }
            }
            
            // 空の状態
            if !hasReflection && !hasActivity {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("この日の記録はありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: selectedDate)
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    private var selectedDayReflection: NSManagedObject? {
        reflectionViewModel.reflections(for: selectedDate).first
    }
    
    private var selectedDayActivities: [NSManagedObject] {
        let calendar = Calendar.current
        return activityViewModel.activities.filter { activity in
            guard let activityDate = activity.value(forKey: "date") as? Date else { return false }
            return calendar.isDate(activityDate, inSameDayAs: selectedDate)
        }
    }
    
    private var hasReflection: Bool {
        selectedDayReflection != nil
    }
    
    private var hasActivity: Bool {
        !selectedDayActivities.isEmpty
    }
    
    private var reflectionCount: Int {
        reflectionViewModel.reflections(for: selectedDate).count
    }
    
    private var activityCount: Int {
        selectedDayActivities.count
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
}

// MARK: - Month Calendar View

struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    @ObservedObject var activityViewModel: ActivityViewModel
    @ObservedObject var reflectionViewModel: ReflectionViewModel
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            HStack {
                Button(action: {
                    HapticFeedback.light()
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(AppDesign.primaryColor)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(monthYearText)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(monthActivityCount)回の記録")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    HapticFeedback.light()
                    withAnimation {
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(AppDesign.primaryColor)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                }
            }
            
            // 曜日ヘッダー
            HStack(spacing: 0) {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // カレンダーグリッド
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                            hasReflection: hasReflection(on: date),
                            hasActivity: hasActivity(on: date)
                        )
                        .onTapGesture {
                            HapticFeedback.selection()
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: currentMonth)
    }
    
    private var monthActivityCount: Int {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        let startOfMonth = calendar.date(from: components)!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let activityCount = activityViewModel.activities.filter { activity in
            guard let date = activity.value(forKey: "date") as? Date else { return false }
            return date >= startOfMonth && date <= endOfMonth
        }.count
        
        let reflectionCount = reflectionViewModel.reflections.filter { reflection in
            guard let date = reflection.value(forKey: "date") as? Date else { return false }
            return date >= startOfMonth && date <= endOfMonth
        }.count
        
        return activityCount + reflectionCount
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        let monthLastDay = calendar.date(byAdding: DateComponents(day: -1), to: monthInterval.end)!
        guard let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthLastDay) else {
            return []
        }
        
        var dates: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate <= monthLastWeek.end {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private func hasReflection(on date: Date) -> Bool {
        !reflectionViewModel.reflections(for: date).isEmpty
    }
    
    private func hasActivity(on date: Date) -> Bool {
        activityViewModel.activities.contains { activity in
            guard let activityDate = activity.value(forKey: "date") as? Date else { return false }
            return calendar.isDate(activityDate, inSameDayAs: date)
        }
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let hasReflection: Bool
    let hasActivity: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.system(size: 16, weight: isSelected || isToday ? .bold : .regular))
                .foregroundColor(textColor)
            
            // インジケーター
            HStack(spacing: 2) {
                if hasReflection {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 4, height: 4)
                }
                if hasActivity {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 4)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(backgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? AppDesign.primaryColor : Color.clear, lineWidth: 2)
        )
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .gray.opacity(0.4)
        } else if isSelected {
            return .white
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return AppDesign.primaryColor
        } else if hasReflection || hasActivity {
            return AppDesign.primaryColor.opacity(0.1)
        } else {
            return Color.clear
        }
    }
}

#Preview {
    CalendarTabView()
}
