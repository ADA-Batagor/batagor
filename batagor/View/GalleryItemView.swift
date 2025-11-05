//
//  GalleryItemView.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/10/25.
//

import SwiftUI

struct GalleryItemView: View {
    let storage: Storage
    @State private var selectedStorage: Storage?
    
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            if let image = StorageManager.shared.loadThumbnail(fileURL: storage.thumbnailPath) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .onTapGesture {
                        selectedStorage = storage
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    )
            }
            
            RemainingTime(storage: storage, variant: .small)
        }
        .fullScreenCover(item: $selectedStorage) { _ in
            DetailView(selectedStorage: $selectedStorage)
        }
    }
}

#Preview {
    GalleryItemView(storage: Storage(
        createdAt: Date(),
        expiredAt: 300,
        mainPath: URL(string: "https://images.unsplash.com/photo-1761405378282-e819a65cb493?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1364")!,
        thumbnailPath: URL(string: "https://images.unsplash.com/photo-1761405378282-e819a65cb493?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1364")!
    ))
}
