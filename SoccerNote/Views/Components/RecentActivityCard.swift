// SoccerNote/Views/Components/RecentActivityCard.swift
import SwiftUI
import CoreData

struct RecentActivityCard: View {
    let activity: NSManagedObject
    
    var body: some View {
        NavigationLink(destination: ActivityDetailView(activity: activity)) {
            VStack(alignment: .leading, spacing: 8) {
                // アクティビティタイプアイコン
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(activityTypeColor)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: activityTypeIcon)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                    }
                    
                    Text(activityTypeText)
                        .font(.headline)
                }
                
                Text(activity.value(forKey: "location") as? String ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(width: 170, height: 130)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.appShadow, radius: 3, x: 0, y: 1)
        }
    }
    
    // ヘルパープロパティ
    private var activityTypeText: String {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? "試合" : "練習"
    }
    
    private var activityTypeIcon: String {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? "sportscourt.fill" : "figure.walk"
    }
    
    private var activityTypeColor: Color {
        let type = activity.value(forKey: "type") as? String ?? ""
        return type == "match" ? Color.appSecondary : Color.appPrimary
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

struct RecentActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Activity")
        let activities = try! context.fetch(request)
        
        return RecentActivityCard(activity: activities.first!)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
