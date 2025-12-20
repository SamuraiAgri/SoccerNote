// SoccerNote/Views/Components/ToastView.swift
import SwiftUI

// トースト表示用のモデル
struct ToastData: Equatable {
    var type: ToastType
    var message: String
    var duration: Double = 3.0
    
    enum ToastType {
        case success
        case error
        case warning
        case info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
    }
}

// トーストビュー
struct ToastView: View {
    let toast: ToastData
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .foregroundColor(.white)
                .font(.system(size: 20))
            
            Text(toast.message)
                .foregroundColor(.white)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(toast.type.color)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
}

// トースト表示用のビューモディファイア
struct ToastModifier: ViewModifier {
    @Binding var toast: ToastData?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let toast = toast {
                VStack {
                    Spacer()
                    ToastView(toast: toast)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: toast)
                        .padding(.bottom, 100)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                        withAnimation {
                            self.toast = nil
                        }
                    }
                }
            }
        }
    }
}

// 便利な拡張
extension View {
    func toast(_ toast: Binding<ToastData?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}

// ハプティックフィードバックユーティリティ
struct HapticFeedback {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

#Preview {
    VStack {
        Spacer()
        ToastView(toast: ToastData(type: .success, message: "記録が保存されました"))
        ToastView(toast: ToastData(type: .error, message: "エラーが発生しました"))
        ToastView(toast: ToastData(type: .warning, message: "注意が必要です"))
        ToastView(toast: ToastData(type: .info, message: "情報を表示しています"))
        Spacer()
    }
}
