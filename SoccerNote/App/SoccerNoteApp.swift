// SoccerNote/App/SoccerNoteApp.swift
import SwiftUI

@main
struct SoccerNoteApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // アプリ起動時にUIの外観を設定
        AppDesign.setupAppearance()
        
        // メモリ警告通知を監視
        setupMemoryWarningObserver()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .accentColor(AppDesign.primaryColor)
                .onAppear {
                    checkForPreviousCrash()
                }
        }
    }
    
    // メモリ警告監視の設定
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main) { _ in
                self.handleMemoryWarning()
            }
    }
    
    // メモリ警告時の処理
    private func handleMemoryWarning() {
        print("メモリ警告を受信しました。不要なリソースを解放します。")
        // キャッシュのクリアや、不要なオブジェクトの解放を行う
        URLCache.shared.removeAllCachedResponses()
        
        // CoreDataコンテキストのリフレッシュ
        persistenceController.container.viewContext.refreshAllObjects()
    }
    
    // 前回のクラッシュ確認
    private func checkForPreviousCrash() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("crash_log.txt")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // クラッシュログが存在する場合の処理
            print("前回の実行でクラッシュが発生しました。クラッシュログを確認してください。")
            
            // クラッシュログの内容を読み込む（必要に応じて）
            do {
                let crashLog = try String(contentsOf: fileURL, encoding: .utf8)
                print("クラッシュログの内容: \(crashLog)")
                
                // 修復処理が必要な場合はここに実装
                
                // 処理が完了したらログを削除
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("クラッシュログの読み込みに失敗: \(error)")
            }
        }
    }
}

// クラッシュハンドラー
extension SoccerNoteApp {
    static let uncaughtExceptionHandler: @convention(c) (NSException) -> Void = { exception in
        // クラッシュログの保存
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let crashLog = """
        ======= クラッシュレポート =======
        日時: \(dateFormatter.string(from: Date()))
        理由: \(exception.name)
        詳細: \(exception.reason ?? "不明")
        コールスタック: \(exception.callStackSymbols.joined(separator: "\n"))
        ============================
        """
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("crash_log.txt")
        
        do {
            try crashLog.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("クラッシュログの保存に失敗: \(error)")
        }
    }
}
