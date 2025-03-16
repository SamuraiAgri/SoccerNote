import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SoccerNote")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("CoreDataのロードに失敗: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // プレビュー用のインスタンス
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // サンプルデータの追加
        let viewContext = controller.container.viewContext
        
        // サンプルの活動記録
        let activity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: viewContext)
        activity.setValue(Date(), forKey: "date")
        activity.setValue("match", forKey: "type")
        activity.setValue("市民グラウンド", forKey: "location")
        activity.setValue("良い試合だった", forKey: "notes")
        activity.setValue(4, forKey: "rating")
        activity.setValue(UUID(), forKey: "id")
        
        // サンプルの試合記録
        let match = NSEntityDescription.insertNewObject(forEntityName: "Match", into: viewContext)
        match.setValue("FCトーキョー", forKey: "opponent")
        match.setValue("2-1", forKey: "score")
        match.setValue(1, forKey: "goalsScored")
        match.setValue(1, forKey: "assists")
        match.setValue(90, forKey: "playingTime")
        match.setValue(8, forKey: "performance")
        match.setValue(UUID(), forKey: "id")
        match.setValue(activity, forKey: "activity")
        
        // サンプルの目標
        let goal = NSEntityDescription.insertNewObject(forEntityName: "Goal", into: viewContext)
        goal.setValue("シーズン10ゴール", forKey: "title")
        goal.setValue("今シーズンは最低10ゴールを決める", forKey: "goalDescription")
        goal.setValue(Date().addingTimeInterval(60*60*24*90), forKey: "deadline") // 90日後
        goal.setValue(false, forKey: "isCompleted")
        goal.setValue(20, forKey: "progress") // 20%達成
        goal.setValue(Date(), forKey: "creationDate")
        goal.setValue(UUID(), forKey: "id")
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("プレビューデータの保存に失敗: \(nsError)")
        }
        
        return controller
    }()
}
