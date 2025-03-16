// SoccerNote/Views/Components/CardView.swift
import SwiftUI

struct CardView: View {
    let title: String
    let content: String
    var icon: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.medium) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(AppDesign.primaryColor)
                }
                
                Text(title)
                    .font(.appHeadline())
            }
            
            Text(content)
                .font(.appBody())
        }
        .padding()
        .background(AppDesign.backgroundColor)
        .cornerRadius(AppDesign.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    CardView(
        title: "今日のトレーニング",
        content: "ドリブル練習とシュート練習を行いました。",
        icon: "figure.soccer"
    )
    .previewLayout(.sizeThatFits)
    .padding()
}
