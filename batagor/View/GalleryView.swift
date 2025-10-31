//
//  GalleryView.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/10/25.
//

import SwiftUI
import SwiftData

struct GalleryView: View {
    @EnvironmentObject var timer: SharedTimerManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    @Query(sort: \Storage.createdAt, order: .reverse)
        private var allPhotos: [Storage]

        private var photos: [Storage] {
            allPhotos.filter { $0.expiredAt > Date() }
        }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if photos.isEmpty {
                    emptyStateView
                } else {
                    galleryGridView
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            navigationManager.navigate(to: .camera)
                        } label: {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.brown)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Gallery")
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                Task { @MainActor in
                    await
                    DeletionService.shared.performCleanup(modelContext: modelContext)
                }
            }
        }
        .onChange(of: timer.currentTime) {
            Task { @MainActor in
                await DeletionService.shared.performCleanup(modelContext: modelContext)
            }
        }
    }
    
    private var galleryGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(photos) { photo in
                    GalleryItemView(storage: photo)
                }
            }
            .padding()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundStyle(.gray)
            
            Text("No Photos")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Captured photos will appear here")
                .font(.callout)
                .foregroundStyle(.secondary)
        }.padding()
    }
}



#Preview {
    GalleryView()
        .environmentObject(SharedTimerManager.shared)
}
