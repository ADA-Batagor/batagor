//
//  CameraToolbar.swift
//  batagor
//
//  Created by Tude Maha on 22/10/2025.
//

import SwiftUI
import SwiftData

struct CameraToolbar: View {
    @ObservedObject var cameraViewModel: CameraViewModel
    
    var storageCount: Int
    @Binding var currentDuration: Double
    @Binding var isRecording: Bool
    @Binding var capturingPhoto: Bool
    
    @State private var isPressed = false
    
    var movieDurationLimit = 5.0
    var lineWidth: CGFloat = 4.0
    
    var body: some View {
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
                if isRecording {
                    Circle()
                        .trim(from: 0, to: (currentDuration / movieDurationLimit))
                        .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .fill(storageCount >= 24 ? .gray : .white)
                        .rotationEffect(.degrees(-90))
                } else {
                    Circle()
                        .stroke(lineWidth: lineWidth)
                        .fill(storageCount >= 24 ? .gray : .white)
                }
                
                Circle()
                    .inset(by: lineWidth * 1.2)
                    .fill(storageCount >= 24 ? .gray : isRecording ? .red : .white)
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
                    } onPressingChanged: { _ in
                        cameraViewModel.camera.stopRecordingVideo()
                        if isRecording {
                            vibrateLight()
                        }
                        
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isPressed = false
                            isRecording = false
                            currentDuration = 0
                        }
                    }
                    .onChange(of: currentDuration) { _, newValue in
                        if newValue >= movieDurationLimit {
                            cameraViewModel.camera.stopRecordingVideo()
                            
                            if isRecording {
                                vibrateLight()
                            }
                            
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isPressed = false
                                isRecording = false
                                currentDuration = 0
                            }
                        }
                    }
                
            }
            .frame(height: 75)
            .disabled(storageCount >= 24 ? true : false)
            
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
    }
}

//#Preview {
//    CameraToolbar()
//}
