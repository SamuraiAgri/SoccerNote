// SoccerNote/Views/AddRecord/StarRatingPicker.swift
import SwiftUI

struct StarRatingPicker: View {
    @Binding var rating: Int
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? AppIcons.Rating.starFill : AppIcons.Rating.star)
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        rating = star
                    }
            }
        }
    }
}

#Preview {
    StarRatingPicker(rating: .constant(3))
}
