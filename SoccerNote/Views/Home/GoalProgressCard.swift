// SoccerNote/Views/Home/GoalProgressCard.swift
import SwiftUI
import CoreData

struct GoalProgressCard: View {
    let goal: NSManagedObject
    
    var body: some View {
        NavigationLink(destination: GoalDetailView(goal: goal, goalViewModel: GoalViewModel(viewContext: goal.managedObjectContext!))) {
            VStack(alignment: .leading) {
                Text(goal.value(forKey: "title") as? String ?? "")
                    .font(.appHeadline())
                    .lineLimit(1)
                
                Text(formattedDeadline)
                    .font(.caption)
                    .foregroundColor(AppDesign.secondaryText)
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .padding(.vertical, 5)
                
                Text("\(progress * 100, specifier: "%.0f")%")
                    .font(.caption)
                    .foregroundColor(progressColor)
            }
            .padding()
            .background(AppDesign.secondaryBackground)
            .cornerRadius(AppDesign.CornerRadius.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // ヘルパープロパティ
    private var progress: Double {
        Double(goal.value(forKey: "progress") as? Int ?? 0) / 100.0
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
    return GoalProgressCard(goal: goals.first!)
}
