// SoccerNote/Models/ReminderTypeEnum.swift
import Foundation

enum ReminderTypeEnum: String, CaseIterable, Identifiable {
    case match = "試合"
    case practice = "練習"
    
    var id: String { self.rawValue }
}
