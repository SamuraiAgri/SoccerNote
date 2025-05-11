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
    
    // エラー表示用
    @State private var showingErrorBanner = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // カレンダービュー - activityViewModelを渡す
                    CalendarView(selectedDate: $selectedDate, activityViewModel: activityViewModel)
                        .frame(height: 350)
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
                                .foregroundColor(Color.appPrimary)
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
                                    .background(selectedFilter == nil ? Color.appPrimary : Color.gray.opacity(0.2))
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
                                        .background(selectedFilter == type ? Color.appPrimary : Color.gray.opacity(0.2))
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
                    if activityViewModel.isLoading {
                        Spacer()
                        LoadingView()
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
                                    ActivityRowCard(activity: activity)
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
                
                // エラーバナー
                if let errorMessage = activityViewModel.errorMessage, showingErrorBanner {
                    VStack {
                        ErrorBanner(message: errorMessage) {
                            showingErrorBanner = false
                            activityViewModel.errorMessage = nil
                        }
                        .padding(.top)
                        
                        Spacer()
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
                            .foregroundColor(Color.appPrimary)
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

struct RecordsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        RecordsHomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AddSheetController())
    }
}
