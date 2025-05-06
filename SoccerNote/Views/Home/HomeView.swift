// SoccerNote/Views/Home/HomeView.swift
import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var addSheetController: AddSheetController
    @StateObject private var activityViewModel = ActivityViewModel(viewContext: PersistenceController.shared.container.viewContext)
    
    @State private var selectedDate = Date()
    @State private var showingFilterOptions = false
    @State private var selectedFilter: ActivityType?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // カレンダービュー
                CalendarView(selectedDate: $selectedDate)
                    .frame(height: 320)
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
                        HStack {
                            Text(filterButtonText)
                                .font(.subheadline)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .rotationEffect(.degrees(showingFilterOptions ? 180 : 0))
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // フィルターオプション（表示/非表示）
                if showingFilterOptions {
                    HStack(spacing: 10) {
                        Button(action: {
                            selectedFilter = nil
                            showingFilterOptions = false
                        }) {
                            Text("すべて")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedFilter == nil ? AppDesign.primaryColor : Color.gray.opacity(0.1))
                                .foregroundColor(selectedFilter == nil ? .white : .primary)
                                .cornerRadius(8)
                        }
                        
                        ForEach(ActivityType.allCases) { type in
                            Button(action: {
                                selectedFilter = type
                                showingFilterOptions = false
                            }) {
                                Text(type.rawValue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedFilter == type ? AppDesign.primaryColor : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedFilter == type ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: showingFilterOptions)
                }
                
                // 選択した日の記録一覧
                if activityViewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if activitiesForSelectedDate.isEmpty {
                    EmptyStateView(
                        title: "この日の記録はありません",
                        message: "タップして新しい記録を追加しましょう",
                        icon: "note.text",
                        buttonTitle: "記録を追加",
                        buttonAction: {
                            addSheetController.showAddSheet(for: selectedDate)
                        }
                    )
                    .padding(.top, 30)
                } else {
                    List {
                        ForEach(activitiesForSelectedDate, id: \.self) { activity in
                            NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                ActivityRow(activity: activity)
                            }
                        }
                        .onDelete(perform: deleteActivity)
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        activityViewModel.fetchActivities()
                    }
                }
            }
            .navigationTitle("サッカーノート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        addSheetController.showAddSheet(for: selectedDate)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(AppDesign.primaryColor)
                    }
                }
            }
            .onAppear {
                activityViewModel.fetchActivities()
            }
        }
    }
    
    // 選択された日付のフォーマット
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: selectedDate)
    }
    
    // フィルターボタンのテキスト
    private var filterButtonText: String {
        if let filter = selectedFilter {
            return filter.rawValue
        } else {
            return "すべて"
        }
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
        let activitiesToDelete = offsets.map { activitiesForSelectedDate[$0] }
        
        for activity in activitiesToDelete {
            activityViewModel.deleteActivity(activity)
        }
    }
}
