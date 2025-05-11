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
                        .foregroundColor(Color.appPrimary)
                        .padding(10)
                        .background(Color.appPrimary.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Spacer()
                
                Text(monthYearText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.appPrimary)
                        .padding(10)
                        .background(Color.appPrimary.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 8)
            
            // 曜日ヘッダー
            HStack {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(
                            day == "日" ? .red :
                            (day == "土" ? Color.appAccent : .primary)
                        )
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
                            ZStack {
                                // 選択日のハイライト
                                if Calendar.current.isDate(day.date, inSameDayAs: selectedDate) {
                                    Circle()
                                        .fill(Color.appPrimary)
                                        .frame(width: 35, height: 35)
                                } else if Calendar.current.isDateInToday(day.date) {
                                    // 今日の日付はアウトライン
                                    Circle()
                                        .stroke(Color.appPrimary, lineWidth: 1.5)
                                        .frame(width: 35, height: 35)
                                }
                                
                                // 日付
                                Text("\(Calendar.current.component(.day, from: day.date))")
                                    .font(.system(size: 16))
                                    .fontWeight(
                                        Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ?
                                        .bold : .regular
                                    )
                                    .foregroundColor(
                                        Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ?
                                        .white :
                                        (Calendar.current.isDateInToday(day.date) ?
                                         Color.appPrimary :
                                         (Calendar.current.component(.weekday, from: day.date) == 1 ?
                                          .red :
                                          (Calendar.current.component(.weekday, from: day.date) == 7 ?
                                           Color.appAccent :
                                           .primary)))
                                    )
                                
                                // アクティビティインジケーター - 実際のデータに基づいて表示
                                if hasActivity(for: day.date) {
                                    Circle()
                                        .fill(
                                            getActivityColor(for: day.date)
                                        )
                                        .frame(width: 6, height: 6)
                                        .offset(y: 12)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.appShadow, radius: 5, x: 0, y: 2)
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
    
    // 日付のアクティビティタイプに基づいた色を取得
    private func getActivityColor(for date: Date) -> Color {
        let calendar = Calendar.current
        let matchTypes = activityViewModel.activities.filter { activity in
            guard let activityDate = activity.value(forKey: "date") as? Date,
                  let type = activity.value(forKey: "type") as? String else { return false }
            return calendar.isDate(activityDate, inSameDayAs: date) && type == "match"
        }
        
        let practiceTypes = activityViewModel.activities.filter { activity in
            guard let activityDate = activity.value(forKey: "date") as? Date,
                  let type = activity.value(forKey: "type") as? String else { return false }
            return calendar.isDate(activityDate, inSameDayAs: date) && type == "practice"
        }
        
        if !matchTypes.isEmpty && !practiceTypes.isEmpty {
            // 試合と練習の両方がある場合は紫色
            return Color.purple
        } else if !matchTypes.isEmpty {
            // 試合のみの場合はオレンジ
            return Color.appSecondary
        } else {
            // 練習のみの場合は緑
            return Color.appPrimary
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(
            selectedDate: .constant(Date()),
            activityViewModel: ActivityViewModel(viewContext: PersistenceController.preview.container.viewContext)
        )
        .frame(height: 380)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
