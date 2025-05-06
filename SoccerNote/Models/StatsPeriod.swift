// SoccerNote/Models/StatsPeriod.swift
import Foundation

// 統計期間（アプリ全体で共有する定義）
public enum StatsPeriod: String, CaseIterable, Identifiable {
    case week = "週間"
    case month = "月間"
    case season = "シーズン"
    case all = "全期間"
    
    public var id: String { self.rawValue }
    
    public var displayName: String {
        return self.rawValue
    }
}
