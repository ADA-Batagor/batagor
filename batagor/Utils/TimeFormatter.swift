//
//  TimeFormatter.swift
//  batagor
//
//  Created by Tude Maha on 03/11/2025.
//

import Foundation

class TimeFormatter {
    static func formatTimeRemaining(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        
        if hours > 0 {
            return String(format: "%dh", hours)
        } else {
            return String(format: "< 1h")
        }
    }
    
    static func formatHourRemaining(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        
        if hours > 0 {
            return String(format: "%d hours left", hours)
        } else {
            return String(format: "less than hour left")
        }
        
    }
}
