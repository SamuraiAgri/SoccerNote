// SoccerNote/Views/Components/CardView.swift
import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(AppDesign.secondaryBackground)
            .cornerRadius(AppDesign.CornerRadius.medium)
            .shadow(radius: 1)
    }
}

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
