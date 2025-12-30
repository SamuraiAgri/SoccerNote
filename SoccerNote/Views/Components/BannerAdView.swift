// SoccerNote/Views/Components/BannerAdView.swift
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    
    init(adUnitID: String = AdMobManager.AdIDs.bannerID) {
        self.adUnitID = adUnitID
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.getRootViewController()
        banner.load(GADRequest())
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // 必要に応じて更新
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
