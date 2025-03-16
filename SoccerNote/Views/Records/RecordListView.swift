import SwiftUI
import CoreData

struct RecordListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var activityViewModel: ActivityViewModel
    
    @State private var searchText = ""
    @State private var selectedFilter: ActivityType?
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _activityViewModel = StateObject(wrappedValue: ActivityViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 検索バーとフィルターオプション
                VStack {
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
                            FilterButton(title: "すべて", isSelected: selectedFilter == nil) {
                                selectedFilter = nil
                            }
                            
                            ForEach(ActivityType.allCases) { type in
                                FilterButton(title: type.rawValue, isSelected: selectedFilter == type) {
                                    selectedFilter = type
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding(.horizontal)
                
                // 記録リスト
                if filteredActivities.isEmpty {
                    EmptyStateView(
                        title: "記録がありません",
                        message: "「追加」タブから新しい記録を追加しましょう",
                        icon: "note.text",
                        buttonTitle: "記録を追加",
                        buttonAction: {
                            // タブインデックスを「追加」タブに変更するアクション
                            // 実際の実装ではタブインデックスを変更する方法を追加する必要があります
                        }
                    )
                } else {
                    List {
                        ForEach(filteredActivities, id: \.self) { activity in
                            NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                ActivityRow(activity: activity)
                            }
                        }
                        .onDelete(perform: deleteActivities)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("記録履歴")
            .navigationBarItems(trailing: EditButton())
            .onAppear {
                activityViewModel.fetchActivities()
            }
        }
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
        
        return activities
    }
    
    // 削除処理
    private func deleteActivities(at offsets: IndexSet) {
        for index in offsets {
            let activity = filteredActivities[index]
            activityViewModel.deleteActivity(activity)
        }
    }
}
