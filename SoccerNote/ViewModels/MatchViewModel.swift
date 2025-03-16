import Foundation
import CoreData
import SwiftUI

class MatchViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var matches: [NSManagedObject] = []
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchMatches()
    }
    
    func fetchMatches() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Match")
        let activitySort = NSSortDescriptor(key: "activity.date", ascending: false)
        request.sortDescriptors = [activitySort]
        
        do {
            matches = try viewContext.fetch(request)
        } catch {
            print("試合の取得に失敗: \(error)")
        }
    }
    
    func saveMatch(activity: NSManagedObject, opponent: String, score: String, goalsScored: Int, assists: Int, playingTime: Int, performance: Int, photos: Data? = nil) {
        let match = NSEntityDescription.insertNewObject(forEntityName: "Match", into: viewContext)
        
        match.setValue(opponent, forKey: "opponent")
        match.setValue(score, forKey: "score")
        match.setValue(goalsScored, forKey: "goalsScored")
        match.setValue(assists, forKey: "assists")
        match.setValue(playingTime, forKey: "playingTime")
        match.setValue(performance, forKey: "performance")
        match.setValue(photos, forKey: "photos")
        match.setValue(UUID(), forKey: "id")
        match.setValue(activity, forKey: "activity")
        
        do {
            try viewContext.save()
            fetchMatches()
        } catch {
            let nsError = error as NSError
            print("試合の保存に失敗: \(nsError)")
        }
    }
    
    func deleteMatch(_ match: NSManagedObject) {
        viewContext.delete(match)
        
        do {
            try viewContext.save()
            fetchMatches()
        } catch {
            let nsError = error as NSError
            print("試合の削除に失敗: \(nsError)")
        }
    }
    
    // 統計データの取得メソッド
    func getStatistics() -> (totalGoals: Int, totalAssists: Int, averagePerformance: Double) {
        var totalGoals = 0
        var totalAssists = 0
        var totalPerformance = 0
        
        for match in matches {
            totalGoals += match.value(forKey: "goalsScored") as? Int ?? 0
            totalAssists += match.value(forKey: "assists") as? Int ?? 0
            totalPerformance += match.value(forKey: "performance") as? Int ?? 0
        }
        
        let averagePerformance = matches.isEmpty ? 0.0 : Double(totalPerformance) / Double(matches.count)
        
        return (totalGoals, totalAssists, averagePerformance)
    }
}
