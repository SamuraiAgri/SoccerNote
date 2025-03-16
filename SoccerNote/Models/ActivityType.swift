import Foundation

public enum ActivityType: String, CaseIterable, Identifiable {
    case match = "試合"
    case practice = "練習"
    
    public var id: String { self.rawValue }
}
