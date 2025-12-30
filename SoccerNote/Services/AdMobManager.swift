// SoccerNote/Services/AdMobManager.swift
import SwiftUI
import GoogleMobileAds

class AdMobManager: NSObject, ObservableObject {
    static let shared = AdMobManager()
    
    // AdMob IDs
    struct AdIDs {
        static let appID = "ca-app-pub-8001546494492220~3867474657"
        static let bannerID = "ca-app-pub-8001546494492220/7425701391"
        static let interstitialID = "ca-app-pub-8001546494492220/4944854193"
        
        // テスト用ID (開発時はこちらを使用)
        static let testBannerID = "ca-app-pub-3940256099942544/2435281174"
        static let testInterstitialID = "ca-app-pub-3940256099942544/4411468910"
    }
    
    @Published var interstitialAd: GADInterstitialAd?
    @Published var isInterstitialReady = false
    
    private var interstitialLoadCount = 0
    private let showInterstitialEvery = 3 // 3回に1回表示
    
    private override init() {
        super.init()
    }
    
    func initialize() {
        GADMobileAds.sharedInstance().start { status in
            print("AdMob SDK initialized")
            // 初期化後にインタースティシャル広告をロード
            self.loadInterstitial()
        }
    }
    
    // MARK: - Interstitial Ad
    
    func loadInterstitial() {
        let request = GADRequest()
        
        GADInterstitialAd.load(
            withAdUnitID: AdIDs.interstitialID,
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                self?.isInterstitialReady = false
                return
            }
            
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
            self?.isInterstitialReady = true
            print("Interstitial ad loaded successfully")
        }
    }
    
    func showInterstitialIfNeeded(from viewController: UIViewController?) {
        interstitialLoadCount += 1
        
        // 指定回数ごとに広告を表示
        guard interstitialLoadCount % showInterstitialEvery == 0 else {
            return
        }
        
        if let ad = interstitialAd, isInterstitialReady {
            guard let viewController = viewController else {
                print("View controller not available")
                return
            }
            
            ad.present(fromRootViewController: viewController)
        } else {
            print("Interstitial ad wasn't ready")
            // 次回のために再ロード
            loadInterstitial()
        }
    }
    
    func resetInterstitialCount() {
        interstitialLoadCount = 0
    }
}

// MARK: - GADFullScreenContentDelegate

extension AdMobManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial ad dismissed")
        // 広告が閉じられたら次の広告をロード
        loadInterstitial()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Failed to present interstitial ad: \(error.localizedDescription)")
        // エラーが発生したら再ロード
        loadInterstitial()
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("Interstitial ad recorded impression")
    }
}
