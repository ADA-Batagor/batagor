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
    @State private var currentDuration = 0.0
    @State private var isRecording = false
    @State private var storageCount = 0
    
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
                            .overlay {
                                if capturingPhoto {
                                    Color(.black)
                                }
                            }
                    }
                    
                    if cameraViewModel.camera.isRunning && !cameraViewModel.camera.isPreviewPaused {
                        CameraToolbar(
                            cameraViewModel: cameraViewModel,
                            storageCount: storages.count,
                            latestStorage: storages.last,
                            currentDuration: $currentDuration,
                            isRecording: $isRecording,
                            capturingPhoto: $capturingPhoto
                        )
                        .containerRelativeFrame(.vertical) { height, _ in
                            height * 0.15
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                    }
                }
                .onAppear {
                    cameraViewModel.camera.isPreviewPaused = false
                }
                .onDisappear {
                    cameraViewModel.camera.isPreviewPaused = true
                }
                
                if storages.count >= 24 {
                    ErrorModal()
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
            if isRecording {
                withAnimation(.easeInOut(duration: 0.15)) {
                    currentDuration += 1
                }
            }
            
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

//#Preview {
//    Camera()
//}
