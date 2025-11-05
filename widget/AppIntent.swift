//
//  AppIntent.swift
//  widget
//
//  Created by Gede Pramananda Kusuma Wisesa on 28/10/25.
//

import WidgetKit
import AppIntents
import UIKit

struct OpenCameraIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Camera"
    static var description: IntentDescription = "Opens the camera view in app"
    
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
//        guard let groupIdentifier = Bundle.main.object(forInfoDictionaryKey: "GroupAppBundleIdentifier") as? String else {
//            return .result()
//        }
//        
//        if let sharedDefaults = UserDefaults(suiteName: groupIdentifier) {
//            sharedDefaults.set(true, forKey: "isOpenCamera")
//            sharedDefaults.set(Date().timeIntervalSince1970, forKey: "cameraRequestTimestamp")
//        }
        
        NavigationManager.shared.navigate(to: .camera)
        return .result()
    }
}

struct BatagorAppShortcuts: AppShortcutsProvider {
      static var appShortcuts: [AppShortcut] {
          AppShortcut(
              intent: OpenCameraIntent(),
              phrases: [
                  "Open \(.applicationName) Camera",
                  "Capture with \(.applicationName)",
                  "Take photo with \(.applicationName)"
              ],
              shortTitle: "Open Camera",
              systemImageName: "camera.viewfinder"
          )
      }
  }
