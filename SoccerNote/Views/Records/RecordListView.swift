// SoccerNote/Views/Records/RecordListView.swift
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

// SoccerNote/Views/Records/FilterButton.swift
import SwiftUI

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? AppDesign.primaryColor : AppDesign.secondaryBackground)
                .foregroundColor(isSelected ? .white : AppDesign.primaryText)
                .cornerRadius(20)
        }
    }
}

// SoccerNote/Views/Records/ActivityRow.swift
import SwiftUI
import CoreData

struct ActivityRow: View {
    let activity: NSManagedObject
    
    var body: some View {
        HStack {
            // アイコン
            ZStack {
                Circle()
                    .fill(activityTypeColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: activityTypeIcon)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(activityTypeText)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(AppDesign.secondaryText)
                }
                
                Text(activity.value(forKey: "location") as? String ?? "")
                    .font(.subheadline)
                
                // 評価スター
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= (activity.value(forKey: "rating") as? Int ?? 0) ? AppIcons.Rating.starFill : AppIcons.Rating.star)
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    // ヘルパープロパティ
    private var activityTypeText: String {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? "試合" : "練習"
    }
    
    private var activityTypeIcon: String {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? AppIcons.Activity.match : AppIcons.Activity.practice
    }
    
    private var activityTypeColor: Color {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? AppDesign.secondaryColor : AppDesign.primaryColor
    }
    
    private var formattedDate: String {
        let date = activity.value(forKey: "date") as? Date ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

// SoccerNote/Views/Records/ActivityDetailView.swift
import SwiftUI
import CoreData

struct ActivityDetailView: View {
    let activity: NSManagedObject
    
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDesign.Spacing.medium) {
                // ヘッダー
                HStack {
                    VStack(alignment: .leading) {
                        Text(activityTypeText)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundColor(AppDesign.secondaryText)
                    }
                    
                    Spacer()
                    
                    // 評価スター
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= (activity.value(forKey: "rating") as? Int ?? 0) ? AppIcons.Rating.starFill : AppIcons.Rating.star)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Divider()
                
                // 基本情報
                Group {
                    DetailRow(title: "場所", value: activity.value(forKey: "location") as? String ?? "")
                    
                    DetailRow(title: "メモ", value: activity.value(forKey: "notes") as? String ?? "")
                }
                
                Divider()
                
                // 詳細情報（試合または練習）
                if let type = activity.value(forKey: "type") as? String, type == "match" {
                    // 試合詳細を表示
                    if let matchDetails = fetchMatchDetails() {
                        Group {
                            DetailRow(title: "対戦相手", value: matchDetails.value(forKey: "opponent") as? String ?? "")
                            
                            DetailRow(title: "スコア", value: matchDetails.value(forKey: "score") as? String ?? "")
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("ゴール")
                                        .font(.headline)
                                    
                                    Text("\(matchDetails.value(forKey: "goalsScored") as? Int ?? 0)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(alignment: .leading) {
                                    Text("アシスト")
                                        .font(.headline)
                                    
                                    Text("\(matchDetails.value(forKey: "assists") as? Int ?? 0)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            DetailRow(title: "出場時間", value: "\(matchDetails.value(forKey: "playingTime") as? Int ?? 0)分")
                            
                            DetailRow(title: "パフォーマンス評価", value: "\(matchDetails.value(forKey: "performance") as? Int ?? 0)/10")
                        }
                    }
                } else {
                    // 練習詳細を表示
                    if let practiceDetails = fetchPracticeDetails() {
                        Group {
                            DetailRow(title: "フォーカスエリア", value: practiceDetails.value(forKey: "focus") as? String ?? "")
                            
                            DetailRow(title: "練習時間", value: "\(practiceDetails.value(forKey: "duration") as? Int ?? 0)分")
                            
                            Text("練習強度")
                                .font(.headline)
                            
                            HStack {
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= (practiceDetails.value(forKey: "intensity") as? Int ?? 0) ? AppIcons.Rating.circleFill : AppIcons.Rating.circle)
                                        .foregroundColor(AppDesign.primaryColor)
                                }
                            }
                            
                            DetailRow(title: "学んだこと", value: practiceDetails.value(forKey: "learnings") as? String ?? "")
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("詳細", displayMode: .inline)
        .navigationBarItems(trailing: Button("編集") {
            showingEditSheet = true
        })
        .sheet(isPresented: $showingEditSheet) {
            // 編集画面を表示
            if let type = activity.value(forKey: "type") as? String, type == "match" {
                EditMatchView(activity: activity)
            } else {
                EditPracticeView(activity: activity)
            }
        }
    }
    
    // 試合詳細の取得
    private func fetchMatchDetails() -> NSManagedObject? {
        guard let id = activity.value(forKey: "id") as? UUID else { return nil }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Match")
        request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let context = activity.managedObjectContext!
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("試合詳細の取得に失敗: \(error)")
            return nil
        }
    }
    
    // 練習詳細の取得
    private func fetchPracticeDetails() -> NSManagedObject? {
        guard let id = activity.value(forKey: "id") as? UUID else { return nil }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Practice")
        request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let context = activity.managedObjectContext!
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("練習詳細の取得に失敗: \(error)")
            return nil
        }
    }
    
    // ヘルパープロパティ
    private var activityTypeText: String {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? "試合" : "練習"
    }
    
    private var formattedDate: String {
        let date = activity.value(forKey: "date") as? Date ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

// SoccerNote/Views/Components/DetailRow.swift
import SwiftUI

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            
            Text(value)
                .font(.body)
                .padding(.bottom, 5)
        }
    }
}

// SoccerNote/Views/Records/EditMatchView.swift
import SwiftUI
import CoreData

struct EditMatchView: View {
    @Environment(\.presentationMode) var presentationMode
    let activity: NSManagedObject
    
    // 詳細な編集実装はこのアプリのスコープ外なので、
    // シンプルな画面としてプレースホルダーを実装します
    
    var body: some View {
        NavigationView {
            Text("試合記録編集機能は今後実装予定です")
                .padding()
                .navigationTitle("試合記録編集")
                .navigationBarItems(trailing: Button("閉じる") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

// SoccerNote/Views/Records/EditPracticeView.swift
import SwiftUI
import CoreData

struct EditPracticeView: View {
    @Environment(\.presentationMode) var presentationMode
    let activity: NSManagedObject
    
    // 詳細な編集実装はこのアプリのスコープ外なので、
    // シンプルな画面としてプレースホルダーを実装します
    
    var body: some View {
        NavigationView {
            Text("練習記録編集機能は今後実装予定です")
                .padding()
                .navigationTitle("練習記録編集")
                .navigationBarItems(trailing: Button("閉じる") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}
