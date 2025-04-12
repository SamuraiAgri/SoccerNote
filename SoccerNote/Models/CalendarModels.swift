// SoccerNote/Models/CalendarModels.swift
import Foundation

struct CalendarDay: Hashable {
    let date: Date
    let isPlaceholder: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(isPlaceholder)
    }
    
    static func == (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        return lhs.date == rhs.date && lhs.isPlaceholder == rhs.isPlaceholder
    }
}
