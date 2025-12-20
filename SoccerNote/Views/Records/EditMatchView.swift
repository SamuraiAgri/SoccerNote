import SwiftUI
import CoreData

struct EditMatchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let activity: NSManagedObject
    
    @State private var date: Date
    @State private var location: String
    @State private var notes: String
    @State private var rating: Int
    
    @State private var opponent: String
    @State private var score: String
    @State private var goalsScored: Int
    @State private var assists: Int
    @State private var playingTime: Int
    @State private var performance: Int
    
    @State private var showingConfirmation = false
    @State private var toast: ToastData?
    
    init(activity: NSManagedObject) {
        self.activity = activity
        
        // 活動の基本情報を初期化
        self._date = State(initialValue: activity.value(forKey: "date") as? Date ?? Date())
        self._location = State(initialValue: activity.value(forKey: "location") as? String ?? "")
        self._notes = State(initialValue: activity.value(forKey: "notes") as? String ?? "")
        self._rating = State(initialValue: activity.value(forKey: "rating") as? Int ?? 3)
        
        // 試合詳細を取得して初期化
        let matchDetails = Self.fetchMatchDetails(for: activity)
        
        self._opponent = State(initialValue: matchDetails?.value(forKey: "opponent") as? String ?? "")
        self._score = State(initialValue: matchDetails?.value(forKey: "score") as? String ?? "")
        self._goalsScored = State(initialValue: matchDetails?.value(forKey: "goalsScored") as? Int ?? 0)
        self._assists = State(initialValue: matchDetails?.value(forKey: "assists") as? Int ?? 0)
        self._playingTime = State(initialValue: matchDetails?.value(forKey: "playingTime") as? Int ?? 90)
        self._performance = State(initialValue: matchDetails?.value(forKey: "performance") as? Int ?? 5)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 基本情報
                Section(header: Text("基本情報")) {
                    DatePicker("日時", selection: $date)
                    
                    TextField("場所", text: $location)
                    
                    TextField("メモ", text: $notes)
                        .frame(height: 100)
                    
                    HStack {
                        Text("評価")
                        Spacer()
                        StarRatingPicker(rating: $rating)
                    }
                }
                
                // 試合詳細
                Section(header: Text("試合詳細")) {
                    TextField("対戦相手", text: $opponent)
                    
                    TextField("スコア (例: 2-1)", text: $score)
                    
                    Stepper("ゴール: \(goalsScored)", value: $goalsScored, in: 0...20)
                    
                    Stepper("アシスト: \(assists)", value: $assists, in: 0...20)
                    
                    Stepper("出場時間: \(playingTime)分", value: $playingTime, in: 0...120, step: 5)
                    
                    HStack {
                        Text("パフォーマンス評価")
                        Spacer()
                        Picker("", selection: $performance) {
                            ForEach(1...10, id: \.self) { rating in
                                Text("\(rating)").tag(rating)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 50)
                    }
                }
                
                // 保存ボタン
                Section {
                    Button(action: {
                        HapticFeedback.medium()
                        updateRecord()
                    }) {
                        Text("変更を保存")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(AppDesign.primaryColor)
                            .cornerRadius(AppDesign.CornerRadius.medium)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("試合記録編集")
            .navigationBarItems(trailing: Button("キャンセル") {
                HapticFeedback.light()
                presentationMode.wrappedValue.dismiss()
            })
            .toast($toast)
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text("保存完了"),
                    message: Text("記録が更新されました"),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // バリデーション
    private var isFormValid: Bool {
        return !location.isEmpty && !opponent.isEmpty && !score.isEmpty
    }
    
    // 記録の更新
    private func updateRecord() {
        // 活動記録の更新
        activity.setValue(date, forKey: "date")
        activity.setValue(location, forKey: "location")
        activity.setValue(notes, forKey: "notes")
        activity.setValue(rating, forKey: "rating")
        
        // 試合詳細の更新
        if let matchDetails = Self.fetchMatchDetails(for: activity) {
            matchDetails.setValue(opponent, forKey: "opponent")
            matchDetails.setValue(score, forKey: "score")
            matchDetails.setValue(goalsScored, forKey: "goalsScored")
            matchDetails.setValue(assists, forKey: "assists")
            matchDetails.setValue(playingTime, forKey: "playingTime")
            matchDetails.setValue(performance, forKey: "performance")
        }
        
        // 保存
        do {
            try viewContext.save()
            HapticFeedback.success()
            toast = ToastData(type: .success, message: "記録を更新しました")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showingConfirmation = true
            }
        } catch {
            HapticFeedback.error()
            toast = ToastData(type: .error, message: "更新に失敗しました")
            let nsError = error as NSError
            print("記録の更新に失敗: \(nsError)")
        }
    }
    
    // 試合詳細の取得（静的メソッド）
    static func fetchMatchDetails(for activity: NSManagedObject) -> NSManagedObject? {
        guard let id = activity.value(forKey: "id") as? UUID,
              let context = activity.managedObjectContext else { return nil }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Match")
        request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("試合詳細の取得に失敗: \(error)")
            return nil
        }
    }
}
