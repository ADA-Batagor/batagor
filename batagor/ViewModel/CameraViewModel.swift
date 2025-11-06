import AVFoundation
import SwiftUI
import SwiftData
import WidgetKit
import CoreLocation
import ImageIO

@MainActor
class CameraViewModel: ObservableObject {
    let camera = CameraManager()
    let storageManager = StorageManager.shared
    let locationManager = LocationManager()
    
    @Published var previewImage: Image?
    @Published var photoTaken: PhotoData?
    @Published var movieFileURL: URL?
    
    init() {
        // Request location permission
        locationManager.requestPermission()
        
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
            let photo = UIImage(data: image.imageData)!
            
            // Add location metadata to photo
            let photoWithLocation = addLocationToImage(photo, location: locationManager.currentLocation)
            
            let mainPath = storageManager.savePhoto(photoWithLocation)
            let thumbnailPath = storageManager.saveThumbnail(photoWithLocation)
            
            if let mainPath = mainPath, let thumbnailPath = thumbnailPath {
                let storage = Storage(
                    createdAt: Date(),
                    expiredAt: 5 * 60,
                    mainPath: mainPath,
                    thumbnailPath: thumbnailPath,
                    location: locationManager.currentLocation
                )
                context.insert(storage)
                print("Added \(mainPath) with location: \(locationManager.currentLocation?.coordinate.latitude ?? 0), \(locationManager.currentLocation?.coordinate.longitude ?? 0)")
            }
            
            try? context.save()
            print("Photo saved!")
            
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        photoTaken = nil
    }
    
    func handleSaveMovie(context: ModelContext) {
        if let movieURL = movieFileURL {
            // Add location metadata to video
            addLocationToVideo(at: movieURL, location: locationManager.currentLocation)
            
            let asset = AVURLAsset(url: movieURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                if let thumbnailURL = storageManager.saveThumbnail(UIImage(cgImage: cgImage)) {
                    let storage = Storage(
                        createdAt: Date(),
                        expiredAt: 30,
                        mainPath: movieURL,
                        thumbnailPath: thumbnailURL,
                        location: locationManager.currentLocation
                    )
                    context.insert(storage)
                    try? context.save()
                }
            } catch {
                print("Error: \(error)")
            }
            
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        movieFileURL = nil
    }
    
    // Add GPS metadata to image
    private func addLocationToImage(_ image: UIImage, location: CLLocation?) -> UIImage {
        guard let location = location,
              let imageData = image.jpegData(compressionQuality: 1.0),
              let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let uniformTypeIdentifier = CGImageSourceGetType(source) else {
            return image
        }
        
        let destinationData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(destinationData, uniformTypeIdentifier, 1, nil) else {
            return image
        }
        
        // Create GPS metadata
        let gpsMetadata: [String: Any] = [
            kCGImagePropertyGPSLatitude as String: abs(location.coordinate.latitude),
            kCGImagePropertyGPSLatitudeRef as String: location.coordinate.latitude >= 0 ? "N" : "S",
            kCGImagePropertyGPSLongitude as String: abs(location.coordinate.longitude),
            kCGImagePropertyGPSLongitudeRef as String: location.coordinate.longitude >= 0 ? "E" : "W",
            kCGImagePropertyGPSAltitude as String: location.altitude,
            kCGImagePropertyGPSTimeStamp as String: ISO8601DateFormatter().string(from: location.timestamp),
            kCGImagePropertyGPSDateStamp as String: ISO8601DateFormatter().string(from: location.timestamp)
        ]
        
        // Get existing metadata and add GPS data
        var metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] ?? [:]
        metadata[kCGImagePropertyGPSDictionary as String] = gpsMetadata
        
        // Add image to destination with metadata
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        
        if CGImageDestinationFinalize(destination) {
            if let newImage = UIImage(data: destinationData as Data) {
                return newImage
            }
        }
        
        return image
    }
    
    // Add GPS metadata to video
    private func addLocationToVideo(at url: URL, location: CLLocation?) {
        guard let location = location else { return }
        
        let asset = AVURLAsset(url: url)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
            return
        }
        
        // Create temporary output URL
        let tempURL = url.deletingLastPathComponent().appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        
        // Create location metadata
        let locationMetadata = AVMutableMetadataItem()
        locationMetadata.identifier = .quickTimeMetadataLocationISO6709
        locationMetadata.dataType = kCMMetadataBaseDataType_UTF8 as String
        
        // ISO 6709 format: ±DD.DDDD±DDD.DDDD/
        let locationString = String(format: "%+09.5f%+010.5f/", location.coordinate.latitude, location.coordinate.longitude)
        locationMetadata.value = locationString as NSString
        
        exportSession.outputURL = tempURL
        exportSession.outputFileType = .mp4
        exportSession.metadata = [locationMetadata]
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                // Replace original file with metadata-added file
                try? FileManager.default.removeItem(at: url)
                try? FileManager.default.moveItem(at: tempURL, to: url)
                print("Location added to video")
            case .failed:
                print("Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                try? FileManager.default.removeItem(at: tempURL)
            default:
                break
            }
        }
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
