// SoccerNote/Views/Records/RecordListView.swift
import SwiftUI
import CoreData

struct RecordListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var activityViewModel: ActivityViewModel
    
    @State private var searchText = ""
    @State private var selectedFilter: ActivityType?
    @State private var showingDeleteConfirmation = false
    @State private var activityToDelete: NSManagedObject?
    @State private var showingFilterSheet = false
    
    // 高度なフィルター
    @State private var selectedRating: Int?
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var isUsingDateFilter = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バーとフィルターオプション
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: AppIcons.Function.search)
                            .foregroundColor(AppDesign.secondaryText)
                        
                        TextField("検索", text: $searchText)
                            .disableAutocorrection(true)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppDesign.secondaryText)
                            }
                        }
                    }
                    .padding(8)
                    .background(AppDesign.secondaryBackground)
                    .cornerRadius(AppDesign.CornerRadius.medium)
                    
                    // フィルターボタン
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button(action: {
                                withAnimation {
                                    selectedFilter = nil
                                }
                            }) {
                                Text("すべて")
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == nil ? AppDesign.primaryColor : AppDesign.secondaryBackground)
                                    .foregroundColor(selectedFilter == nil ? .white : AppDesign.primaryText)
                                    .cornerRadius(20)
                            }
                            
                            ForEach(ActivityType.allCases) { type in
                                Button(action: {
                                    withAnimation {
                                        selectedFilter = type
                                    }
                                }) {
                                    Text(type.rawValue)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(selectedFilter == type ? AppDesign.primaryColor : AppDesign.secondaryBackground)
                                        .foregroundColor(selectedFilter == type ? .white : AppDesign.primaryText)
                                        .cornerRadius(20)
                                }
                            }
                            
                            // 詳細フィルターボタン
                            Button(action: {
                                showingFilterSheet = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                    Text("詳細")
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(hasActiveFilters ? AppDesign.primaryColor : AppDesign.secondaryBackground)
                                .foregroundColor(hasActiveFilters ? .white : AppDesign.primaryText)
                                .cornerRadius(20)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .background(Color(UIColor.systemBackground))
                
                // 記録リスト
                if filteredActivities.isEmpty {
                    EmptyStateView(
                        title: "記録がありません",
                        message: "「追加」タブから新しい記録を追加しましょう",
                        icon: "note.text",
                        buttonTitle: "記録を追加",
                        buttonAction: {
                            // タブを「追加」タブに切り替える処理
                            // MainTabViewのタブ選択を制御する仕組みが必要
                            if let window = UIApplication.shared.windows.first {
                                if let tabBarController = window.rootViewController as? UITabBarController {
                                    tabBarController.selectedIndex = 1
                                }
                            }
                        }
                    )
                    .padding(.top, 50)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                } else {
                    List {
                        ForEach(filteredActivities, id: \.self) { activity in
                            NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                ActivityRow(activity: activity)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    activityToDelete = activity
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("記録履歴")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: EditButton())
            .onAppear {
                activityViewModel.fetchActivities()
            }
            .alert("記録を削除", isPresented: $showingDeleteConfirmation) {
                Button("キャンセル", role: .cancel) {
                    activityToDelete = nil
                }
                Button("削除", role: .destructive) {
                    if let activity = activityToDelete {
                        withAnimation {
                            activityViewModel.deleteActivity(activity)
                        }
                        activityToDelete = nil
                    }
                }
            } message: {
                Text("この記録を削除してもよろしいですか？この操作は取り消せません。")
            }
            .sheet(isPresented: $showingFilterSheet) {
                AdvancedFilterSheet(
                    selectedRating: $selectedRating,
                    startDate: $startDate,
                    endDate: $endDate,
                    isUsingDateFilter: $isUsingDateFilter
                )
            }
        }
    }
    
    // 詳細フィルターが有効かどうか
    private var hasActiveFilters: Bool {
        return selectedRating != nil || isUsingDateFilter
    }
    
    // フィルタリングされた活動リスト
    private var filteredActivities: [NSManagedObject] {
        var activities = activityViewModel.activities
        
        // タイプでフィルタリング
        if let filter = selectedFilter {
            activities = activities.filter { activity in
                let type = activity.value(forKey: "type") as? String ?? ""
                return type.lowercased() == filter.rawValue.lowercased()
            }
        }
        
        // 検索テキストでフィルタリング
        if !searchText.isEmpty {
            activities = activities.filter { activity in
                let location = activity.value(forKey: "location") as? String ?? ""
                let notes = activity.value(forKey: "notes") as? String ?? ""
                
                return location.lowercased().contains(searchText.lowercased()) ||
                       notes.lowercased().contains(searchText.lowercased())
            }
        }
        
        // 評価でフィルタリング
        if let rating = selectedRating {
            activities = activities.filter { activity in
                let activityRating = activity.value(forKey: "rating") as? Int ?? 0
                return activityRating == rating
            }
        }
        
        // 日付範囲でフィルタリング
        if isUsingDateFilter {
            activities = activities.filter { activity in
                guard let date = activity.value(forKey: "date") as? Date else { return false }
                
                if let start = startDate, let end = endDate {
                    return date >= start && date <= end
                } else if let start = startDate {
                    return date >= start
                } else if let end = endDate {
                    return date <= end
                }
                return true
            }
        }
        
        return activities
    }
}

// 詳細フィルターシート
struct AdvancedFilterSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedRating: Int?
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var isUsingDateFilter: Bool
    
    @State private var tempStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var tempEndDate: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("評価フィルター")) {
                    HStack {
                        Text("評価")
                        Spacer()
                        
                        ForEach(1...5, id: \.self) { rating in
                            Button(action: {
                                HapticFeedback.selection()
                                if selectedRating == rating {
                                    selectedRating = nil
                                } else {
                                    selectedRating = rating
                                }
                            }) {
                                Image(systemName: selectedRating == rating ? "star.fill" : "star")
                                    .foregroundColor(selectedRating == rating ? .yellow : .gray)
                                    .font(.system(size: 24))
                            }
                        }
                    }
                    
                    if selectedRating != nil {
                        Button(action: {
                            HapticFeedback.light()
                            selectedRating = nil
                        }) {
                            Text("評価フィルターをクリア")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("日付範囲フィルター")) {
                    Toggle("日付範囲を指定", isOn: $isUsingDateFilter)
                        .onChange(of: isUsingDateFilter) { _, newValue in
                            if newValue {
                                startDate = tempStartDate
                                endDate = tempEndDate
                            } else {
                                startDate = nil
                                endDate = nil
                            }
                        }
                    
                    if isUsingDateFilter {
                        DatePicker("開始日", selection: $tempStartDate, displayedComponents: .date)
                            .onChange(of: tempStartDate) { _, newValue in
                                startDate = newValue
                            }
                        
                        DatePicker("終了日", selection: $tempEndDate, displayedComponents: .date)
                            .onChange(of: tempEndDate) { _, newValue in
                                endDate = newValue
                            }
                    }
                }
                
                Section {
                    Button(action: {
                        HapticFeedback.light()
                        selectedRating = nil
                        isUsingDateFilter = false
                        startDate = nil
                        endDate = nil
                    }) {
                        HStack {
                            Spacer()
                            Text("すべてのフィルターをクリア")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("詳細フィルター")
            .navigationBarItems(
                trailing: Button("完了") {
                    HapticFeedback.light()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
