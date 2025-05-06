// SoccerNote/Views/Home/CalendarView.swift
import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth = Date()
    @GestureState private var dragOffset: CGFloat = 0
    
    // 活動データを取得するためのViewModel
    @ObservedObject var activityViewModel: ActivityViewModel
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init(selectedDate: Binding<Date>, activityViewModel: ActivityViewModel) {
        self._selectedDate = selectedDate
        self.activityViewModel = activityViewModel
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // カレンダーヘッダー
            HStack {
                Button(action: {
                    withAnimation {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppDesign.primaryColor)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Text(monthYearText)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppDesign.primaryColor)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 4)
            
            // 曜日ヘッダー
            HStack {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(day == "日" ? .red : (day == "土" ? .blue : .primary))
                }
            }
            .padding(.top, 8)
            
            // 日付グリッド
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(daysInMonth, id: \.self) { day in
                    if day.isPlaceholder {
                        Text("")
                            .frame(maxWidth: .infinity, minHeight: 35)
                    } else {
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedDate = day.date
                            }
                        }) {
                            VStack(spacing: 4) {
                                // 日付
                                Text("\(Calendar.current.component(.day, from: day.date))")
                                    .font(.system(size: 16))
                                    .fontWeight(Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ? .bold : .regular)
                                    .foregroundColor(
                                        Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ? .white :
                                            (Calendar.current.isDateInToday(day.date) ? AppDesign.primaryColor :
                                                (Calendar.current.component(.weekday, from: day.date) == 1 ? .red :
                                                    (Calendar.current.component(.weekday, from: day.date) == 7 ? .blue : .primary)))
                                    )
                                
                                // アクティビティインジケーター - 実際のデータに基づいて表示
                                if hasActivity(for: day.date) {
                                    Circle()
                                        .fill(AppDesign.primaryColor.opacity(0.8))
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .frame(width: 35, height: 35)
                            .background(
                                Circle()
                                    .fill(Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ? AppDesign.primaryColor : Color.clear)
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold {
                        // 左スワイプで次の月へ
                        withAnimation {
                            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    } else if value.translation.width > threshold {
                        // 右スワイプで前の月へ
                        withAnimation {
                            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    }
                }
        )
    }
    
    // 月と年の表示テキスト
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentMonth)
    }
    
    // 月の日付一覧を取得
    private var daysInMonth: [CalendarDay] {
        let calendar = Calendar.current
        
        let month = calendar.component(.month, from: currentMonth)
        let year = calendar.component(.year, from: currentMonth)
        
        guard let monthRange = calendar.range(of: .day, in: .month, for: currentMonth),
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
    
    // 日付にアクティビティがあるかどうかを実際のデータから確認
    private func hasActivity(for date: Date) -> Bool {
        let calendar = Calendar.current
        
        return activityViewModel.activities.contains { activity in
            guard let activityDate = activity.value(forKey: "date") as? Date else { return false }
            return calendar.isDate(activityDate, inSameDayAs: date)
        }
    }
}
