import SwiftUI
import CoreData

struct EditPracticeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    let activity: NSManagedObject
    
    @State private var date: Date
    @State private var location: String
    @State private var notes: String
    @State private var rating: Int
    
    @State private var focus: String
    @State private var duration: Int
    @State private var intensity: Int
    @State private var learnings: String
    
    @State private var showingConfirmation = false
    
    init(activity: NSManagedObject) {
        self.activity = activity
        
        // 活動の基本情報を初期化
        self._date = State(initialValue: activity.value(forKey: "date") as? Date ?? Date())
        self._location = State(initialValue: activity.value(forKey: "location") as? String ?? "")
        self._notes = State(initialValue: activity.value(forKey: "notes") as? String ?? "")
        self._rating = State(initialValue: activity.value(forKey: "rating") as? Int ?? 3)
        
        // 練習詳細を取得して初期化
        let practiceDetails = Self.fetchPracticeDetails(for: activity)
        
        self._focus = State(initialValue: practiceDetails?.value(forKey: "focus") as? String ?? "")
        self._duration = State(initialValue: practiceDetails?.value(forKey: "duration") as? Int ?? 60)
        self._intensity = State(initialValue: practiceDetails?.value(forKey: "intensity") as? Int ?? 3)
        self._learnings = State(initialValue: practiceDetails?.value(forKey: "learnings") as? String ?? "")
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
                
                // 練習詳細
                Section(header: Text("練習詳細")) {
                    TextField("フォーカスエリア", text: $focus)
                    
                    Stepper("練習時間: \(duration)分", value: $duration, in: 0...300, step: 15)
                    
                    VStack(alignment: .leading) {
                        Text("練習強度")
                        
                        HStack {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= intensity ? AppIcons.Rating.circleFill : AppIcons.Rating.circle)
                                    .foregroundColor(AppDesign.primaryColor)
                                    .onTapGesture {
                                        intensity = index
                                    }
                            }
                        }
                    }
                    
                    TextField("学んだこと", text: $learnings)
                        .frame(height: 100)
                }
                
                // 保存ボタン
                Section {
                    Button(action: {
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
            .navigationTitle("練習記録編集")
            .navigationBarItems(trailing: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss()
            })
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
        return !location.isEmpty && !focus.isEmpty
    }
    
    // 記録の更新
    private func updateRecord() {
        // 活動記録の更新
        activity.setValue(date, forKey: "date")
        activity.setValue(location, forKey: "location")
        activity.setValue(notes, forKey: "notes")
        activity.setValue(rating, forKey: "rating")
        
        // 練習詳細の更新
        if let practiceDetails = Self.fetchPracticeDetails(for: activity) {
            practiceDetails.setValue(focus, forKey: "focus")
            practiceDetails.setValue(duration, forKey: "duration")
            practiceDetails.setValue(intensity, forKey: "intensity")
            practiceDetails.setValue(learnings, forKey: "learnings")
        }
        
        // 保存
        do {
            try viewContext.save()
            showingConfirmation = true
        } catch {
            let nsError = error as NSError
            print("記録の更新に失敗: \(nsError)")
        }
    }
    
    // 練習詳細の取得（静的メソッド）
    static func fetchPracticeDetails(for activity: NSManagedObject) -> NSManagedObject? {
        guard let id = activity.value(forKey: "id") as? UUID,
              let context = activity.managedObjectContext else { return nil }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Practice")
        request.predicate = NSPredicate(format: "activity.id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("練習詳細の取得に失敗: \(error)")
            return nil
        }
    }
}
