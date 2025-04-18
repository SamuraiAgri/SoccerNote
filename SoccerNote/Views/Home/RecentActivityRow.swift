// SoccerNote/Views/Home/RecentActivityRow.swift
import SwiftUI
import CoreData

struct RecentActivityRow: View {
    let activity: NSManagedObject
    
    var body: some View {
        NavigationLink(destination: ActivityDetailView(activity: activity)) {
            HStack {
                // アクティビティタイプのアイコン
                ZStack {
                    Circle()
                        .fill(activityTypeColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: activityTypeIcon)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading) {
                    Text(activityTypeText)
                        .font(.appHeadline())
                    
                    Text(formattedDate)
                        .font(.appCaption())
                        .foregroundColor(AppDesign.secondaryText)
                }
                
                Spacer()
                
                // 評価スター
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= (activity.value(forKey: "rating") as? Int ?? 0) ? AppIcons.Rating.starFill : AppIcons.Rating.star)
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(AppDesign.secondaryBackground)
            .cornerRadius(AppDesign.CornerRadius.medium)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
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
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let request = NSFetchRequest<NSManagedObject>(entityName: "Activity")
    let activities = try! context.fetch(request)
    return RecentActivityRow(activity: activities.first!)
}
