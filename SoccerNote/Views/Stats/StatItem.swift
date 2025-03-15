// SoccerNote/Views/Stats/StatItem.swift
import SwiftUI

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(AppDesign.secondaryText)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatItem(title: "試合数", value: "10")
}
