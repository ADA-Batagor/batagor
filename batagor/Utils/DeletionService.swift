//
//  PhotoDeletionService.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/10/25.
//

import Foundation
import SwiftData
import BackgroundTasks
import WidgetKit

class DeletionService {
    static let shared = DeletionService()
    static let backgroundTaskIdentifier = Bundle.main.object(forInfoDictionaryKey: "MainAppBundleIdentifier") as! String
    
    // --- ADD THIS KEY ---
        static let totalSpaceClearedKey = "totalSpaceClearedInBytes"
    
    @MainActor
    func performCleanup(modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<Storage>()
        
        guard let allFiles = try? modelContext.fetch(descriptor) else {
            return
        }
        
        let now = Date()
        let expiredFiles: [Storage] = allFiles.filter {
            $0.expiredAt < now
        }
        
        guard !expiredFiles.isEmpty else {
            return
        }
        
        // --- START OF CHANGES ---
                var bytesFreedThisSession: Int64 = 0
                
                for file in expiredFiles {
                    // Add the file's saved size to our session counter
                    bytesFreedThisSession += file.fileSizeInBytes
                    
                    StorageManager.shared.deleteFile(fileURL: file.mainPath)
                    StorageManager.shared.deleteFile(fileURL: file.thumbnailPath)
                    modelContext.delete(file)
                    print("deleted \(file.mainPath.lastPathComponent), freeing \(file.fileSizeInBytes) bytes")
                }
                
                // Now, add the session total to the persistent total in UserDefaults
                if bytesFreedThisSession > 0 {
                    let defaults = UserDefaults.standard
                    let currentTotal = defaults.integer(forKey: Self.totalSpaceClearedKey) // Int64 is too big, use integer
                    let newTotal = currentTotal + Int(bytesFreedThisSession)
                    defaults.setValue(newTotal, forKey: Self.totalSpaceClearedKey)
                    print("Freed \(bytesFreedThisSession) bytes this session. Total space cleared: \(newTotal) bytes.")
                }
                // --- END OF CHANGES ---
        try? modelContext.save()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func scheduleBackgroundCleanup() {
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 )
        
        try? BGTaskScheduler.shared.submit(request)
    }
}
