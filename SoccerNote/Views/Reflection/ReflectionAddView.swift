// SoccerNote/Views/Reflection/ReflectionAddView.swift
import SwiftUI
import CoreData

struct ReflectionAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var reflectionViewModel: ReflectionViewModel
    
    // 入力状態
    @State private var currentStep = 0
    @State private var date = Date()
    @State private var mood: Int = 3
    @State private var successes = ""
    @State private var challenges = ""
    @State private var learnings = ""
    @State private var improvements = ""
    @State private var nextGoal = ""
    @State private var feelings = ""
    
    // UI状態
    @State private var showingSuccessAlert = false
    @State private var toast: ToastData?
    
    private let totalSteps = 5
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _reflectionViewModel = StateObject(wrappedValue: ReflectionViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // プログレスインジケーター
                ReflectionProgressBar(currentStep: currentStep, totalSteps: totalSteps)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // ステップタイトル
                stepTitle
                    .padding(.vertical, 16)
                
                // ステップコンテンツ
                TabView(selection: $currentStep) {
                    moodStep.tag(0)
                    successStep.tag(1)
                    challengeStep.tag(2)
                    learningStep.tag(3)
                    nextStep.tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // ナビゲーションボタン
                navigationButtons
                    .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("今日の振り返り")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            )
            .toast($toast)
            .overlay(
                Group {
                    if showingSuccessAlert {
                        successOverlay
                    }
                }
            )
        }
    }
    
    // MARK: - Step Views
    
    private var stepTitle: some View {
        VStack(spacing: 4) {
            Text(stepTitleText)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(stepSubtitleText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var moodStep: some View {
        VStack(spacing: 24) {
            Text("今日の調子は？")
                .font(.headline)
            
            MoodSelector(selectedMood: $mood)
            
            // 簡単な気持ちメモ
            VStack(alignment: .leading, spacing: 8) {
                Text("今の気持ちを一言")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("例: 疲れたけど充実してた", text: $feelings)
                    .textFieldStyle(ReflectionTextFieldStyle())
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private var successStep: some View {
        VStack(spacing: 16) {
            PromptCard(
                icon: "star.fill",
                iconColor: .yellow,
                prompt: "今日うまくいったこと、できたことは？",
                hint: "小さなことでもOK！自分を褒めてあげよう"
            )
            
            ReflectionTextEditor(
                text: $successes,
                placeholder: "例:\n・パスの成功率が高かった\n・積極的に声を出せた\n・最後まで走り切れた"
            )
            
            Spacer()
        }
        .padding()
    }
    
    private var challengeStep: some View {
        VStack(spacing: 16) {
            PromptCard(
                icon: "exclamationmark.triangle.fill",
                iconColor: .orange,
                prompt: "課題だと感じたこと、難しかったことは？",
                hint: "改善のチャンスを見つけよう"
            )
            
            ReflectionTextEditor(
                text: $challenges,
                placeholder: "例:\n・シュートの精度が低かった\n・判断が遅かった\n・守備の切り替えが遅れた"
            )
            
            Spacer()
        }
        .padding()
    }
    
    private var learningStep: some View {
        VStack(spacing: 16) {
            PromptCard(
                icon: "lightbulb.fill",
                iconColor: .blue,
                prompt: "今日学んだこと、気づいたことは？",
                hint: "コーチのアドバイス、試合での発見など"
            )
            
            ReflectionTextEditor(
                text: $learnings,
                placeholder: "例:\n・ボールを受ける前に周りを見ることが大事\n・チームメイトともっとコミュニケーションを取る\n・体の向きを意識する"
            )
            
            Spacer()
        }
        .padding()
    }
    
    private var nextStep: some View {
        VStack(spacing: 16) {
            PromptCard(
                icon: "flag.fill",
                iconColor: .green,
                prompt: "次に意識すること、目標は？",
                hint: "具体的なアクションを決めよう"
            )
            
            ReflectionTextEditor(
                text: $nextGoal,
                placeholder: "例:\n・練習前に必ずストレッチする\n・パスを出す前に2回以上首を振る\n・シュート練習を10本追加する"
            )
            
            // 改善ポイント（オプション）
            VStack(alignment: .leading, spacing: 8) {
                Text("改善のためにやること（任意）")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("具体的なアクション", text: $improvements)
                    .textFieldStyle(ReflectionTextFieldStyle())
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Navigation
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button(action: {
                    HapticFeedback.light()
                    withAnimation {
                        currentStep -= 1
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("戻る")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
            
            Button(action: {
                HapticFeedback.medium()
                if currentStep < totalSteps - 1 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    saveReflection()
                }
            }) {
                HStack {
                    Text(currentStep < totalSteps - 1 ? "次へ" : "保存する")
                    if currentStep < totalSteps - 1 {
                        Image(systemName: "chevron.right")
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppDesign.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("振り返りを保存しました！")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("お疲れさまでした 🎉")
                    .foregroundColor(.secondary)
                
                Button(action: {
                    showingSuccessAlert = false
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("OK")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppDesign.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(30)
            .frame(width: 280)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
    
    // MARK: - Helper
    
    private var stepTitleText: String {
        switch currentStep {
        case 0: return "調子チェック"
        case 1: return "Good Point"
        case 2: return "課題"
        case 3: return "学び"
        case 4: return "次への一歩"
        default: return ""
        }
    }
    
    private var stepSubtitleText: String {
        switch currentStep {
        case 0: return "今日の自分の状態を振り返ろう"
        case 1: return "今日の良かったことを書き出そう"
        case 2: return "課題を明確にすることが成長への第一歩"
        case 3: return "気づきは宝物、忘れないうちに記録しよう"
        case 4: return "明日からの具体的なアクションを決めよう"
        default: return ""
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: date)
    }
    
    private func saveReflection() {
        let title = "\(formattedDate)の振り返り"
        
        let _ = reflectionViewModel.saveReflection(
            title: title,
            date: date,
            mood: mood,
            successes: successes,
            challenges: challenges,
            learnings: learnings,
            improvements: improvements,
            nextGoal: nextGoal,
            feelings: feelings
        )
        
        HapticFeedback.success()
        showingSuccessAlert = true
    }
}

// MARK: - Supporting Views

struct ReflectionProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? AppDesign.primaryColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
    }
}

struct MoodSelector: View {
    @Binding var selectedMood: Int
    
    private let moods = [
        (emoji: "😫", label: "つらい", value: 1),
        (emoji: "😕", label: "いまいち", value: 2),
        (emoji: "😐", label: "ふつう", value: 3),
        (emoji: "😊", label: "良い", value: 4),
        (emoji: "🔥", label: "最高！", value: 5)
    ]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(moods, id: \.value) { mood in
                VStack(spacing: 4) {
                    Text(mood.emoji)
                        .font(.system(size: selectedMood == mood.value ? 44 : 36))
                        .scaleEffect(selectedMood == mood.value ? 1.1 : 1.0)
                    
                    Text(mood.label)
                        .font(.caption2)
                        .foregroundColor(selectedMood == mood.value ? .primary : .secondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedMood == mood.value ? AppDesign.primaryColor.opacity(0.15) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedMood == mood.value ? AppDesign.primaryColor : Color.clear, lineWidth: 2)
                )
                .onTapGesture {
                    HapticFeedback.selection()
                    withAnimation(.spring(response: 0.3)) {
                        selectedMood = mood.value
                    }
                }
            }
        }
    }
}

struct PromptCard: View {
    let icon: String
    let iconColor: Color
    let prompt: String
    let hint: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(prompt)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(hint)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ReflectionTextEditor: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
            }
            
            TextEditor(text: $text)
                .frame(minHeight: 150)
                .padding(4)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ReflectionTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    ReflectionAddView()
}
