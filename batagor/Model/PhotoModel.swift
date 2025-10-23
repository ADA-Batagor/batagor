//
//  PhotoModel.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/10/25.
//

import Foundation
import SwiftData

@Model
class Photo {
    var id: UUID
    var filePath: String
    var createdAt: Date
    var expiredAt: Date
    
    var isExpired: Bool {
        return Date() > expiredAt
    }
    
    var timeRemaining: TimeInterval {
        max(0, expiredAt.timeIntervalSince(Date()))
    }
    
    // Default 24 hours
    init(createdAt: Date = Date(), filePath: String) {
        self.id = UUID()
        self.createdAt = createdAt
        self.expiredAt = createdAt.addingTimeInterval(24 * 60 * 60)
        self.filePath = filePath
    }
    
    // Custom expiration time
    init(createdAt: Date = Date(), expiredAt seconds: TimeInterval, filePath: String) {
        self.id = UUID()
        self.createdAt = createdAt
        self.expiredAt = createdAt.addingTimeInterval(seconds)
        self.filePath = filePath
    }
}
