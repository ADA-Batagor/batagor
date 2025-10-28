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
    @StateObject private var sharedTaskManager = SharedTimerManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Storage.self,
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
                .onAppear {
                    PhotoSeeder.shared.seed(modelContext: sharedModelContainer.mainContext)
                    Task { @MainActor in
                        await DeletionService.shared.performCleanup(modelContext: sharedModelContainer.mainContext)
                    }
                }
                .environmentObject(sharedTaskManager)
        }
        .modelContainer(sharedModelContainer)
        .backgroundTask(.appRefresh(DeletionService.backgroundTaskIdentifier)) { @MainActor in
            await DeletionService.shared.performCleanup(modelContext: sharedModelContainer.mainContext)
            DeletionService.shared.scheduleBackgroundCleanup()
        }
    }
}
