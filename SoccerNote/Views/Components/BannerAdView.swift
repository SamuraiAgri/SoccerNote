// SoccerNote/Views/Components/BannerAdView.swift
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    @StateObject private var adMobManager = AdMobManager.shared
    
    init(adUnitID: String = AdMobManager.AdIDs.bannerID) {
        self.adUnitID = adUnitID
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        banner.rootViewController = UIApplication.shared.getRootViewController()
        
        // AdMobが初期化されている場合のみ広告をロード
        if adMobManager.isInitialized {
            banner.load(GADRequest())
        } else {
            // 初期化を待ってからロード
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                banner.load(GADRequest())
            }
        }
        
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // 必要に応じて更新
    }
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("✅ Banner ad loaded successfully")
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ Banner ad failed to load: \(error.localizedDescription)")
        }
    }
}

// MARK: - UIApplication Extension

extension UIApplication {
    func getRootViewController() -> UIViewController? {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        // presentedViewControllerがある場合はそれを返す
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        return topController
    }
}

// MARK: - Banner Ad Modifier

struct BannerAdViewModifier: ViewModifier {
    let position: BannerPosition
    
    enum BannerPosition {
        case top
        case bottom
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if position == .top {
                BannerAdView()
                    .frame(height: 50)
                    .background(Color(.systemBackground))
            }
            
            content
            
            if position == .bottom {
                BannerAdView()
                    .frame(height: 50)
                    .background(Color(.systemBackground))
            }
        }
    }
}

extension View {
    func bannerAd(position: BannerAdViewModifier.BannerPosition = .bottom) -> some View {
        modifier(BannerAdViewModifier(position: position))
    }
}
