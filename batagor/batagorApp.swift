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
            Photo.self,
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
//            DefaultView()
            Camera()
                .onAppear {
                    PhotoSeeder.shared.seed(modelContext: sharedModelContainer.mainContext)
                    Task { @MainActor in
                        await PhotoDeletionService.shared.performCleanup(modelContext: sharedModelContainer.mainContext)
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        .backgroundTask(.appRefresh(PhotoDeletionService.backgroundTaskIdentifier)) { @MainActor in
            await PhotoDeletionService.shared.performCleanup(modelContext: sharedModelContainer.mainContext)
            PhotoDeletionService.shared.scheduleBackgroundCleanup()
        }
    }
}
