// SoccerNote/Extensions/Color+Extension.swift
import SwiftUI

extension Color {
    // メインカラー - RGB値で直接定義（アセットに依存しない）
    static let appPrimary = Color(red: 38/255, green: 155/255, blue: 75/255) // より鮮やかな緑
    static let appSecondary = Color(red: 252/255, green: 163/255, blue: 17/255) // 明るいオレンジ
    static let appAccent = Color(red: 0/255, green: 122/255, blue: 255/255) // 鮮やかなブルー
    
    // アクセントカラー（タッチポイント用）
    static let appSuccess = Color(red: 52/255, green: 199/255, blue: 89/255) // 成功グリーン
    static let appWarning = Color(red: 255/255, green: 149/255, blue: 0/255) // 警告オレンジ
    static let appError = Color(red: 255/255, green: 59/255, blue: 48/255) // エラー赤
    
    // テキストカラー
    static let appPrimaryText = Color(red: 33/255, green: 33/255, blue: 33/255)
    static let appSecondaryText = Color(red: 120/255, green: 120/255, blue: 120/255)
    
    // バックグラウンドカラー
    static let appBackground = Color(UIColor.systemBackground)
    static let appBackgroundSecondary = Color(UIColor.secondarySystemBackground)
    
    // ユーティリティカラー
    static let appDivider = Color.gray.opacity(0.3)
    static let appShadow = Color.black.opacity(0.05)
    
    // シャドウカラー
    struct Shadow {
        static let light = Color.black.opacity(0.06)
        static let medium = Color.black.opacity(0.12)
        static let strong = Color.black.opacity(0.18)
    }
}
