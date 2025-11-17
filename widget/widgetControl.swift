//
//  widgetControl.swift
//  widget
//
//  Created by Gede Pramananda Kusuma Wisesa on 28/10/25.
//

import AppIntents
import SwiftUI
import WidgetKit

struct widgetControl: ControlWidget {
    static let kind: String = Bundle.main.object(forInfoDictionaryKey: "MainAppBundleIdentifier") as! String + ".widget"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: OpenCameraIntent()) {
                Label("Capture Snaps", systemImage: "camera.viewfinder")
            }
        }
        .displayName("Capture Snaps")
        .description("Quickly open camera to capture media")
    }
}
