// SoccerNote/Views/Home/HomeView.swift
import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var activityViewModel = ActivityViewModel(viewContext: PersistenceController.shared.container.viewContext)
    
    // タブ選択マネージャーを環境オブジェクトとして取得
    @EnvironmentObject private var tabSelectionManager: TabSelectionManager
    
    // 選択された日付
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 月間カレンダー
                    CalendarView(selectedDate: $selectedDate, activityViewModel: activityViewModel)
                        .frame(height: 320)
                        .padding(.top)
                        .padding(.horizontal)
                    
                    // 選択日の記録
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(formattedSelectedDate)
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if activitiesForSelectedDate.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 30))
                                    .foregroundColor(Color.appPrimary)
                                
                                Text("この日の記録はありません")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    // タブを記録タブ(インデックス1)に切り替え
                                    tabSelectionManager.selectedTab = 1
                                    
                                    // 選択された日付を保存（記録追加画面で使用するため）
                                    UserDefaults.standard.set(selectedDate.timeIntervalSince1970, forKey: "SelectedDateForNewRecord")
                                }) {
                                    Text("記録を追加")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.appPrimary)
                                        .cornerRadius(10)
                                }
                            }
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        } else {
                            ForEach(activitiesForSelectedDate, id: \.self) { activity in
                                NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                    ActivityRowCard(activity: activity)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 最近の活動
                    VStack(alignment: .leading, spacing: 10) {
                        Text("最近の活動")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if activityViewModel.recentActivities.isEmpty {
                            Text("最近の活動はありません")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(activityViewModel.recentActivities.prefix(5), id: \.self) { activity in
                                        RecentActivityCard(activity: activity)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("サッカーノート")
            .onAppear {
                activityViewModel.fetchActivities()
            }
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
    
    // 選択された日付の活動一覧
    private var activitiesForSelectedDate: [NSManagedObject] {
        let calendar = Calendar.current
        
        return activityViewModel.activities.filter { activity in
            guard let activityDate = activity.value(forKey: "date") as? Date else { return false }
            return calendar.isDate(activityDate, inSameDayAs: selectedDate)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TabSelectionManager())
    }
}
