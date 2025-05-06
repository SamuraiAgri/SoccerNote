// SoccerNote/Views/Records/SimplifiedActivityRow.swift
import SwiftUI
import CoreData

struct SimplifiedActivityRow: View {
    let activity: NSManagedObject
    
    var body: some View {
        HStack(spacing: 12) {
            // アクティビティタイプアイコン
            ZStack {
                Circle()
                    .fill(activityTypeColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: activityTypeIcon)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activityTypeText)
                    .font(.headline)
                
                Text(activity.value(forKey: "location") as? String ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 評価スターの表示
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= (activity.value(forKey: "rating") as? Int ?? 0) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 10))
                }
            }
        }
        .padding(.vertical, 4)
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
        return type == "match" ? Color.orange : AppDesign.primaryColor
    }
}

#Preview("活動行", traits: .sizeThatFits) {
    let context = PersistenceController.preview.container.viewContext
    let request = NSFetchRequest<NSManagedObject>(entityName: "Activity")
    let activities = try! context.fetch(request)
    return SimplifiedActivityRow(activity: activities.first!)
        .padding()
}
