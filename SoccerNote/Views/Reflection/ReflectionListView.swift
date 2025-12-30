// SoccerNote/Views/Reflection/ReflectionListView.swift
import SwiftUI
import CoreData

struct ReflectionListView: View {
    @StateObject private var viewModel: ReflectionViewModel
    @State private var showingAddSheet = false
    @State private var searchText = ""
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: ReflectionViewModel(viewContext: context))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.reflections.isEmpty {
                    emptyState
                } else {
                    reflectionList
                }
            }
            .navigationTitle("振り返りノート")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: GrowthInsightsView()) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title3)
                            .foregroundColor(AppDesign.primaryColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppDesign.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ReflectionAddView()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("まだ振り返りがありません")
                .font(.headline)
            
            Text("今日の練習や試合を振り返って\n成長につなげよう！")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("振り返りを書く")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppDesign.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(25)
            }
        }
        .padding()
    }
    
    private var reflectionList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 統計カード
                statsCard
                    .padding()
                
                // 振り返りリスト（月ごとにグループ化）
                LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                    ForEach(groupedReflections.keys.sorted().reversed(), id: \.self) { month in
                        Section(header: monthHeader(month)) {
                            ForEach(groupedReflections[month] ?? [], id: \.objectID) { reflection in
                                NavigationLink(destination: ReflectionDetailView(reflection: reflection, viewModel: viewModel)) {
                                    ReflectionCard(reflection: reflection)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(value: "\(viewModel.streakDays())", label: "連続日数", icon: "flame.fill", color: .orange)
            
            Divider()
                .frame(height: 40)
            
            statItem(value: "\(viewModel.thisWeekReflectionCount())", label: "今週", icon: "calendar", color: .blue)
            
            Divider()
                .frame(height: 40)
            
            statItem(value: "\(viewModel.thisMonthReflectionCount())", label: "今月", icon: "chart.bar.fill", color: .green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func monthHeader(_ month: String) -> some View {
        HStack {
            Text(month)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    private var groupedReflections: [String: [NSManagedObject]] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        
        return Dictionary(grouping: viewModel.reflections) { reflection in
            guard let date = reflection.value(forKey: "date") as? Date else { return "不明" }
            return formatter.string(from: date)
        }
    }
}

// MARK: - Reflection Card

struct ReflectionCard: View {
    let reflection: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 日付と調子
            HStack {
                Text(formattedDate)
                    .font(.headline)
                
                Spacer()
                
                Text(moodEmoji)
                    .font(.title2)
            }
            
            // 気持ちメモ
            if !feelings.isEmpty {
                Text(feelings)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // プレビュー
            HStack(spacing: 16) {
                if !successes.isEmpty {
                    previewBadge(icon: "star.fill", color: .yellow, text: "Good")
                }
                if !challenges.isEmpty {
                    previewBadge(icon: "exclamationmark.triangle.fill", color: .orange, text: "課題")
                }
                if !learnings.isEmpty {
                    previewBadge(icon: "lightbulb.fill", color: .blue, text: "学び")
                }
                if !nextGoal.isEmpty {
                    previewBadge(icon: "flag.fill", color: .green, text: "目標")
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
    
    private func previewBadge(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    // Helpers
    private var formattedDate: String {
        guard let date = reflection.value(forKey: "date") as? Date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: date)
    }
    
    private var moodEmoji: String {
        let mood = reflection.value(forKey: "mood") as? Int ?? 3
        switch mood {
        case 1: return "😫"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "🔥"
        default: return "😐"
        }
    }
    
    private var feelings: String {
        reflection.value(forKey: "feelings") as? String ?? ""
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
}

#Preview {
    ReflectionListView()
}
