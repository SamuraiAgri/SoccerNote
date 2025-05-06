// SoccerNote/Services/DesignSystem.swift
import SwiftUI

// アプリのデザインガイド
struct AppDesign {
    // メインカラー - アセットではなくExtensionから取得
    static let primaryColor = Color.appPrimary
    static let secondaryColor = Color.appSecondary
    static let accentColor = Color.appAccent
    
    // テキストカラー
    static let primaryText = Color.appPrimaryText
    static let secondaryText = Color.appSecondaryText
    
    // コンポーネントカラー
    static let backgroundColor = Color.appBackground
    static let secondaryBackground = Color.appBackgroundSecondary
    static let dividerColor = Color.appDivider
    
    // フォントサイズ
    struct FontSize {
        static let title = 28.0
        static let header = 20.0
        static let body = 16.0
        static let caption = 12.0
    }
    
    // 角丸サイズ
    struct CornerRadius {
        static let small = 5.0
        static let medium = 10.0
        static let large = 15.0
    }
    
    // 間隔
    struct Spacing {
        static let small = 5.0
        static let medium = 10.0
        static let large = 20.0
    }
    
    // アニメーション
    struct Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    }
    
    // カラーテーマの設定
    static func setupAppearance() {
        // タブバーの外観
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = UIColor(primaryColor)
        
        // ナビゲーションバーの外観
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(primaryText)]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(primaryText)]
        
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().tintColor = UIColor(primaryColor)
    }
}
