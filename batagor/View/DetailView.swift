//
//  DetailView.swift
//  batagor
//
//  Created by Tude Maha on 30/10/2025.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selectedStorage: Storage?
    
    @State private var showToolbar: Bool = true
    @State private var showDeleteConfirmation: Bool = false
    
    //    gesture state
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var dismissOffset: CGSize = .zero
    @State private var dismissScale: CGFloat = 1.0
    @State private var isZoomed = false
    
    var body: some View {
        ZStack(alignment: .center) {
            Color(showToolbar ? .white : .black)
            
            if let storage = selectedStorage, let uiImage = UIImage(contentsOfFile: storage.mainPath.path()) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale * dismissScale)
                    .offset(CGSize(width: offset.width + dismissOffset.width, height: offset.height + dismissOffset.height))
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { value in
                                    if scale < 1 {
                                        withAnimation {
                                            scale = 1
                                            lastScale = 1
                                            offset = .zero
                                        }
                                    } else if scale > 3 {
                                        withAnimation {
                                            scale = 3
                                            lastScale = 3
                                        }
                                    }
                                    
                                    lastScale = scale
                                    isZoomed = scale > 1
                                },
                            
                            DragGesture()
                                .onChanged { value in
                                    if !isZoomed {
                                        dismissOffset = value.translation
                                        let progress = min(abs(value.translation.height) / 200, 1.0)
                                        dismissScale = 1.0 - (progress * 0.5)
                                    } else {
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded { value in
                                    lastOffset = offset
                                    
                                    if !isZoomed {
                                        if abs(value.translation.height) > 150 {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                dismissOffset = CGSize(width: 0, height: value.translation.height > 0 ? 1000 : -1000)
                                                dismissScale = 0
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                selectedStorage = nil
                                            }
                                        } else {
                                            withAnimation(.spring()) {
                                                dismissOffset = .zero
                                                dismissScale = 1.0
                                            }
                                        }
                                    }
                                }
                        )
                    )
            }
            
            VStack {
                if showToolbar {
                    HStack {
                        Button {
                            selectedStorage = nil
                        } label: {
                            CircleButton(icon: "chevron.backward")
                        }
                        
                        Spacer()
                        
                        if let storage = selectedStorage {
                            RemainingTime(storage: storage, variant: .large)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                if showToolbar {
                    HStack {
                        if let storage = selectedStorage,
                           let mainData = try? Data(contentsOf: storage.mainPath),
                           let thumbnailData = try? Data(contentsOf: storage.thumbnailPath),
                           let thumbnailUIImage = UIImage(data: thumbnailData) {
                            if storage.mainPath.pathExtension == "mp4" {
                                
                            } else {
                                if let mainUIImage = UIImage(data: mainData) {
                                    ShareLink(
                                        item: Image(uiImage: mainUIImage),
                                        preview: SharePreview("Share Your Temp Photo", image: Image(uiImage: thumbnailUIImage))
                                    ) {
                                        CircleButton(icon: "square.and.arrow.up")
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            CircleButton(icon: "trash")
                        }
                        .confirmationDialog("Delete Photo", isPresented: $showDeleteConfirmation, titleVisibility: .hidden) {
                            Button("Delete", role: .destructive) {
                                if let storage = selectedStorage {
                                    withAnimation {
                                        DeletionService.shared.manualDelete(modelContext: modelContext, storage: storage)
                                    }
                                }
                            }
                        } message: {
                            if let storage = selectedStorage,
                               let ext = storage.mainPath.pathExtension == "mp4" ? "video" : "photo" {
                                Text("This \(ext) will be deleted permanently.")
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 30)
            .padding(.top, 20)
            .padding(.horizontal, 25)
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                showToolbar.toggle()
            }
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    DetailView(selectedStorage: .constant(
        Storage(
            mainPath: URL(string: "https://example.com")!,
            thumbnailPath: URL(string: "https://example.com")!
        )
    ))
}
