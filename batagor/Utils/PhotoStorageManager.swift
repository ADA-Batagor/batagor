//
//  PhotoStorageManager.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/10/25.
//

import Foundation
import UIKit

class PhotoStorageManager {
    static let shared = PhotoStorageManager()
    private let photosDirectory: URL
    
    private init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        photosDirectory = paths[0].appendingPathComponent("Photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
    }
    
    func savePhoto(_ image: UIImage) -> String? {
        let filename = "\(UUID().uuidString)"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            return nil
        }
    }
    
    func loadPhoto(filename: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    func deletePhoto(filename: String) {
        let fileURL = photosDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
        print("Photo \(filename) deleted at \(Date()).")
    }
}
