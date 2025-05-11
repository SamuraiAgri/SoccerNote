// SoccerNote/Services/AddSheetController.swift
import SwiftUI

class AddSheetController: ObservableObject {
    @Published var isShowingAddSheet = false
    @Published var preselectedDate: Date? = nil
    
    func showAddSheet(for date: Date? = nil) {
        self.preselectedDate = date
        isShowingAddSheet = true
    }
}
