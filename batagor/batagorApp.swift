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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var sharedTaskManager = SharedTimerManager.shared
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var shortcutManager = ShortcutManager.shared
    
    private var sharedModelContainer = SharedModelContainer.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    switch navigationManager.selectedTab {
                    case .camera:
                        Camera()
                    case .gallery:
                        GalleryView()
                    }
                }
                .onAppear {
                    Task { @MainActor in
                        await DeletionService.shared.performCleanup(modelContext: sharedModelContainer.mainContext)
                        shortcutManager.processShortcutItem(navigationManager: navigationManager)
                    }
               
                }
                .onChange(of: shortcutManager.shortcutItem, { oldValue, newValue in
                    if newValue != nil {
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            shortcutManager.processShortcutItem(navigationManager: navigationManager)
                        }
                    }
                })
                .environmentObject(sharedTaskManager)
                .environmentObject(navigationManager)
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
        .modelContainer(sharedModelContainer)
        .backgroundTask(.appRefresh(DeletionService.backgroundTaskIdentifier)) { @MainActor in
            await DeletionService.shared.performCleanup(modelContext: sharedModelContainer.mainContext)
            DeletionService.shared.scheduleBackgroundCleanup()
        }
        .handlesExternalEvents(matching: [])
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "batagor" else { return }
        
        if url.host == "gallery" {
            navigationManager.navigate(to: .gallery)
        } else if url.host == "camera" {
            navigationManager.navigate(to: .camera)
        }
    }
}
