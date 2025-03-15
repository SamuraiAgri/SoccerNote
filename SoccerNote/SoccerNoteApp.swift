//
//  SoccerNoteApp.swift
//  SoccerNote
//
//  Created by iwamoto rinka on 2025/03/15.
//

import SwiftUI

@main
struct SoccerNoteApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
