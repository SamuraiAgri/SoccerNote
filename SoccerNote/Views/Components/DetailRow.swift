// SoccerNote/Views/Components/DetailRow.swift
import SwiftUI

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            
            Text(value)
                .font(.body)
                .padding(.bottom, 5)
        }
    }
}

#Preview {
    DetailRow(title: "場所", value: "市民グラウンド")
}
