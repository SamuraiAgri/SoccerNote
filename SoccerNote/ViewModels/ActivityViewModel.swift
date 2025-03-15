// SoccerNote/ViewModels/ActivityViewModel.swift
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

// SoccerNote/ViewModels/MatchViewModel.swift
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

// SoccerNote/ViewModels/PracticeViewModel.swift
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

// SoccerNote/ViewModels/GoalViewModel.swift
import Foundation
import CoreData
import SwiftUI

class GoalViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var goals: [NSManagedObject] = []
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchGoals()
    }
    
    func fetchGoals() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Goal")
        request.sortDescriptors = [NSSortDescriptor(key: "deadline", ascending: true)]
        
        do {
            goals = try viewContext.fetch(request)
        } catch {
            print("目標の取得に失敗: \(error)")
        }
    }
    
    func saveGoal(title: String, description: String, deadline: Date, progress: Int = 0) {
        let goal = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: viewContext)
        
        goal.setValue(title, forKey: "title")
        goal.setValue(description, forKey: "description")
        goal.setValue(deadline, forKey: "deadline")
        goal.setValue(false, forKey: "isCompleted")
        goal.setValue(progress, forKey: "progress")
        goal.setValue(Date(), forKey: "creationDate")
        goal.setValue(UUID(), forKey: "id")
        
        do {
            try viewContext.save()
            fetchGoals()
        } catch {
            let nsError = error as NSError
            print("目標の保存に失敗: \(nsError)")
        }
    }
    
    func updateGoalProgress(_ goal: NSManagedObject, progress: Int, isCompleted: Bool = false) {
        goal.setValue(progress, forKey: "progress")
        goal.setValue(isCompleted, forKey: "isCompleted")
        
        do {
            try viewContext.save()
            fetchGoals()
        } catch {
            let nsError = error as NSError
            print("目標の更新に失敗: \(nsError)")
        }
    }
    
    func deleteGoal(_ goal: NSManagedObject) {
        viewContext.delete(goal)
        
        do {
            try viewContext.save()
            fetchGoals()
        } catch {
            let nsError = error as NSError
            print("目標の削除に失敗: \(nsError)")
        }
    }
}
