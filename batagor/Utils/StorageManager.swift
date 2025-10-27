//
//  PhotoStorageManager.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/10/25.
//

import Foundation
import UIKit

class StorageManager {
    static let shared = StorageManager()
    private let photosDirectory: URL
    private let moviesDirectory: URL
    private let thumbnailsDirectory: URL
    
    private init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        photosDirectory = paths[0].appendingPathComponent("Photos", isDirectory: true)
        moviesDirectory = paths[0].appendingPathComponent("Movies", isDirectory: true)
        thumbnailsDirectory = paths[0].appendingPathComponent("Thumbnails", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: moviesDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)
    }
    
    func savePhoto(_ image: UIImage) -> URL? {
        let filename = "\(UUID().uuidString)"
        let fileURL = photosDirectory.appendingPathComponent(filename)
        guard let data = image.heicData() else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
    
    func saveThumbnail(_ image: UIImage) -> URL? {
        let filename = "\(UUID().uuidString)"
        let fileURL = thumbnailsDirectory.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.3) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
    
    func loadThumbnail(fileURL: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        print(fileURL)
        return UIImage(data: data)
    }
    
    func deleteFile(fileURL: URL) {
        try? FileManager.default.removeItem(at: fileURL)
        print("\(fileURL.absoluteString) deleted at \(Date())")
    }
}
