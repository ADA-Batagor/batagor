//
//  CameraViewModel.swift
//  batagor
//
//  Created by Tude Maha on 22/10/2025.
//

import AVFoundation
import SwiftUI
import SwiftData

@MainActor
class CameraViewModel: ObservableObject {
    let camera = CameraManager()
    let storageManager = PhotoStorageManager.shared
            
    @Published var cameraMode: CameraMode = .photo
    @Published var previewImage: Image?
    @Published var photoTaken: PhotoData?
    @Published var movieFileURL: URL?
    
    init() {
        
        Task {
            await handleCameraPreview()
        }
        
        Task {
            await handleCameraPhoto()
        }
        
        Task {
            await handleCameraMovie()
        }
    }
    
    func handleCameraPreview() async {
        let imageStream = camera.previewStream
            .map { $0.image }
        
        for await image in imageStream {
            Task { @MainActor in
                previewImage = image
            }
        }
    }
    
    func handleCameraPhoto() async {
        let unpackedPhotoStream = camera.photoStream
            .compactMap { await self.unpackPhoto($0) }
        
        for await photoData in unpackedPhotoStream {
            
            Task { @MainActor in
                photoTaken = photoData
            }
        }
    }
    
    func handleCameraMovie() async {
        let fileUrlStream = camera.movieFileStream
        
        for await url in fileUrlStream {
            Task { @MainActor in
                movieFileURL = url
            }
        }
    }
    
    func handleSavePhoto(context: ModelContext) {
        if let image = photoTaken {
            let savePhoto = UIImage(data: image.imageData)!
            if let filename = storageManager.savePhoto(savePhoto) {
                let photo = Photo(createdAt: Date(), expiredAt: 60, filePath: filename)
                context.insert(photo)
                print("Added \(filename)")
            }
            
            try? context.save()
            print("Photo saved!")
        }
        
        photoTaken = nil
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }
        
        guard let cgImage = photo.cgImageRepresentation(),
              let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation)
        else { return nil }
        
        let imageOrientation = UIImage.Orientation(cgImageOrientation)
        let image = Image(uiImage: UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation))
        let photoDimentions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimentions.width), height: Int(photoDimentions.height))
        
        return PhotoData(image: image, imageData: imageData, imageSize: imageSize)
    }
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate extension UIImage.Orientation {
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

struct PhotoData {
    var image: Image
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

enum CameraMode {
    case photo, video
}

extension CameraMode {
    mutating func toggle() {
        if self == .photo {
            self = .video
        } else {
            self = .photo
        }
    }
}
