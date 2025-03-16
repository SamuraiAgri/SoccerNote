// SoccerNote/Services/DesignSystem.swift
import SwiftUI

// アプリのデザインガイド
struct AppDesign {
    // メインカラー - システムカラーを使用
    static let primaryColor = Color.green // サッカーフィールド風の緑
    static let secondaryColor = Color.orange // アクセントカラー
    static let accentColor = Color.blue
    
    // テキストカラー
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    
    // コンポーネントカラー
    static let backgroundColor = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let dividerColor = Color.gray.opacity(0.3)
    
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
}

// カスタムテキストスタイル
extension Text {
    func titleStyle() -> some View {
        self.font(.system(size: AppDesign.FontSize.title, weight: .bold))
            .foregroundColor(AppDesign.primaryText)
    }
    
    func headerStyle() -> some View {
        self.font(.system(size: AppDesign.FontSize.header, weight: .semibold))
            .foregroundColor(AppDesign.primaryText)
    }
    
    func bodyStyle() -> some View {
        self.font(.system(size: AppDesign.FontSize.body))
            .foregroundColor(AppDesign.primaryText)
    }
    
    func captionStyle() -> some View {
        self.font(.system(size: AppDesign.FontSize.caption))
            .foregroundColor(AppDesign.secondaryText)
    }
}

// カスタムボタンスタイル
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppDesign.primaryColor.opacity(configuration.isPressed ? 0.8 : 1))
            .foregroundColor(.white)
            .cornerRadius(AppDesign.CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(AppDesign.Animation.standard, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppDesign.secondaryBackground)
            .foregroundColor(AppDesign.primaryColor)
            .cornerRadius(AppDesign.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppDesign.CornerRadius.medium)
                    .stroke(AppDesign.primaryColor, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(AppDesign.Animation.standard, value: configuration.isPressed)
    }
}

// ボタン拡張
extension Button {
    func primaryStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
    
    func secondaryStyle() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
}

// SwiftUIでカスタムモディファイアを追加
struct RoundedShadowModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(AppDesign.backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 1)
    }
}

extension View {
    func roundedShadow(cornerRadius: CGFloat = AppDesign.CornerRadius.medium, shadowRadius: CGFloat = 3) -> some View {
        self.modifier(RoundedShadowModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}

// カスタムタブバースタイル
struct AppTabBarAppearance {
    static func setupAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = UIColor(AppDesign.primaryColor)
    }
}

// カスタムナビゲーションバースタイル
struct AppNavigationBarAppearance {
    static func setupAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().tintColor = UIColor(AppDesign.primaryColor)
    }
}
