import Foundation
import SwiftData
import CoreLocation

@Model
class Storage {
    var id: UUID
    var mainPath: URL
    var thumbnailPath: URL
    var createdAt: Date
    var expiredAt: Date
    
    // Location properties
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var locationName: String?
    
    var isExpired: Bool {
        return Date() > expiredAt
    }
    
    var timeRemaining: TimeInterval {
        max(0, expiredAt.timeIntervalSince(Date()))
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    // Default 24 hours
    init(createdAt: Date = Date(), mainPath: URL, thumbnailPath: URL, location: CLLocation? = nil) {
        self.id = UUID()
        self.createdAt = createdAt
        self.expiredAt = createdAt.addingTimeInterval(24 * 60 * 60)
        self.mainPath = mainPath
        self.thumbnailPath = thumbnailPath
        
        if let location = location {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.altitude = location.altitude
        }
    }
    
    // Custom expiration time
    init(createdAt: Date = Date(), expiredAt seconds: TimeInterval, mainPath: URL, thumbnailPath: URL, location: CLLocation? = nil) {
        self.id = UUID()
        self.createdAt = createdAt
        self.expiredAt = createdAt.addingTimeInterval(seconds)
        self.mainPath = mainPath
        self.thumbnailPath = thumbnailPath
        
        if let location = location {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.altitude = location.altitude
        }
    }
}
