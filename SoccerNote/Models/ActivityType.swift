// SoccerNote/Models/ActivityType.swift
import Foundation

enum ActivityType: String, CaseIterable, Identifiable {
    case match = "試合"
    case practice = "練習"
    
    var id: String { self.rawValue }
}
