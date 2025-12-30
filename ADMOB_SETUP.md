# AdMob 実装手順書

## 完了した作業
✅ AdMobManager の作成
✅ BannerAdView コンポーネントの作成
✅ アプリ初期化時の AdMob SDK 初期化
✅ 主要画面へのバナー広告配置（ホーム、カレンダー、統計）
✅ インタースティシャル広告の実装（振り返り保存時）

## Xcode で必要な手順

### 1. Google Mobile Ads SDK の追加

1. **Xcode でプロジェクトを開く**
2. **File → Add Package Dependencies...** を選択
3. 検索バーに以下のURLを入力:
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads.git
   ```
4. **Dependency Rule** で "Up to Next Major Version" を選択（最新バージョン）
5. **Add Package** をクリック
6. **GoogleMobileAds** にチェックを入れて **Add Package** をクリック

### 2. Info.plist の設定

1. **プロジェクトナビゲーター** で `SoccerNote` ターゲットを選択
2. **Info** タブを開く
3. **Custom iOS Target Properties** セクションで右クリック → **Add Row**
4. 以下のキーと値を追加:

   ```xml
   Key: GADApplicationIdentifier
   Type: String
   Value: ca-app-pub-8001546494492220~3867474657
   ```

5. App Tracking Transparency (iOS 14+) のために以下も追加:
   ```xml
   Key: NSUserTrackingUsageDescription
   Type: String
   Value: 広告のパーソナライズに使用されます
   ```

### 3. App Transport Security の設定（必要な場合）

Info.plist に以下を追加（既に存在する場合はスキップ）:

```xml
Key: NSAppTransportSecurity
Type: Dictionary
  └─ NSAllowsArbitraryLoadsInWebContent
     Type: Boolean
     Value: YES
```

### 4. ビルド設定の確認

1. プロジェクト設定 → **Build Settings** を開く
2. "Other Linker Flags" を検索
3. 以下のフラグが含まれていることを確認（自動的に追加されます）:
   - `-ObjC`

## 広告ID情報

### バナー広告
- App ID: `ca-app-pub-8001546494492220~3867474657`
- Ad Unit ID: `ca-app-pub-8001546494492220/7425701391`

### インタースティシャル広告
- App ID: `ca-app-pub-8001546494492220~3867474657`
- Ad Unit ID: `ca-app-pub-8001546494492220/4944854193`

## 実装済みの機能

### バナー広告
以下の画面の下部にバナー広告が表示されます:
- ✅ ホーム画面 (HomeView)
- ✅ カレンダー画面 (CalendarTabView)
- ✅ 統計画面 (GrowthInsightsView)

### インタースティシャル広告
- ✅ 振り返り保存時に3回に1回表示
- ✅ 自動ロード・リロード機能

## テスト方法

### 開発中のテスト
現在のコードは本番の Ad Unit ID を使用していますが、テスト中は以下の手順でテスト広告に切り替えることを推奨します:

1. `AdMobManager.swift` を開く
2. `AdIDs` 構造体内で以下のように変更:
   ```swift
   // 本番用（現在使用中）
   static let bannerID = "ca-app-pub-8001546494492220/7425701391"
   static let interstitialID = "ca-app-pub-8001546494492220/4944854193"
   
   // テスト用に切り替える場合
   static let bannerID = testBannerID
   static let interstitialID = testInterstitialID
   ```

### 実機テスト
1. Info.plist の設定完了後、実機またはシミュレーターでビルド
2. アプリを起動してバナー広告が表示されることを確認
3. 振り返りを3回保存してインタースティシャル広告が表示されることを確認

## トラブルシューティング

### 広告が表示されない場合
1. Info.plist に GADApplicationIdentifier が正しく設定されているか確認
2. コンソールログでエラーメッセージを確認
3. ネットワーク接続を確認
4. 新規の Ad Unit ID は承認に時間がかかる場合があります（最大1時間）

### ビルドエラーが出る場合
1. Swift Package Manager のキャッシュをクリア: **File → Packages → Reset Package Caches**
2. Clean Build Folder: **Product → Clean Build Folder** (⌘⇧K)
3. Derived Data を削除: **Xcode → Settings → Locations → Derived Data** から削除

## 次のステップ

1. ✅ SDK の追加
2. ✅ Info.plist の設定
3. ✅ テスト広告での動作確認
4. ✅ 本番 Ad Unit ID に切り替え
5. ✅ App Store 提出前の最終確認

## 注意事項

- **自分でクリックしない**: 開発者が自分の広告をクリックすると、AdMob のポリシー違反となる可能性があります
- **テスト広告を使用**: 開発中は必ずテスト Ad Unit ID を使用してください
- **本番環境**: App Store 提出前に本番の Ad Unit ID に戻すことを忘れずに
