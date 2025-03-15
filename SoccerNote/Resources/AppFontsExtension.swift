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
