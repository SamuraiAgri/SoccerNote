import Foundation
import CoreData
import SwiftUI

class PracticeViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var practices: [NSManagedObject] = []
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchPractices()
    }
    
    func fetchPractices() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Practice")
        let activitySort = NSSortDescriptor(key: "activity.date", ascending: false)
        request.sortDescriptors = [activitySort]
        
        do {
            practices = try viewContext.fetch(request)
        } catch {
            print("練習の取得に失敗: \(error)")
        }
    }
    
    func savePractice(activity: NSManagedObject, focus: String, duration: Int, intensity: Int, learnings: String) {
        let practice = NSEntityDescription.insertNewObject(forEntityName: "Practice", into: viewContext)
        
        practice.setValue(focus, forKey: "focus")
        practice.setValue(duration, forKey: "duration")
        practice.setValue(intensity, forKey: "intensity")
        practice.setValue(learnings, forKey: "learnings")
        practice.setValue(UUID(), forKey: "id")
        practice.setValue(activity, forKey: "activity")
        
        do {
            try viewContext.save()
            fetchPractices()
        } catch {
            let nsError = error as NSError
            print("練習の保存に失敗: \(nsError)")
        }
    }
    
    func deletePractice(_ practice: NSManagedObject) {
        viewContext.delete(practice)
        
        do {
            try viewContext.save()
            fetchPractices()
        } catch {
            let nsError = error as NSError
            print("練習の削除に失敗: \(nsError)")
        }
    }
    
    // 統計データの取得メソッド
    func getStatistics() -> (totalDuration: Int, averageIntensity: Double) {
        var totalDuration = 0
        var totalIntensity = 0
        
        for practice in practices {
            totalDuration += practice.value(forKey: "duration") as? Int ?? 0
            totalIntensity += practice.value(forKey: "intensity") as? Int ?? 0
        }
        
        let averageIntensity = practices.isEmpty ? 0.0 : Double(totalIntensity) / Double(practices.count)
        
        return (totalDuration, averageIntensity)
    }
}
