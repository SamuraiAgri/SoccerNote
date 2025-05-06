// SoccerNote/Services/DesignSystem.swift
import SwiftUI

// アプリのデザインガイド
struct AppDesign {
    // メインカラー - アセット名をAppPrimaryColorに変更
    static let primaryColor = Color("AppPrimaryColor")
    static let secondaryColor = Color.orange
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
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? (configuration.isPressed ? AppDesign.primaryColor.opacity(0.8) : AppDesign.primaryColor) : Color.gray)
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
    func primaryStyle(isEnabled: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
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
    
    // アニメーション付きのトランジション
    func smoothTransition() -> some View {
        self.transition(.opacity.combined(with: .scale(scale: 0.95)).animation(.easeInOut(duration: 0.2)))
    }
}
