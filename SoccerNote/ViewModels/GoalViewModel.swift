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
