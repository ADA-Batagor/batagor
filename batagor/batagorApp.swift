//
//  batagorApp.swift
//  batagor
//
//  Created by Tude Maha on 21/10/2025.
//

import SwiftUI
import SwiftData

@main
struct batagorApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Camera()
        }
        .modelContainer(sharedModelContainer)
    }
}
