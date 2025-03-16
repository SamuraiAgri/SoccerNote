// SoccerNote/Views/Home/CalendarView.swift
import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @GestureState private var dragOffset: CGFloat = 0
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            // カレンダーヘッダー
            HStack {
                Button(action: {
                    withAnimation {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Text(monthYearText)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.green)
                }
            }
            .padding(.bottom)
            
            // 曜日ヘッダー
            HStack {
                ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(day == "日" ? .red : .primary)
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
        .cornerRadius(10)
        .shadow(radius: 1)
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
    
    // ヘルパープロパティとメソッド
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentMonth)
    }
    
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
                .fill(isSelected ? Color.green : Color.clear)
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
            return .orange // アクセントカラー
        } else if weekday == 1 { // 日曜日
            return .red
        } else {
            return .primary
        }
    }
}

#Preview {
    CalendarView()
}
