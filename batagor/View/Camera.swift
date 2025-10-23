//
//  Camera.swift
//  batagor
//
//  Created by Tude Maha on 22/10/2025.
//

import SwiftUI

struct Camera: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    
    var lineWidth: CGFloat = 4.0
    
    var body: some View {
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
                }
                if cameraViewModel.camera.isRunning {
                    HStack {
                        Button {
                            
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
                            
                            Button {
                                Task {
                                    cameraViewModel.camera.takePhoto()
                                }
                            } label: {
                                Circle()
                                    .inset(by: lineWidth * 1.2)
                                    .fill(.white)
                            }
                            .buttonStyle(PhotoButtonStyle())
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
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
        }
        .ignoresSafeArea(.all)
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
