//
//  FileManager+Ext.swift
//  batagor
//
//  Created by Fuad Fajri on 06/11/25.
//

import Foundation

extension FileManager {
    /// Safely gets the size of a file at a given URL.
    /// Returns 0 if the file doesn't exist or an error occurs.
    func getSizeOfFile(at url: URL) -> Int64 {
        guard fileExists(atPath: url.path()) else {
            return 0
        }
        
        do {
            let attributes = try attributesOfItem(atPath: url.path())
            return (attributes[.size] as? NSNumber)?.int64Value ?? 0
        } catch {
            print("Error getting attributes for file at \(url.path()): \(error.localizedDescription)")
            return 0
        }
    }
}
