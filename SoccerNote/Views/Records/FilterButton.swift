// SoccerNote/Views/Records/FilterButton.swift
import SwiftUI

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? AppDesign.primaryColor : AppDesign.secondaryBackground)
                .foregroundColor(isSelected ? .white : AppDesign.primaryText)
                .cornerRadius(20)
        }
    }
}

#Preview {
    HStack {
        FilterButton(title: "すべて", isSelected: true) {}
        FilterButton(title: "試合", isSelected: false) {}
        FilterButton(title: "練習", isSelected: false) {}
    }
    .padding()
}
