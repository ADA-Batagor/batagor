//
//  PhotoDeletionService.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/10/25.
//

import Foundation
import SwiftData
import BackgroundTasks

class PhotoDeletionService {
    static let shared = PhotoDeletionService()
    static let backgroundTaskIdentifier = "com.tudemaha.batagor"
    
    @MainActor
    func performCleanup(modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<Photo>()
        
        guard let allPhotos = try? modelContext.fetch(descriptor) else {
            return
        }
        
        let now = Date()
        let expiredPhotos: [Photo] = allPhotos.filter {
            $0.expiredAt < now
        }
        
        guard !expiredPhotos.isEmpty else {
            return 
        }
        
        for photo in expiredPhotos {
            PhotoStorageManager.shared.deletePhoto(filename: photo.filePath)
            modelContext.delete(photo)
        }
        
        try? modelContext.save()
    }
    
    func scheduleBackgroundCleanup() {
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        try? BGTaskScheduler.shared.submit(request)
    }
}
