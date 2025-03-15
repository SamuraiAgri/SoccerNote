// SoccerNote/Services/DesignSystem.swift
import SwiftUI

// アプリのデザインガイド
struct AppDesign {
    // メインカラー
    static let primaryColor = Color("PrimaryColor")
    static let secondaryColor = Color("SecondaryColor")
    static let accentColor = Color("AccentColor")
    
    // テキストカラー
    static let primaryText = Color("PrimaryTextColor")
    static let secondaryText = Color("SecondaryTextColor")
    
    // コンポーネントカラー
    static let backgroundColor = Color.white
    static let secondaryBackground = Color("BackgroundSecondary")
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

// SoccerNote/Resources/AppFontsExtension.swift
import SwiftUI

extension Font {
    // タイトル用フォント
    static func appTitle() -> Font {
        return .system(size: AppDesign.FontSize.title, weight: .bold, design: .default)
    }
    
    // 見出し用フォント
    static func appHeadline() -> Font {
        return .system(size: AppDesign.FontSize.header, weight: .semibold, design: .default)
    }
    
    // 本文用フォント
    static func appBody() -> Font {
        return .system(size: AppDesign.FontSize.body, weight: .regular, design: .default)
    }
    
    // 注釈用フォント
    static func appCaption() -> Font {
        return .system(size: AppDesign.FontSize.caption, weight: .regular, design: .default)
    }
    
    // 強調用フォント
    static func appEmphasized() -> Font {
        return .system(size: AppDesign.FontSize.body, weight: .bold, design: .default)
    }
    
    // ボタン用フォント
    static func appButton() -> Font {
        return .system(size: AppDesign.FontSize.body, weight: .medium, design: .default)
    }
}

// SoccerNote/Resources/AppIconsExtension.swift
import SwiftUI

struct AppIcons {
    // タブアイコン
    struct Tab {
        static let home = "house.fill"
        static let records = "list.bullet.rectangle"
        static let add = "plus.circle.fill"
        static let stats = "chart.bar.fill"
        static let goals = "flag.fill"
    }
    
    // 活動タイプアイコン
    struct Activity {
        static let match = "sportscourt.fill"
        static let practice = "figure.walk"
    }
    
    // 機能アイコン
    struct Function {
        static let calendar = "calendar"
        static let add = "plus.circle"
        static let edit = "pencil"
        static let delete = "trash"
        static let save = "square.and.arrow.down"
        static let share = "square.and.arrow.up"
        static let filter = "line.horizontal.3.decrease.circle"
        static let sort = "arrow.up.arrow.down"
        static let search = "magnifyingglass"
    }
    
    // 評価アイコン
    struct Rating {
        static let starFill = "star.fill"
        static let star = "star"
        static let circle = "circle"
        static let circleFill = "circle.fill"
    }
    
    // ステータスアイコン
    struct Status {
        static let checkmark = "checkmark.circle.fill"
        static let clock = "clock"
        static let warning = "exclamationmark.triangle"
        static let info = "info.circle"
    }
}
