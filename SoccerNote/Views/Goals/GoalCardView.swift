// SoccerNote/Views/Goals/GoalCardView.swift
import SwiftUI
import CoreData

struct GoalCardView: View {
    let goal: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 目標タイトルと進捗ステータス
            HStack {
                Text(goal.value(forKey: "title") as? String ?? "")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                // 完了/進行中アイコン
                if goal.value(forKey: "isCompleted") as? Bool ?? false {
                    Label("達成", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Label("進行中", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(Color.appAccent)
                }
            }
            
            // 期限表示
            if let deadline = goal.value(forKey: "deadline") as? Date {
                Text("期限: \(formattedDate(deadline))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 進捗バー
            VStack(alignment: .leading, spacing: 4) {
                let progress = Double(goal.value(forKey: "progress") as? Int ?? 0) / 100.0
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor(progress)))
                
                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(progressColor(progress))
                    
                    Spacer()
                    
                    // 残り日数表示
                    if let daysRemaining = daysRemaining, !isCompleted {
                        Text("残り\(daysRemaining)日")
                            .font(.caption)
                            .foregroundColor(daysRemaining < 7 ? .red : .secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.appShadow, radius: 3, x: 0, y: 2)
    }
    
    // 進捗に応じた色
    private func progressColor(_ progress: Double) -> Color {
        if progress < 0.3 {
            return .red
        } else if progress < 0.7 {
            return .orange
        } else {
            return .green
        }
    }
    
    // 日付フォーマット
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 残り日数計算
    private var daysRemaining: Int? {
        guard let deadline = goal.value(forKey: "deadline") as? Date else {
            return nil
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let deadlineDay = calendar.startOfDay(for: deadline)
        
        return calendar.dateComponents([.day], from: today, to: deadlineDay).day
    }
    
    // 完了フラグ
    private var isCompleted: Bool {
        return goal.value(forKey: "isCompleted") as? Bool ?? false
    }
}

struct GoalCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Goal")
        let goals = try! context.fetch(request)
        
        return GoalCardView(goal: goals.first!)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
