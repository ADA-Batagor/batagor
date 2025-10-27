//
//  PhotoModel.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/10/25.
//

import Foundation
import SwiftData

@Model
class Storage {
    var id: UUID
    var mainPath: URL
    var thumbnailPath: URL
    var createdAt: Date
    var expiredAt: Date
    
    var isExpired: Bool {
        return Date() > expiredAt
    }
    
    var timeRemaining: TimeInterval {
        max(0, expiredAt.timeIntervalSince(Date()))
    }
    
    // Default 24 hours
    init(createdAt: Date = Date(), mainPath: URL, thumbnailPath: URL) {
        self.id = UUID()
        self.createdAt = createdAt
        self.expiredAt = createdAt.addingTimeInterval(24 * 60 * 60)
        self.mainPath = mainPath
        self.thumbnailPath = thumbnailPath
    }
    
    // Custom expiration time
    init(createdAt: Date = Date(), expiredAt seconds: TimeInterval, mainPath: URL, thumbnailPath: URL) {
        self.id = UUID()
        self.createdAt = createdAt
        self.expiredAt = createdAt.addingTimeInterval(seconds)
        self.mainPath = mainPath
        self.thumbnailPath = thumbnailPath
    }
}
