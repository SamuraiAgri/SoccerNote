import SwiftUI

// ローディングインジケーター
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            Text("読み込み中...")
                .font(.caption)
                .padding(.top, 8)
        }
        .frame(width: 120, height: 120)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

// エラーメッセージ表示
struct ErrorBanner: View {
    let message: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
}

// 改良された日付選択フィールド
struct DatePickerField: View {
    @Binding var date: Date
    var label: String
    var displayComponents: DatePickerComponents = [.date]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
            
            DatePicker("", selection: $date, displayedComponents: displayComponents)
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

// 画像リサイズユーティリティ
struct ImageResizer {
    // 画像サイズを縮小して最適化
    static func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    // JPEG圧縮して最適化
    static func compressImage(_ image: UIImage, quality: CGFloat = 0.7) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
}

// 入力検証
struct ValidationRules {
    // 文字列フィールドの長さ制限
    static let maxLocationLength = 100
    static let maxNotesLength = 1000
    static let maxOpponentLength = 100
    static let maxScoreLength = 10
    static let maxFocusLength = 100
    
    // 数値フィールドの範囲制限
    static let ratingRange = 1...5
    static let goalsRange = 0...20
    static let assistsRange = 0...20
    static let playingTimeRange = 0...120
    static let performanceRange = 1...10
    static let durationRange = 0...300
    static let intensityRange = 1...5
    
    // 入力検証メソッド
    static func validateLocationInput(_ location: String) -> Bool {
        return !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               location.count <= maxLocationLength
    }
    
    static func validateNotesInput(_ notes: String) -> Bool {
        return notes.count <= maxNotesLength
    }
    
    static func validateOpponentInput(_ opponent: String) -> Bool {
        return !opponent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               opponent.count <= maxOpponentLength
    }
    
    static func validateScoreInput(_ score: String) -> Bool {
        return !score.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               score.count <= maxScoreLength
    }
    
    static func validateFocusInput(_ focus: String) -> Bool {
        return !focus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               focus.count <= maxFocusLength
    }
    
    static func isInRange<T: Comparable>(_ value: T, range: ClosedRange<T>) -> Bool {
        return range.contains(value)
    }
}
