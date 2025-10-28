//
//  CameraManager.swift
//  batagor
//
//  Created by Tude Maha on 22/10/2025.
//

import UIKit
import AVFoundation

class CameraManager: NSObject {
    //    create a new capture session from AVFoundation
    private let captureSession = AVCaptureSession()
    
    //    prepare input and output configuration
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    //    prepare preview
    private var videoOutput: AVCaptureVideoDataOutput?
    private var sessionQueue: DispatchQueue!
    
    //    list capture devices
    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [
            .builtInTrueDepthCamera,
            .builtInDualCamera,
//            .builtInDualWideCamera,
            .builtInWideAngleCamera,
        ], mediaType: .video, position: .unspecified).devices
    }
    
    private var frontCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices.filter { $0.position == .front }
    }
    
    private var backCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices.filter { $0.position == .back }
    }
    
    private var captureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
        if let backDevice = backCaptureDevices.first {
            devices += [backDevice]
        }
        if let frontDevice = frontCaptureDevices.first {
            devices += [frontDevice]
        }
        return devices
    }
    
    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices
            .filter( {$0.isConnected} )
            .filter( {!$0.isSuspended})
    }
    
    private var selectedCaptureDevice: AVCaptureDevice? {
        didSet {
            guard let selectedCaptureDevice = selectedCaptureDevice else { return }
            sessionQueue.async {
                self.updateSessionForCaptureDevice(selectedCaptureDevice)
            }
        }
    }
    
    //    capture session status
    var isRunning: Bool {
        captureSession.isRunning
    }
    
    var isUsingFrontCaptureDevice: Bool {
        guard let selectedCaptureDevice = selectedCaptureDevice else { return false }
        return frontCaptureDevices.contains(selectedCaptureDevice)
    }
    
    var isUsingBackCaptureDevice: Bool {
        guard let selectedCaptureDevice = selectedCaptureDevice else { return false }
        return backCaptureDevices.contains(selectedCaptureDevice)
    }
    
    
    // capture photo
    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    lazy var photoStream: AsyncStream<AVCapturePhoto> = {
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }
    }()
    
    //    record movie
    private var addToMovieFileStream: ((URL) -> Void)?
    lazy var movieFileStream: AsyncStream<URL> = {
        AsyncStream { continuation in
            addToMovieFileStream = { fileURL in
                continuation.yield(fileURL)
            }
        }
    }()
    
    //    preview output
    var isPreviewPaused = false
    private var addToPreviewStream: ((CIImage) -> Void)?
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if !self.isPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()
    
    // override init
    override init() {
        super.init()
        
        captureSession.sessionPreset = .low
        sessionQueue = DispatchQueue.init(label: "com.tudemaha.batagor")
        selectedCaptureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
    }
    
    //    start capture session
    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else { return }
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in
                    self.captureSession.startRunning()
                }
            }
            return
        }
        
        sessionQueue.async { [self] in
            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }
    
    //    stop capture session
    func stop() {
        guard isCaptureSessionConfigured else { return }
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    //    switch cameras
    func switchCaptureDevices() {
        if let selectedCaptureDevice = selectedCaptureDevice, let index = availableCaptureDevices.firstIndex(of: selectedCaptureDevice) {
            let nextIndex = (index + 1) % availableCaptureDevices.count
            self.selectedCaptureDevice = availableCaptureDevices[nextIndex]
        } else {
            self.selectedCaptureDevice = AVCaptureDevice.default(for: .video)
        }
    }
    
    //    start record video
    func startRecordingVideo() {
        guard let movieFileOutput = self.movieFileOutput else {
            print("cannot find movie file output")
            return
        }
        
        guard let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("cannot access local file domain")
            return
        }
        
        let filename = UUID().uuidString
        let filepath = directoryPath
            .appendingPathComponent("Movies", isDirectory: true)
            .appendingPathComponent(filename)
            .appendingPathExtension("mp4")
        
        movieFileOutput.startRecording(to: filepath, recordingDelegate: self)
    }
    
    //    stop record video
    func stopRecordingVideo() {
        guard let movieFileOutput = self.movieFileOutput else {
            print("cannot find movie file output")
            return
        }
        
        movieFileOutput.stopRecording()
    }
    
    //    take photo
    func takePhoto() {
        guard let photoOutput = self.photoOutput else {
            print("cannot find photo output")
            return
        }
        
        sessionQueue.async {
            var photoSettings = AVCapturePhotoSettings()
            
            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off
            
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            
            photoSettings.photoQualityPrioritization = .balanced
            
            if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
                photoOutputVideoConnection.videoRotationAngle = RotationAngle.portrait.rawValue
            }
            
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    
    //    capture session configuration
    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        var success = false
        self.captureSession.beginConfiguration()
        
        defer {
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }
        
        guard
            let selectedCaptureDevice = selectedCaptureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: selectedCaptureDevice)
        else {
            print("failed obtain video input")
            return
        }
        
        let movieFileOutput = AVCaptureMovieFileOutput()
        
        let photoOutput = AVCapturePhotoOutput()
//        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.tudemaha.batagor.output"))
        
        guard captureSession.canAddInput(deviceInput) else {
            print("can't add device input to capture session")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            print("can't add photo output to capture session")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            print("can't add video output to capture session")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        captureSession.addOutput(movieFileOutput)
        
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        self.movieFileOutput = movieFileOutput
        
        photoOutput.maxPhotoQualityPrioritization = .balanced
        
        updateVideoOutputConnection()
        
        isCaptureSessionConfigured = true
        success = true
    }
    
    
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        if let deviceInput = deviceInputFor(device: captureDevice) {            
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
        
        updateVideoOutputConnection()
    }
    
    //    video output configuration
    private func updateVideoOutputConnection() {
        if let videoOutput = videoOutput, let videoOutputConnection = videoOutput.connection(with: .video) {
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection.isVideoMirrored = isUsingFrontCaptureDevice
            }
        }
    }
    
    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let error {
            print("error get capture devide: \(error.localizedDescription)")
            return nil
        }
    }
    
    //    check autorization for camera access
    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("camera access: authorized")
            return true
        case .notDetermined:
            print("camera access: not determined")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            print("camera access: denied")
            return false
        case .restricted:
            print("camera access: restricted")
            return false
        default:
            return false
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let error = error {
            print("capture photo error: \(error.localizedDescription)")
        }
        
        addToPhotoStream?(photo)
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        if let error = error {
            print("file output error: \(error.localizedDescription)")
        }
        
        addToMovieFileStream?(outputFileURL)
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        connection.videoRotationAngle = RotationAngle.portrait.rawValue
        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
}

private enum RotationAngle: CGFloat {
    case portrait = 90
    case portraitUpsideDown = 270
    case landscapeRight = 180
    case landscapeLeft = 0
}
