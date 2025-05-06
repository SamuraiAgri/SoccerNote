// SoccerNote/Extensions/Color+Extension.swift
import SwiftUI

extension Color {
    // メインカラー
    static let appPrimary = Color(red: 60/255, green: 140/255, blue: 60/255)
    static let appSecondary = Color.orange
    static let appAccent = Color.blue
    
    // テキストカラー
    static let appPrimaryText = Color(red: 33/255, green: 33/255, blue: 33/255)
    static let appSecondaryText = Color(red: 120/255, green: 120/255, blue: 120/255)
    
    // バックグラウンドカラー
    static let appBackground = Color(UIColor.systemBackground)
    static let appBackgroundSecondary = Color(UIColor.secondarySystemBackground)
    
    // ユーティリティカラー
    static let appDivider = Color.gray.opacity(0.3)
    static let appShadow = Color.black.opacity(0.05)
}
