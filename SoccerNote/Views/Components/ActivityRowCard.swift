// SoccerNote/Views/Components/ActivityRowCard.swift
import SwiftUI
import CoreData

struct ActivityRowCard: View {
    let activity: NSManagedObject
    
    var body: some View {
        HStack(spacing: 15) {
            // アクティビティタイプアイコン
            ZStack {
                Circle()
                    .fill(activityTypeColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: activityTypeIcon)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activityTypeText)
                    .font(.headline)
                
                Text(activity.value(forKey: "location") as? String ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // 評価スター
                HStack(spacing: 3) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= (activity.value(forKey: "rating") as? Int ?? 0) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 10))
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.appShadow, radius: 2, x: 0, y: 1)
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
}

struct ActivityRowCard_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Activity")
        let activities = try! context.fetch(request)
        
        return ActivityRowCard(activity: activities.first!)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
