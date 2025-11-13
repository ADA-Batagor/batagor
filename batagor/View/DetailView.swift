//
//  DetailView.swift
//  batagor
//
//  Created by Tude Maha on 30/10/2025.
//

import SwiftUI
import SwiftData
import AVKit
import UniformTypeIdentifiers

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selectedStorage: Storage?
    @Binding var showCover: Bool
    
    @State private var showToolbar: Bool = true
    @State private var showDeleteConfirmation: Bool = false
    @State private var selectedThumbnail: Storage?
    
    //    gesture state
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var dismissOffset: CGSize = .zero
    @State private var dismissScale: CGFloat = 1.0
    @State private var isZoomed = false
    
    //    video player
    @State private var player: AVPlayer?
    
    @Query(sort: \Storage.createdAt, order: .reverse)
    private var allStorages: [Storage]
    private var storages: [Storage] {
        allStorages.filter { $0.expiredAt > Date() }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color(showToolbar ? .white : .black)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(storages, id: \.self) { storage in
                            ZStack {
                                if storage.isVideo {
                                    if selectedThumbnail == storage {
                                        VideoPlayer(player: player)
                                            .scaleEffect(scale * dismissScale)
                                            .offset(CGSize(width: offset.width + dismissOffset.width, height: offset.height + dismissOffset.height))
                                            .simultaneousGesture(simultaneousGesture())
                                            .task {
                                                player = AVPlayer(url: storage.mainPath as URL)
                                                player?.play()
                                            }
                                            .onDisappear {
                                                player?.pause()
                                            }
                                    }
                                } else {
                                    if let uiImage = StorageManager.shared.loadUIImage(fileURL: storage.mainPath) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .scaleEffect(scale * dismissScale)
                                            .offset(CGSize(width: offset.width + dismissOffset.width, height: offset.height + dismissOffset.height))
                                            .simultaneousGesture(simultaneousGesture())
                                    }
                                }
                            }
                            .id(storage.id)
                            .frame(width: UIScreen.main.bounds.width)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $selectedThumbnail)
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.vertical, 80)
                .onAppear {
                    proxy.scrollTo(selectedStorage?.id)
                    selectedThumbnail = selectedStorage
                }
                .onChange(of: selectedStorage) { _, newValue in
                    proxy.scrollTo(newValue?.id)
                    selectedThumbnail = selectedStorage
                }
            }
            
            if showToolbar {
                VStack {
                    HStack {
                        Button {
                            showCover = false
                        } label: {
                            CircleButton(icon: "chevron.backward")
                        }
                        
                        Spacer()
                        
                        if let storage = selectedThumbnail {
                            RemainingTime(storage: storage, variant: .large)
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    if !isZoomed {
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .bottom, spacing: 3) {
                                    ForEach(storages, id: \.self) { storage in
                                        if let thumbnail = StorageManager.shared.loadUIImage(fileURL: storage.thumbnailPath) {
                                            Image(uiImage: thumbnail)
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(.rect(cornerRadius: 2))
                                                .containerRelativeFrame(.horizontal) { width, _ in
                                                    storage.id == selectedThumbnail?.id ? width * 0.065 : width * 0.05
                                                }
                                                .padding(.horizontal, storage.id == selectedThumbnail?.id ? 4 : 0)
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.15)) {
                                                        vibrateLight()
                                                        selectedStorage = storage
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    if let selectedThumbnail = selectedThumbnail {
                        DetailBottomToolbar(selectedStorage: selectedThumbnail)
                    }
                    
                }
                .padding(.vertical, 30)
                .padding(.top, 20)
                .padding(.horizontal, 25)
            }
            
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                showToolbar.toggle()
            }
        }
        .ignoresSafeArea(.all)
    }
    
    private func simultaneousGesture() -> some Gesture {
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
                        if abs(value.translation.height) > abs(value.translation.width) {
                            dismissOffset.height = value.translation.height
                            let progress = min(abs(value.translation.height) / 200, 1.0)
                            dismissScale = 1.0 - (progress * 0.5)
                        }
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
                                showCover = false
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
    }
}

#Preview {
    DetailView(selectedStorage: .constant(
        Storage(
            mainPath: URL(string: "https://example.com")!,
            thumbnailPath: URL(string: "https://example.com")!
        )
    ), showCover: .constant(true))
}
