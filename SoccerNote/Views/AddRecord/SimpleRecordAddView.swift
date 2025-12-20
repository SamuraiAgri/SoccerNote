// SoccerNote/Views/AddRecord/SimpleRecordAddView.swift
import SwiftUI
import CoreData

struct SimpleRecordAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // 活動タイプを文字列として保持（enumの比較問題を回避）
    @State private var selectedType = "試合" // "試合" または "練習"
    @State private var date: Date
    @State private var location = ""
    @State private var notes = ""
    @State private var rating = 3
    
    // 試合情報
    @State private var opponent = ""
    @State private var score = ""
    @State private var goalsScored = 0
    @State private var assists = 0
    
    // 練習情報
    @State private var focus = ""
    @State private var duration = 60
    @State private var intensity = 3
    
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var toast: ToastData?
    
    // イニシャライザでUserDefaultsから選択された日付を取得
    init() {
        // UserDefaultsから選択された日付を取得
        if let timestamp = UserDefaults.standard.object(forKey: "SelectedDateForNewRecord") as? TimeInterval {
            _date = State(initialValue: Date(timeIntervalSince1970: timestamp))
            // 使用後は削除（次回以降に影響しないように）
            UserDefaults.standard.removeObject(forKey: "SelectedDateForNewRecord")
        } else {
            _date = State(initialValue: Date())
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 基本情報セクション
                    VStack(alignment: .leading, spacing: 16) {
                        Text("基本情報")
                            .font(.headline)
                        
                        // タイプ選択をSegmentedControlに変更
                        Picker("記録タイプ", selection: $selectedType) {
                            Text("試合").tag("試合")
                            Text("練習").tag("練習")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        // iOS 17用のonChange修正
                        .onChange(of: selectedType) { _, newValue in
                            HapticFeedback.selection()
                            print("選択されたタイプ: \(newValue)")
                        }
                        
                        // 日時 - 選択した日付が保持されるよう修正
                        VStack(alignment: .leading, spacing: 8) {
                            Text("日時")
                                .font(.subheadline)
                            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                // 日付が現在に強制されないようにする
                                .environment(\.calendar, Calendar.current)
                        }
                        
                        // 場所
                        VStack(alignment: .leading, spacing: 8) {
                            Text("場所")
                                .font(.subheadline)
                            TextField("場所を入力", text: $location)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // 評価
                        VStack(alignment: .leading, spacing: 8) {
                            Text("評価")
                                .font(.subheadline)
                            HStack {
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= rating ? "star.fill" : "star")
                                        .foregroundColor(index <= rating ? .yellow : .gray)
                                        .font(.system(size: 24))
                                        .onTapGesture {
                                            HapticFeedback.selection()
                                            rating = index
                                        }
                                }
                            }
                        }
                        
                        // メモ
                        VStack(alignment: .leading, spacing: 8) {
                            Text("メモ (任意)")
                                .font(.subheadline)
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // 試合情報セクション（タイプに応じて表示）
                    if selectedType == "試合" {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("試合情報")
                                .font(.headline)
                            
                            // 対戦相手
                            VStack(alignment: .leading, spacing: 8) {
                                Text("対戦相手")
                                    .font(.subheadline)
                                TextField("対戦相手", text: $opponent)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // スコア
                            VStack(alignment: .leading, spacing: 8) {
                                Text("スコア")
                                    .font(.subheadline)
                                TextField("例: 2-1", text: $score)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // 得点
                            VStack(alignment: .leading, spacing: 8) {
                                Text("得点")
                                    .font(.subheadline)
                                HStack {
                                    Button(action: {
                                        if goalsScored > 0 {
                                            goalsScored -= 1
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 24))
                                    }
                                    
                                    Text("\(goalsScored)")
                                        .font(.system(size: 24, weight: .bold))
                                        .frame(width: 40, alignment: .center)
                                    
                                    Button(action: {
                                        goalsScored += 1
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 24))
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            // アシスト
                            VStack(alignment: .leading, spacing: 8) {
                                Text("アシスト")
                                    .font(.subheadline)
                                HStack {
                                    Button(action: {
                                        if assists > 0 {
                                            assists -= 1
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 24))
                                    }
                                    
                                    Text("\(assists)")
                                        .font(.system(size: 24, weight: .bold))
                                        .frame(width: 40, alignment: .center)
                                    
                                    Button(action: {
                                        assists += 1
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.orange)
                                            .font(.system(size: 24))
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // 練習情報セクション（タイプに応じて表示）
                    if selectedType == "練習" {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("練習情報")
                                .font(.headline)
                            
                            // フォーカスエリア
                            VStack(alignment: .leading, spacing: 8) {
                                Text("フォーカスエリア")
                                    .font(.subheadline)
                                TextField("例: パス練習、シュート練習など", text: $focus)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // 練習時間
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("練習時間: \(duration)分")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(formattedDuration)
                                        .foregroundColor(.green)
                                        .fontWeight(.bold)
                                }
                                
                                Slider(value: Binding(
                                    get: { Double(duration) },
                                    set: { duration = Int($0) }
                                ), in: 15...240, step: 15)
                                .accentColor(.green)
                            }
                            
                            // 練習強度
                            VStack(alignment: .leading, spacing: 12) {
                                Text("練習強度")
                                    .font(.subheadline)
                                
                                HStack {
                                    ForEach(1...5, id: \.self) { i in
                                        Button(action: {
                                            intensity = i
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(i <= intensity ? Color.green : Color.gray.opacity(0.2))
                                                    .frame(width: 40, height: 40)
                                                
                                                Text("\(i)")
                                                    .foregroundColor(i <= intensity ? .white : .gray)
                                                    .fontWeight(.bold)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("軽い")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("普通")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text("ハード")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // 保存ボタン
                    Button(action: {
                        HapticFeedback.light()
                        saveRecord()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("記録を保存")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .background(isFormValid ?
                                         (selectedType == "試合" ? Color.orange : Color.green) :
                                         Color.gray)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(!isFormValid || isLoading)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .padding()
            }
            .navigationTitle("記録追加")
            .toast($toast)
            .alert(isPresented: $showSuccess) {
                Alert(
                    title: Text("保存完了"),
                    message: Text("記録が保存されました"),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // 時間フォーマット
    private var formattedDuration: String {
        let hours = duration / 60
        let minutes = duration % 60
        
        if hours > 0 {
            return "\(hours)時間\(minutes > 0 ? "\(minutes)分" : "")"
        } else {
            return "\(minutes)分"
        }
    }
    
    // フォームの入力検証
    private var isFormValid: Bool {
        if selectedType == "試合" {
            return !location.isEmpty && !opponent.isEmpty && !score.isEmpty
        } else {
            return !location.isEmpty && !focus.isEmpty
        }
    }
    
    // 記録保存 - 選択された日付が正しく保存されるよう修正
    private func saveRecord() {
        isLoading = true
        
        // バックグラウンドで保存処理を実行
        DispatchQueue.global(qos: .userInitiated).async {
            let context = PersistenceController.shared.newBackgroundContext()
            
            context.performAndWait {
                // 活動の保存 - 選択された日付をそのまま使用
                let activity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: context)
                activity.setValue(UUID(), forKey: "id")
                activity.setValue(self.date, forKey: "date") // 選択日時を正確に保存
                activity.setValue(selectedType == "試合" ? "match" : "practice", forKey: "type")
                activity.setValue(location, forKey: "location")
                activity.setValue(notes, forKey: "notes")
                activity.setValue(rating, forKey: "rating")
                
                // 活動タイプに応じた詳細情報の保存
                if selectedType == "試合" {
                    let match = NSEntityDescription.insertNewObject(forEntityName: "Match", into: context)
                    match.setValue(UUID(), forKey: "id")
                    match.setValue(opponent, forKey: "opponent")
                    match.setValue(score, forKey: "score")
                    match.setValue(goalsScored, forKey: "goalsScored")
                    match.setValue(assists, forKey: "assists")
                    match.setValue(90, forKey: "playingTime") // デフォルト値
                    match.setValue(rating, forKey: "performance") // 評価と同じ値をデフォルトに
                    match.setValue(activity, forKey: "activity")
                } else {
                    let practice = NSEntityDescription.insertNewObject(forEntityName: "Practice", into: context)
                    practice.setValue(UUID(), forKey: "id")
                    practice.setValue(focus, forKey: "focus")
                    practice.setValue(duration, forKey: "duration")
                    practice.setValue(intensity, forKey: "intensity")
                    practice.setValue(notes, forKey: "learnings")
                    practice.setValue(activity, forKey: "activity")
                }
                
                do {
                    try context.save()
                    
                    // メインスレッドで UI 更新
                    DispatchQueue.main.async {
                        isLoading = false
                        HapticFeedback.success()
                        toast = ToastData(type: .success, message: "記録が保存されました")
                        
                        // 少し遅らせて画面を閉じる
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } catch {
                    print("保存エラー: \(error)")
                    DispatchQueue.main.async {
                        isLoading = false
                        HapticFeedback.error()
                        toast = ToastData(type: .error, message: "保存に失敗しました")
                    }
                }
            }
        }
    }
}

struct SimpleRecordAddView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleRecordAddView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
