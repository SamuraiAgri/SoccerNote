// SoccerNote/Views/Components/EmptyStateView.swift
import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: AppDesign.Spacing.large) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppDesign.secondaryText)
            
            Text(title)
                .font(.appHeadline())
            
            Text(message)
                .font(.appCaption())
                .multilineTextAlignment(.center)
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                Button(action: buttonAction) {
                    Text(buttonTitle)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, AppDesign.Spacing.large)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
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
