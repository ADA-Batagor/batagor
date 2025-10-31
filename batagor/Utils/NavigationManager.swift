//
//  NavigationManager.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 30/10/25.
//

import Foundation
import SwiftUI

enum AppDestination: Hashable {
    case camera
    case gallery
}

@MainActor
class NavigationManager: ObservableObject {
    @Published var selectedTab: AppDestination = .gallery
    
    static let shared = NavigationManager()
    
    private init() {}
    
    func navigate(to destination: AppDestination) {
        print("Navigating to \(destination)")
        selectedTab = destination
    }
}
