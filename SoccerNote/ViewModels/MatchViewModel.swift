// SoccerNote/ViewModels/MatchViewModel.swift
import Foundation
import CoreData
import SwiftUI
import Combine

class MatchViewModel: ObservableObject {
    private let persistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    @Published var matches: [NSManagedObject] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    init(viewContext: NSManagedObjectContext, persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.viewContext = viewContext
        fetchMatches()
        
        // 変更通知を監視して自動更新
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchMatches()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchMatches() {
        isLoading = true
        errorMessage = nil
        
        // バックグラウンドコンテキストを使用
        let backgroundContext = persistenceController.newBackgroundContext()
        
        // バッチサイズを設定してメモリ使用量を削減
        backgroundContext.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Match")
            let activitySort = NSSortDescriptor(key: "activity.date", ascending: false)
            request.sortDescriptors = [activitySort]
            request.fetchBatchSize = 20 // 一度に20件ずつロード
            
            do {
                let fetchedMatches = try backgroundContext.fetch(request)
                // オブジェクトIDを使ってメインコンテキストに変換
                let matchIDs = fetchedMatches.map { $0.objectID }
                
                DispatchQueue.main.async {
                    self.matches = matchIDs.map { self.viewContext.object(with: $0) }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "試合データの取得に失敗しました"
                    self.isLoading = false
                    print("試合の取得に失敗: \(error)")
                }
            }
        }
    }
    
    func saveMatch(activity: NSManagedObject, opponent: String, score: String, goalsScored: Int, assists: Int, playingTime: Int, performance: Int, photos: Data? = nil) {
        isLoading = true
        errorMessage = nil
        
        // 入力検証
        let trimmedOpponent = opponent.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedScore = score.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedOpponent.isEmpty, !trimmedScore.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "対戦相手とスコアは必須項目です"
                self.isLoading = false
            }
            return
        }
        
        let backgroundContext = persistenceController.newBackgroundContext()
        let activityID = activity.objectID
        
        backgroundContext.perform {
            do {
                // 活動オブジェクトをバックグラウンドコンテキストで取得
                let backgroundActivity = try backgroundContext.existingObject(with: activityID)
                
                let match = NSEntityDescription.insertNewObject(forEntityName: "Match", into: backgroundContext)
                
                match.setValue(trimmedOpponent, forKey: "opponent")
                match.setValue(trimmedScore, forKey: "score")
                match.setValue(max(0, min(20, goalsScored)), forKey: "goalsScored") // 0-20の範囲に制限
                match.setValue(max(0, min(20, assists)), forKey: "assists") // 0-20の範囲に制限
                match.setValue(max(0, min(120, playingTime)), forKey: "playingTime") // 0-120の範囲に制限
                match.setValue(max(1, min(10, performance)), forKey: "performance") // 1-10の範囲に制限
                match.setValue(photos, forKey: "photos")
                match.setValue(UUID(), forKey: "id")
                match.setValue(backgroundActivity, forKey: "activity")
                
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    self.fetchMatches()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "試合の保存に失敗しました: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("試合の保存に失敗: \(error)")
            }
        }
    }
    
    func deleteMatch(_ match: NSManagedObject) {
        isLoading = true
        errorMessage = nil
        
        let backgroundContext = persistenceController.newBackgroundContext()
        let matchID = match.objectID
        
        backgroundContext.perform {
            do {
                let matchToDelete = try backgroundContext.existingObject(with: matchID)
                backgroundContext.delete(matchToDelete)
                
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    self.fetchMatches()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "試合の削除に失敗しました: \(error.localizedDescription)"
                    self.isLoading = false
                }
                print("試合の削除に失敗: \(error)")
            }
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
