// SoccerNote/Views/Goals/GoalRow.swift
import SwiftUI
import CoreData

struct GoalRow: View {
    let goal: NSManagedObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(goal.value(forKey: "title") as? String ?? "")
                    .font(.headline)
                
                Spacer()
                
                Text(progressText)
                    .font(.caption)
                    .foregroundColor(progressColor)
            }
            
            Text(formattedDeadline)
                .font(.caption)
                .foregroundColor(AppDesign.secondaryText)
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
        }
    }
    
    // ヘルパープロパティ
    private var progress: Double {
        Double(goal.value(forKey: "progress") as? Int ?? 0) / 100.0
    }
    
    private var progressText: String {
        "\(Int(progress * 100))%"
    }
    
    private var progressColor: Color {
        if progress < 0.3 {
            return .red
        } else if progress < 0.7 {
            return AppDesign.accentColor
        } else {
            return AppDesign.primaryColor
        }
    }
    
    private var formattedDeadline: String {
        let deadline = goal.value(forKey: "deadline") as? Date ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return "期限: \(formatter.string(from: deadline))"
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let request = NSFetchRequest<NSManagedObject>(entityName: "Goal")
    let goals = try! context.fetch(request)
    return GoalRow(goal: goals.first!)
}
