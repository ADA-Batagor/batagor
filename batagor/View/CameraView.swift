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
    @EnvironmentObject var navigationManager: NavigationManager
    
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
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color.rgb(red: 55, green: 64, blue: 83), location: 0.0),
                        Gradient.Stop(color: Color.darkBase, location: 1.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                
                ZStack(alignment: .bottom) {
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            Spacer()
                            if let image = cameraViewModel.previewImage {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .overlay {
                                        if capturingPhoto {
                                            Color(.black)
                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.horizontal, 22)
                                    .padding(.top, 12)
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
                        .safeAreaPadding(.top)
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        navigationManager.navigate(to: .gallery)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.spaceGroteskSemiBold(size: 17))
                            .foregroundStyle(Color.lightBase)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    GalleryCount(currentCount: storages.count, foregroundColor: Color.lightBase, countOnly: true)
                }
            }
            .ignoresSafeArea(.all)
        }
        .task {
            await cameraViewModel.camera.start()
        }
        .onDisappear {
            cameraViewModel.camera.stop()
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

#Preview {
    Camera()
        .environmentObject(SharedTimerManager.shared)
}
