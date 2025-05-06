import Foundation
import CoreData
import SwiftUI
import Combine

class PracticeViewModel: ObservableObject {
    private let persistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var practices: [NSManagedObject] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    init(viewContext: NSManagedObjectContext, persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.viewContext = viewContext
        fetchPractices()
        
        // 変更通知を監視して自動更新
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchPractices()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchPractices() {
        isLoading = true
        errorMessage = nil
        
        let backgroundContext = persistenceController.newBackgroundContext()
        
        backgroundContext.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Practice")
            let activitySort = NSSortDescriptor(key: "activity.date", ascending: false)
            request.sortDescriptors = [activitySort]
            request.fetchBatchSize = 20
            
            do {
                let fetchedPractices = try backgroundContext.fetch(request)
                let practiceIDs = fetchedPractices.map { $0.objectID }
                
                DispatchQueue.main.async {
                    self.practices = practiceIDs.map { self.viewContext.object(with: $0) }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "練習データの取得に失敗しました"
                    self.isLoading = false
                }
                print("練習の取得に失敗: \(error)")
            }
        }
    }
    
    func savePractice(activity: NSManagedObject, focus: String, duration: Int, intensity: Int, learnings: String) {
        isLoading = true
        errorMessage = nil
        
        // 入力検証
        let trimmedFocus = focus.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFocus.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "フォーカスエリアは必須項目です"
                self.isLoading = false
            }
            return
        }
        
        let backgroundContext = persistenceController.newBackgroundContext()
        
        guard let activityID = activity.objectID else {
            DispatchQueue.main.async {
                self.errorMessage = "活動データが不正です"
                self.isLoading = false
            }
            return
        }
        
        backgroundContext.perform {
            do {
                // 活動オブジェクトをバックグラウンドコンテキストで取得
                let backgroundActivity = try backgroundContext.existingObject(with: activityID)
                
                let practice = NSEntityDescription.insertNewObject(forEntityName: "Practice", into: backgroundContext)
                
                practice.setValue(trimmedFocus, forKey: "focus")
                practice.setValue(max(0, min(300, duration)), forKey: "duration") // 0-300の範囲に制限
                practice.setValue(max(1, min(5, intensity)), forKey: "intensity") // 1-5の範囲に制限
                practice.setValue(learnings, forKey: "learnings")
                practice.setValue(UUID(), forKey: "id")
                practice.setValue(backgroundActivity, forKey: "activity")
                
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    self.fetchPractices()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "練習の保存に失敗しました: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("練習の保存に失敗: \(error)")
            }
        }
    }
    
    func deletePractice(_ practice: NSManagedObject) {
        isLoading = true
        errorMessage = nil
        
        let backgroundContext = persistenceController.newBackgroundContext()
        
        guard let practiceID = practice.objectID else {
            DispatchQueue.main.async {
                self.errorMessage = "練習データが不正です"
                self.isLoading = false
            }
            return
        }
        
        backgroundContext.perform {
            do {
                let practiceToDelete = try backgroundContext.existingObject(with: practiceID)
                backgroundContext.delete(practiceToDelete)
                
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    self.fetchPractices()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "練習の削除に失敗しました: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("練習の削除に失敗: \(error)")
            }
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
    func deleteActivity(_ activity: NSManagedObject) {
        let backgroundContext = persistenceController.newBackgroundContext()
        
        // objectIDの非オプショナル性を考慮
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
