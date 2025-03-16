import Foundation
import CoreData
import SwiftUI

class ActivityViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var activities: [NSManagedObject] = []
    @Published var recentActivities: [NSManagedObject] = []
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchActivities()
    }
    
    func fetchActivities() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Activity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Activity.date, ascending: false)]
        
        do {
            activities = try viewContext.fetch(request)
            
            // 最近の活動（最大5件）を取得
            let recentRequest = NSFetchRequest<NSManagedObject>(entityName: "Activity")
            recentRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Activity.date, ascending: false)]
            recentRequest.fetchLimit = 5
            recentActivities = try viewContext.fetch(recentRequest)
        } catch {
            print("活動の取得に失敗: \(error)")
        }
    }
    
    func saveActivity(type: ActivityType, date: Date, location: String, notes: String, rating: Int) -> NSManagedObject? {
        let activity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: viewContext)
        
        activity.setValue(date, forKey: "date")
        activity.setValue(type.rawValue.lowercased(), forKey: "type")
        activity.setValue(location, forKey: "location")
        activity.setValue(notes, forKey: "notes")
        activity.setValue(rating, forKey: "rating")
        activity.setValue(UUID(), forKey: "id")
        
        do {
            try viewContext.save()
            fetchActivities()
            return activity
        } catch {
            let nsError = error as NSError
            print("活動の保存に失敗: \(nsError)")
            return nil
        }
    }
    
    func deleteActivity(_ activity: NSManagedObject) {
        viewContext.delete(activity)
        
        do {
            try viewContext.save()
            fetchActivities()
        } catch {
            let nsError = error as NSError
            print("活動の削除に失敗: \(nsError)")
        }
    }
}
