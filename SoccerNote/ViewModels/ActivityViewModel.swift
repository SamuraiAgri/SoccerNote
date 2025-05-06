// SoccerNote/ViewModels/ActivityViewModel.swift
import Foundation
import CoreData
import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
    private let persistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var activities: [NSManagedObject] = []
    @Published var recentActivities: [NSManagedObject] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    init(viewContext: NSManagedObjectContext, persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.viewContext = viewContext
        fetchActivities()
        
        // 変更通知を監視して自動更新
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchActivities()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchActivities() {
        isLoading = true
        errorMessage = nil
        
        let backgroundContext = persistenceController.newBackgroundContext()
        backgroundContext.perform {
            do {
                let request = NSFetchRequest<NSManagedObject>(entityName: "Activity")
                request.sortDescriptors = [NSSortDescriptor(keyPath: \Activity.date, ascending: false)]
                
                let activities = try backgroundContext.fetch(request)
                
                // 最近の活動（最大5件）を取得
                let recentRequest = NSFetchRequest<NSManagedObject>(entityName: "Activity")
                recentRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Activity.date, ascending: false)]
                recentRequest.fetchLimit = 5
                let recentActivities = try backgroundContext.fetch(recentRequest)
                
                // UIの更新はメインスレッドで行う
                DispatchQueue.main.async {
                    self.activities = activities.map { self.viewContext.object(with: $0.objectID) }
                    self.recentActivities = recentActivities.map { self.viewContext.object(with: $0.objectID) }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "活動の取得に失敗しました: \(error.localizedDescription)"
                    self.isLoading = false
                    print("活動の取得に失敗: \(error)")
                }
            }
        }
    }
    
    func saveActivity(type: ActivityType, date: Date, location: String, notes: String, rating: Int) -> NSManagedObject? {
        // 入力検証
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLocation.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "場所は必須項目です"
            }
            return nil
        }
        
        let backgroundContext = persistenceController.newBackgroundContext()
        var savedActivity: NSManagedObject?
        
        backgroundContext.performAndWait {
            let activity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: backgroundContext)
            
            activity.setValue(date, forKey: "date")
            activity.setValue(type.rawValue, forKey: "type")
            activity.setValue(trimmedLocation, forKey: "location")
            activity.setValue(notes, forKey: "notes")
            activity.setValue(rating, forKey: "rating")
            activity.setValue(UUID(), forKey: "id")
            
            do {
                try backgroundContext.save()
                
                // 保存に成功したら、メインコンテキストのオブジェクトを返す
                savedActivity = self.viewContext.object(with: activity.objectID)
                
                DispatchQueue.main.async {
                    self.fetchActivities()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "活動の保存に失敗しました: \(error.localizedDescription)"
                }
                print("活動の保存に失敗: \(error)")
            }
        }
        
        return savedActivity
    }
    
    func deleteActivity(_ activity: NSManagedObject) {
        let backgroundContext = persistenceController.newBackgroundContext()
        let activityID = activity.objectID
        
        backgroundContext.perform {
            do {
                let activityToDelete = try backgroundContext.existingObject(with: activityID)
                backgroundContext.delete(activityToDelete)
                
                try backgroundContext.save()
                DispatchQueue.main.async {
                    self.fetchActivities()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "活動の削除に失敗しました: \(error.localizedDescription)"
                }
                print("活動の削除に失敗: \(error)")
            }
        }
    }
}
