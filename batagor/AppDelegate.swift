//
//  AppDelegate.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 30/10/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            print("Launching shortcut: \(shortcutItem.type)")
            ShortcutManager.shared.handleShortcut(shortcutItem)
        }
        
        let configuration = UISceneConfiguration(name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)
        
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("Detecting shortcut: \(shortcutItem.type)")
        ShortcutManager.shared.handleShortcut(shortcutItem)
        completionHandler(true)
    }
}
