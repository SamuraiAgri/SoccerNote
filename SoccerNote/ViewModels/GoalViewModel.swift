// SoccerNote/ViewModels/GoalViewModel.swift
import Foundation
import CoreData
import SwiftUI
import Combine

class GoalViewModel: ObservableObject {
    private let persistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var goals: [NSManagedObject] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    init(viewContext: NSManagedObjectContext, persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.viewContext = viewContext
        fetchGoals()
        
        // 変更通知を監視して自動更新
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchGoals()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchGoals() {
        isLoading = true
        errorMessage = nil
        
        let backgroundContext = persistenceController.newBackgroundContext()
        
        backgroundContext.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Goal")
            request.sortDescriptors = [NSSortDescriptor(key: "deadline", ascending: true)]
            request.fetchBatchSize = 20
            
            do {
                let fetchedGoals = try backgroundContext.fetch(request)
                let goalIDs = fetchedGoals.map { $0.objectID }
                
                DispatchQueue.main.async {
                    self.goals = goalIDs.map { self.viewContext.object(with: $0) }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "目標データの取得に失敗しました"
                    self.isLoading = false
                }
                print("目標の取得に失敗: \(error)")
            }
        }
    }
    
    func saveGoal(title: String, description: String, deadline: Date, progress: Int = 0) {
        isLoading = true
        errorMessage = nil
        
        // 入力検証
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "タイトルは必須項目です"
                self.isLoading = false
            }
            return
        }
        
        let backgroundContext = persistenceController.newBackgroundContext()
        
        backgroundContext.perform {
            let goal = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: backgroundContext)
            
            goal.setValue(trimmedTitle, forKey: "title")
            goal.setValue(description, forKey: "goalDescription")
            goal.setValue(deadline, forKey: "deadline")
            goal.setValue(false, forKey: "isCompleted")
            goal.setValue(max(0, min(100, progress)), forKey: "progress") // 0-100の範囲に制限
            goal.setValue(Date(), forKey: "creationDate")
            goal.setValue(UUID(), forKey: "id")
            
            do {
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    self.fetchGoals()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "目標の保存に失敗しました: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("目標の保存に失敗: \(error)")
            }
        }
    }
    
    func updateGoalProgress(_ goal: NSManagedObject, progress: Int, isCompleted: Bool = false) {
        isLoading = true
        errorMessage = nil
        
        let backgroundContext = persistenceController.newBackgroundContext()
        let goalID = goal.objectID
        
        backgroundContext.perform {
            do {
                let goalToUpdate = try backgroundContext.existingObject(with: goalID)
                
                goalToUpdate.setValue(max(0, min(100, progress)), forKey: "progress") // 0-100の範囲に制限
                goalToUpdate.setValue(isCompleted, forKey: "isCompleted")
                
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    self.fetchGoals()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "目標の更新に失敗しました: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("目標の更新に失敗: \(error)")
            }
        }
    }
    
    func deleteGoal(_ goal: NSManagedObject) {
        isLoading = true
        errorMessage = nil
        
        let backgroundContext = persistenceController.newBackgroundContext()
        let goalID = goal.objectID
        
        backgroundContext.perform {
            do {
                let goalToDelete = try backgroundContext.existingObject(with: goalID)
                backgroundContext.delete(goalToDelete)
                
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    self.fetchGoals()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "目標の削除に失敗しました: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("目標の削除に失敗: \(error)")
            }
        }
    }
}
