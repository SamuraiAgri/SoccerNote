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
                    // カレンダービュー - 引数エラーを修正
                    CalendarView(selectedDate: $selectedDate)
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
                    if activityViewModel.isLoading {
                        Spacer()
                        LoadingView()
                        Spacer()
                    } else if activitiesForSelectedDate.isEmpty {
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
                                    ActivityRow(activity: activity)
                                }
                            }
                            .onDelete(perform: deleteActivity)
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            // Pull to refresh
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
                QuickAddView(date: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onChange(of: activityViewModel.errorMessage) { _, newValue in
                showingErrorBanner = newValue != nil
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
        let activitiesToDelete = offsets.map { activitiesForSelectedDate[$0] }
        
        // 確認ダイアログを表示（実際のアプリではここにアラートを追加するとよい）
        for activity in activitiesToDelete {
            activityViewModel.deleteActivity(activity)
        }
    }
}
