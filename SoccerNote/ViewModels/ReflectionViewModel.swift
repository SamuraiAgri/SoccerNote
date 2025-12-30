// SoccerNote/ViewModels/ReflectionViewModel.swift
import Foundation
import CoreData
import SwiftUI
import Combine

class ReflectionViewModel: ObservableObject {
    private let persistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var reflections: [NSManagedObject] = []
    @Published var recentReflections: [NSManagedObject] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    init(viewContext: NSManagedObjectContext, persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.viewContext = viewContext
        fetchReflections()
        
        // 変更通知を監視して自動更新
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchReflections()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchReflections() {
        isLoading = true
        errorMessage = nil
        
        let backgroundContext = persistenceController.newBackgroundContext()
        backgroundContext.perform {
            do {
                let request = NSFetchRequest<NSManagedObject>(entityName: "Reflection")
                request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                
                let reflections = try backgroundContext.fetch(request)
                
                // 最近の振り返り（最大5件）を取得
                let recentRequest = NSFetchRequest<NSManagedObject>(entityName: "Reflection")
                recentRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                recentRequest.fetchLimit = 5
                let recentReflections = try backgroundContext.fetch(recentRequest)
                
                // UIの更新はメインスレッドで行う
                DispatchQueue.main.async {
                    self.reflections = reflections.map { self.viewContext.object(with: $0.objectID) }
                    self.recentReflections = recentReflections.map { self.viewContext.object(with: $0.objectID) }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "振り返りの取得に失敗しました: \(error.localizedDescription)"
                    self.isLoading = false
                    print("振り返りの取得に失敗: \(error)")
                }
            }
        }
    }
    
    // 振り返りを日付でフィルタリング
    func reflections(for date: Date) -> [NSManagedObject] {
        let calendar = Calendar.current
        return reflections.filter { reflection in
            guard let reflectionDate = reflection.value(forKey: "date") as? Date else { return false }
            return calendar.isDate(reflectionDate, inSameDayAs: date)
        }
    }
    
    // 振り返りを保存
    func saveReflection(
        title: String,
        date: Date,
        mood: Int,
        successes: String,
        challenges: String,
        learnings: String,
        improvements: String,
        nextGoal: String,
        feelings: String,
        activity: NSManagedObject? = nil
    ) -> NSManagedObject? {
        let backgroundContext = persistenceController.newBackgroundContext()
        var savedReflection: NSManagedObject?
        
        backgroundContext.performAndWait {
            let reflection = NSEntityDescription.insertNewObject(forEntityName: "Reflection", into: backgroundContext)
            
            reflection.setValue(UUID(), forKey: "id")
            reflection.setValue(title, forKey: "title")
            reflection.setValue(date, forKey: "date")
            reflection.setValue(Date(), forKey: "createdAt")
            reflection.setValue(Date(), forKey: "updatedAt")
            reflection.setValue(mood, forKey: "mood")
            reflection.setValue(successes, forKey: "successes")
            reflection.setValue(challenges, forKey: "challenges")
            reflection.setValue(learnings, forKey: "learnings")
            reflection.setValue(improvements, forKey: "improvements")
            reflection.setValue(nextGoal, forKey: "nextGoal")
            reflection.setValue(feelings, forKey: "feelings")
            
            // 活動と関連付け
            if let activity = activity {
                let bgActivity = backgroundContext.object(with: activity.objectID)
                reflection.setValue(bgActivity, forKey: "activity")
            }
            
            do {
                try backgroundContext.save()
                savedReflection = self.viewContext.object(with: reflection.objectID)
                
                DispatchQueue.main.async {
                    self.fetchReflections()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "振り返りの保存に失敗しました: \(error.localizedDescription)"
                }
                print("振り返りの保存に失敗: \(error)")
            }
        }
        
        return savedReflection
    }
    
    // 振り返りを更新
    func updateReflection(
        reflection: NSManagedObject,
        title: String,
        mood: Int,
        successes: String,
        challenges: String,
        learnings: String,
        improvements: String,
        nextGoal: String,
        feelings: String
    ) {
        let backgroundContext = persistenceController.newBackgroundContext()
        
        backgroundContext.perform {
            let bgReflection = backgroundContext.object(with: reflection.objectID)
            
            bgReflection.setValue(title, forKey: "title")
            bgReflection.setValue(mood, forKey: "mood")
            bgReflection.setValue(successes, forKey: "successes")
            bgReflection.setValue(challenges, forKey: "challenges")
            bgReflection.setValue(learnings, forKey: "learnings")
            bgReflection.setValue(improvements, forKey: "improvements")
            bgReflection.setValue(nextGoal, forKey: "nextGoal")
            bgReflection.setValue(feelings, forKey: "feelings")
            bgReflection.setValue(Date(), forKey: "updatedAt")
            
            do {
                try backgroundContext.save()
                DispatchQueue.main.async {
                    self.fetchReflections()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "振り返りの更新に失敗しました: \(error.localizedDescription)"
                }
                print("振り返りの更新に失敗: \(error)")
            }
        }
    }
    
    // 振り返りを削除
    func deleteReflection(_ reflection: NSManagedObject) {
        let backgroundContext = persistenceController.newBackgroundContext()
        
        backgroundContext.perform {
            let bgReflection = backgroundContext.object(with: reflection.objectID)
            backgroundContext.delete(bgReflection)
            
            do {
                try backgroundContext.save()
                DispatchQueue.main.async {
                    self.fetchReflections()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "振り返りの削除に失敗しました: \(error.localizedDescription)"
                }
                print("振り返りの削除に失敗: \(error)")
            }
        }
    }
    
    // 今週の振り返り数を取得
    func thisWeekReflectionCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        
        return reflections.filter { reflection in
            guard let date = reflection.value(forKey: "date") as? Date else { return false }
            return date >= startOfWeek
        }.count
    }
    
    // 今月の振り返り数を取得
    func thisMonthReflectionCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        
        return reflections.filter { reflection in
            guard let date = reflection.value(forKey: "date") as? Date else { return false }
            return date >= startOfMonth
        }.count
    }
    
    // 連続記録日数を計算
    func streakDays() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        // 今日から過去に向かって連続した日をカウント
        while true {
            let hasReflection = reflections.contains { reflection in
                guard let date = reflection.value(forKey: "date") as? Date else { return false }
                return calendar.isDate(date, inSameDayAs: currentDate)
            }
            
            if hasReflection {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}
