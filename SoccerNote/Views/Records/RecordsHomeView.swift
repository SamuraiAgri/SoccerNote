// SoccerNote/Views/Records/RecordsHomeView.swift
import SwiftUI
import CoreData

struct RecordsHomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var activityViewModel = ActivityViewModel(viewContext: PersistenceController.shared.container.viewContext)
    
    // 環境オブジェクトからAddSheetControllerを取得
    @EnvironmentObject private var addSheetController: AddSheetController
    
    // 選択された日付
    @State private var selectedDate = Date()
    
    // フィルター用
    @State private var showingFilterOptions = false
    @State private var selectedFilter: ActivityType?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // シンプル化したカレンダー
                CompactCalendarView(selectedDate: $selectedDate)
                    .padding(.top)
                    .padding(.horizontal)
                
                // 日付見出し
                HStack {
                    Text(formattedSelectedDate)
                        .font(.headline)
                    
                    Spacer()
                    
                    // フィルターボタン
                    Button(action: {
                        showingFilterOptions.toggle()
                    }) {
                        Label("フィルター", systemImage: "line.3.horizontal.decrease.circle")
                            .font(.subheadline)
                            .foregroundColor(AppDesign.primaryColor)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // フィルターオプション（表示/非表示）
                if showingFilterOptions {
                    HStack {
                        Button(action: {
                            selectedFilter = nil
                        }) {
                            Text("すべて")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedFilter == nil ? AppDesign.primaryColor : Color.gray.opacity(0.2))
                                .foregroundColor(selectedFilter == nil ? .white : .primary)
                                .cornerRadius(15)
                        }
                        
                        ForEach(ActivityType.allCases) { type in
                            Button(action: {
                                selectedFilter = type
                            }) {
                                Text(type.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedFilter == type ? AppDesign.primaryColor : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedFilter == type ? .white : .primary)
                                    .cornerRadius(15)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.opacity)
                }
                
                // 選択した日の記録一覧
                if activitiesForSelectedDate.isEmpty {
                    VStack(spacing: 15) {
                        Spacer()
                        
                        Image(systemName: "note.text")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("この日の記録はありません")
                            .font(.headline)
                        
                        Button(action: {
                            addSheetController.isShowingAddSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("記録を追加")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(AppDesign.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    List {
                        ForEach(activitiesForSelectedDate, id: \.self) { activity in
                            NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                SimplifiedActivityRow(activity: activity)
                            }
                        }
                        .onDelete(perform: deleteActivity)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("サッカー記録帳")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        addSheetController.isShowingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $addSheetController.isShowingAddSheet) {
                AddRecordView(preselectedDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
        .onAppear {
            activityViewModel.fetchActivities()
        }
    }
    
    // 選択された日付のフォーマット
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: selectedDate)
    }
    
    // 選択された日付の活動一覧（フィルター適用済み）
    private var activitiesForSelectedDate: [NSManagedObject] {
        let calendar = Calendar.current
        
        return activityViewModel.activities.filter { activity in
            guard let activityDate = activity.value(forKey: "date") as? Date else { return false }
            
            // 日付でフィルタリング
            let isSameDay = calendar.isDate(activityDate, inSameDayAs: selectedDate)
            
            // タイプでフィルタリング（フィルター選択時のみ）
            if let filter = selectedFilter {
                let type = activity.value(forKey: "type") as? String ?? ""
                return isSameDay && type.lowercased() == filter.rawValue.lowercased()
            }
            
            return isSameDay
        }
    }
    
    // 活動削除
    private func deleteActivity(at offsets: IndexSet) {
        for index in offsets {
            let activity = activitiesForSelectedDate[index]
            activityViewModel.deleteActivity(activity)
        }
    }
}

// シンプル化された活動行
struct SimplifiedActivityRow: View {
    let activity: NSManagedObject
    
    var body: some View {
        HStack(spacing: 15) {
            // アイコン
            ZStack {
                Circle()
                    .fill(activityTypeColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: activityTypeIcon)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activityTitle)
                    .font(.headline)
                
                Text(activity.value(forKey: "location") as? String ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // シンプル化された評価表示
            if let rating = activity.value(forKey: "rating") as? Int, rating > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("\(rating)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // 活動タイプに基づくタイトル
    private var activityTitle: String {
        let type = activity.value(forKey: "type") as? String ?? ""
        
        if type == "match" {
            // 試合の場合は対戦相手を表示
            if let id = activity.value(forKey: "id") as? UUID,
               let context = activity.managedObjectContext {
                let request = NSFetchRequest<NSManagedObject>(entityName: "Match")
                request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
                request.fetchLimit = 1
                
                if let matches = try? context.fetch(request),
                   let match = matches.first,
                   let opponent = match.value(forKey: "opponent") as? String {
                    return "試合：\(opponent)"
                }
            }
            return "試合"
        } else {
            // 練習の場合はフォーカスエリアを表示
            if let id = activity.value(forKey: "id") as? UUID,
               let context = activity.managedObjectContext {
                let request = NSFetchRequest<NSManagedObject>(entityName: "Practice")
                request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
                request.fetchLimit = 1
                
                if let practices = try? context.fetch(request),
                   let practice = practices.first,
                   let focus = practice.value(forKey: "focus") as? String {
                    return "練習：\(focus)"
                }
            }
            return "練習"
        }
    }
    
    // アイコン
    private var activityTypeIcon: String {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? "sportscourt.fill" : "figure.walk"
    }
    
    // 色
    private var activityTypeColor: Color {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? .orange : .green
    }
}

// コンパクトカレンダービュー
struct CompactCalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth = Date()
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
    
    var body: some View {
        VStack(spacing: 8) {
            // カレンダーヘッダー
            HStack {
                Button(action: {
                    withAnimation {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppDesign.primaryColor)
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
                        .foregroundColor(AppDesign.primaryColor)
                }
            }
            
            // 曜日ヘッダー
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(day == "日" ? .red : .primary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 日付グリッド
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if date.isPlaceholder {
                        Text("")
                            .frame(height: 35)
                    } else {
                        Button(action: {
                            selectedDate = date.date
                        }) {
                            Text("\(Calendar.current.component(.day, from: date.date))")
                                .font(.system(size: 14))
                                .frame(height: 35)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Circle()
                                        .fill(isSelectedDate(date.date) ? AppDesign.primaryColor :
                                                isToday(date.date) ? Color.gray.opacity(0.3) : Color.clear)
                                        .frame(width: 35, height: 35)
                                )
                                .foregroundColor(isSelectedDate(date.date) ? .white :
                                                isToday(date.date) ? .primary :
                                                Calendar.current.component(.weekday, from: date.date) == 1 ? .red : .primary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 月と年のテキスト
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentMonth)
    }
    
    // 月の日付取得
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
    
    // 選択された日付かどうか
    private func isSelectedDate(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    // 今日かどうか
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

// カレンダー用の日付構造体
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
