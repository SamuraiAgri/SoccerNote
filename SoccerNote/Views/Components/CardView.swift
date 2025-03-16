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
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
    }
}

#Preview {
    CardView {
        Text("カードの内容")
            .padding()
    }
    .padding()
}
