//
//  Camera.swift
//  batagor
//
//  Created by Tude Maha on 22/10/2025.
//

import SwiftUI
import AVFoundation
import SwiftData

struct Camera: View {
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var timer: SharedTimerManager
    
    @StateObject private var cameraViewModel = CameraViewModel()
    
    @Query var storages: [Storage]
    
    @State private var capturingPhoto = false
    @State private var isPressed = false
    @State private var isRecording = false
    
    var lineWidth: CGFloat = 4.0
    
    init() {
        _storages = Query(FetchDescriptor<Storage>())
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .center) {
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
                                    .fill(storages.count >= 24 ? .gray : .white)
                                Circle()
                                    .inset(by: lineWidth * 1.2)
                                    .fill(storages.count >= 24 ? .gray : isRecording ? .red : .white)
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
                            .disabled(storages.count >= 24 ? true : false)
                            
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
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                    }
                }
                
                if storages.count >= 24 {
                    VStack {
                        Image(systemName: "figure.fishing")
                            .resizable()
                            .scaledToFit()
                            .containerRelativeFrame(.vertical) { height, _ in
                                height * 0.1
                            }
                        Text("You take too much.")
                            .font(.title.bold())
                        Text("Go fishing, cuy!")
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 20))
                    .padding(.bottom, 50)
                }
            }
            .ignoresSafeArea(.all)
        }
        .task {
            await cameraViewModel.camera.start()
        }
        .onChange(of: cameraViewModel.photoTaken?.imageData) {
            cameraViewModel.handleSavePhoto(context: modelContext)
        }
        .onChange(of: cameraViewModel.movieFileURL) {
            cameraViewModel.handleSaveMovie(context: modelContext)
        }
        .onChange(of: timer.currentTime) {
            Task { @MainActor in
                await DeletionService.shared.performCleanup(modelContext: modelContext)
            }
        }
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
