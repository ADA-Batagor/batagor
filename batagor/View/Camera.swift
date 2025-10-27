//
//  Camera.swift
//  batagor
//
//  Created by Tude Maha on 22/10/2025.
//

import SwiftUI
import AVFoundation

struct Camera: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var cameraViewModel = CameraViewModel()
    
    
    @State private var capturingPhoto = false
    @State private var isPressed = false
    @State private var isRecording = false
    
    var lineWidth: CGFloat = 4.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.black)
                
                ZStack(alignment: .bottom) {
                    if let image = cameraViewModel.previewImage {
                        image
                            .resizable()
                            .scaledToFit()
                            .onAppear {
                                cameraViewModel.camera.isPreviewPaused = false
                            }
                            .onDisappear {
                                cameraViewModel.camera.isPreviewPaused = true
                            }
                            .overlay {
                                if capturingPhoto {
                                    Color(.black)
                                }
                            }
                    }
                    
                    if cameraViewModel.camera.isRunning {
                        HStack {
                            NavigationLink {
                                GalleryView()
                            } label: {
                                Image(systemName: "photo.on.rectangle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .foregroundStyle(Color(.white))
                            }
                            .padding(15)
                            .background(.black.opacity(0.5))
                            .clipShape(Circle())
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(lineWidth: lineWidth)
                                    .fill(.white)
                                Circle()
                                    .inset(by: lineWidth * 1.2)
                                    .fill(isRecording ? .red : .white)
                                    .scaleEffect(isPressed ? 0.85 : 1.0)
                                    .frame(height: isRecording ? 120 : 75)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            isPressed = true
                                        }
                                        
                                        vibrateLight()
                                        cameraViewModel.camera.takePhoto()
                                        
                                        withAnimation(.easeInOut(duration: 0.05)) {
                                            capturingPhoto = true
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                            withAnimation(.easeInOut(duration: 0.05)) {
                                                capturingPhoto = false
                                                isPressed = false
                                            }
                                        })
                                    }
                                    .onLongPressGesture {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            isPressed = true
                                            isRecording = true
                                        }
                                        
                                        vibrateLight()
                                        cameraViewModel.camera.startRecordingVideo()
                                        
                                        print("Recording started")
                                    } onPressingChanged: { _ in
                                        cameraViewModel.camera.stopRecordingVideo()
                                        if isRecording {
                                            vibrateLight()
                                        }
                                        
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            isPressed = false
                                            isRecording = false
                                        }
                                    }
                                
                                
                            }
                            .frame(height: 75)
                            
                            Spacer()
                            
                            Button {
                                Task{
                                    cameraViewModel.camera.switchCaptureDevices()
                                }
                            } label: {
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .foregroundStyle(Color(.white))
                            }
                            .padding(15)
                            .background(.black.opacity(0.5))
                            .clipShape(Circle())
                            .onChange(of: cameraViewModel.photoTaken?.imageData) { _, photo in
                                if let _ = photo {
                                    cameraViewModel.handleSavePhoto(context: modelContext)
                                }
                            }
                            //                            .onChange(of: cameraViewModel.movieFileURL) { _, url in
                            //                                if let url = url {
                            //                                    let asset = AVAsset(url: url)
                            //                                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                            //                                    imageGenerator.appliesPreferredTrackTransform = true // correct rotation
                            //
                            //
                            //                                    // Capture at 1 second mark
                            //                                    let time = CMTime(seconds: 1, preferredTimescale: 600)
                            //                                    do {
                            //                                        let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                            //                                        if let thumbnail = StorageManager.shared.savePhoto(UIImage(cgImage: cgImage)) {
                            //                                            let photo = Storage(createdAt: Date(), expiredAt: 60, filePath: thumbnail)
                            //                                            modelContext.insert(photo)
                            //                                            try? modelContext.save()
                            //                                        }
                            //                                    } catch {
                            //                                        print("gagal")
                            //                                    }
                            //                                }
                            //                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                    }
                }
                
            }
            .ignoresSafeArea(.all)
        }
        .task {
            await cameraViewModel.camera.start()
        }
        .environmentObject(cameraViewModel)
    }
    
    struct PhotoButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }
}

#Preview {
    Camera()
}
