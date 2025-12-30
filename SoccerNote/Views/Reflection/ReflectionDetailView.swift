// SoccerNote/Views/Reflection/ReflectionDetailView.swift
import SwiftUI
import CoreData

struct ReflectionDetailView: View {
    let reflection: NSManagedObject
    @ObservedObject var viewModel: ReflectionViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ヘッダー
                headerSection
                
                // 気持ちセクション
                moodSection
                
                // 内容セクション
                if hasContent(successes) {
                    contentCard(
                        title: "うまくいったこと",
                        icon: "star.fill",
                        iconColor: .yellow,
                        content: successes
                    )
                }
                
                if hasContent(challenges) {
                    contentCard(
                        title: "課題",
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .orange,
                        content: challenges
                    )
                }
                
                if hasContent(learnings) {
                    contentCard(
                        title: "学び・気づき",
                        icon: "lightbulb.fill",
                        iconColor: .blue,
                        content: learnings
                    )
                }
                
                if hasContent(nextGoal) {
                    contentCard(
                        title: "次の目標",
                        icon: "flag.fill",
                        iconColor: .green,
                        content: nextGoal
                    )
                }
                
                if hasContent(improvements) {
                    contentCard(
                        title: "改善アクション",
                        icon: "arrow.up.circle.fill",
                        iconColor: .purple,
                        content: improvements
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("振り返り")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("編集", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ReflectionEditView(reflection: reflection, viewModel: viewModel)
        }
        .alert("振り返りを削除", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除", role: .destructive) {
                viewModel.deleteReflection(reflection)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("この振り返りを削除しますか？この操作は取り消せません。")
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(formattedDate)
                .font(.title2)
                .fontWeight(.bold)
            
            if hasContent(feelings) {
                Text(feelings)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var moodSection: some View {
        HStack {
            Text("調子")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(moodEmoji)
                    .font(.title)
                Text(moodLabel)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func contentCard(title: String, icon: String, iconColor: Color, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Helpers
    
    private func hasContent(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var successes: String {
        reflection.value(forKey: "successes") as? String ?? ""
    }
    
    private var challenges: String {
        reflection.value(forKey: "challenges") as? String ?? ""
    }
    
    private var learnings: String {
        reflection.value(forKey: "learnings") as? String ?? ""
    }
    
    private var nextGoal: String {
        reflection.value(forKey: "nextGoal") as? String ?? ""
    }
    
    private var improvements: String {
        reflection.value(forKey: "improvements") as? String ?? ""
    }
    
    private var feelings: String {
        reflection.value(forKey: "feelings") as? String ?? ""
    }
    
    private var mood: Int {
        reflection.value(forKey: "mood") as? Int ?? 3
    }
    
    private var formattedDate: String {
        guard let date = reflection.value(forKey: "date") as? Date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日(E)"
        return formatter.string(from: date)
    }
    
    private var moodEmoji: String {
        switch mood {
        case 1: return "😫"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "🔥"
        default: return "😐"
        }
    }
    
    private var moodLabel: String {
        switch mood {
        case 1: return "つらい"
        case 2: return "いまいち"
        case 3: return "ふつう"
        case 4: return "良い"
        case 5: return "最高！"
        default: return "ふつう"
        }
    }
}

// MARK: - Edit View

struct ReflectionEditView: View {
    let reflection: NSManagedObject
    @ObservedObject var viewModel: ReflectionViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var mood: Int
    @State private var successes: String
    @State private var challenges: String
    @State private var learnings: String
    @State private var improvements: String
    @State private var nextGoal: String
    @State private var feelings: String
    
    init(reflection: NSManagedObject, viewModel: ReflectionViewModel) {
        self.reflection = reflection
        self.viewModel = viewModel
        
        _mood = State(initialValue: reflection.value(forKey: "mood") as? Int ?? 3)
        _successes = State(initialValue: reflection.value(forKey: "successes") as? String ?? "")
        _challenges = State(initialValue: reflection.value(forKey: "challenges") as? String ?? "")
        _learnings = State(initialValue: reflection.value(forKey: "learnings") as? String ?? "")
        _improvements = State(initialValue: reflection.value(forKey: "improvements") as? String ?? "")
        _nextGoal = State(initialValue: reflection.value(forKey: "nextGoal") as? String ?? "")
        _feelings = State(initialValue: reflection.value(forKey: "feelings") as? String ?? "")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 調子
                    VStack(alignment: .leading, spacing: 12) {
                        Text("調子")
                            .font(.headline)
                        MoodSelector(selectedMood: $mood)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // 気持ちメモ
                    editSection(title: "気持ちメモ", text: $feelings, placeholder: "今の気持ち")
                    
                    // うまくいったこと
                    editSection(title: "うまくいったこと", text: $successes, placeholder: "良かった点")
                    
                    // 課題
                    editSection(title: "課題", text: $challenges, placeholder: "課題・難しかったこと")
                    
                    // 学び
                    editSection(title: "学び・気づき", text: $learnings, placeholder: "学んだこと")
                    
                    // 次の目標
                    editSection(title: "次の目標", text: $nextGoal, placeholder: "次に意識すること")
                    
                    // 改善アクション
                    editSection(title: "改善アクション", text: $improvements, placeholder: "具体的なアクション")
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("振り返りを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func editSection(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            TextEditor(text: text)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private func saveChanges() {
        viewModel.updateReflection(
            reflection: reflection,
            title: reflection.value(forKey: "title") as? String ?? "",
            mood: mood,
            successes: successes,
            challenges: challenges,
            learnings: learnings,
            improvements: improvements,
            nextGoal: nextGoal,
            feelings: feelings
        )
        
        HapticFeedback.success()
        presentationMode.wrappedValue.dismiss()
    }
}
