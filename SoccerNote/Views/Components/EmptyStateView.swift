// SoccerNote/Views/Components/EmptyStateView.swift
import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.7))
            
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                Button(action: buttonAction) {
                    Text(buttonTitle)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppDesign.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        title: "記録がありません",
        message: "「追加」タブから新しい記録を追加しましょう",
        icon: "note.text",
        buttonTitle: "記録を追加",
        buttonAction: {}
    )
}
