//
//  TimeFormatter.swift
//  batagor
//
//  Created by Tude Maha on 03/11/2025.
//

import Foundation
import AVFoundation

class TimeFormatter {
    static func formatTimeRemaining(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        
        if hours > 0 {
            return String(format: "%dh", hours)
        } else {
            return String(format: "< 1h")
        }
    }
    
    static func getVideoDuration(from url: URL) async -> Double {
        let asset = AVURLAsset(url: url)

        do {
            let duration = try await CMTimeGetSeconds(asset.load(.duration))
            return duration
        } catch {
            print("Failed to get duration: ", error)
            return 0
        }
    }
}
