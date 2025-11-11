//
//  DetailBottomToolbar.swift
//  batagor
//
//  Created by Tude Maha on 11/11/2025.
//

import SwiftUI

struct DetailBottomToolbar: View {
    var selectedStorage: Storage
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack {
            if let thumbnailImage = StorageManager.shared.loadUIImage(fileURL: selectedStorage.thumbnailPath)
            {
                if selectedStorage.mainPath.pathExtension == "mp4" {
                    ShareLink(item: selectedStorage.mainPath, preview: SharePreview("Share Your Temp Video", image: Image(uiImage: thumbnailImage))
                    ) {
                        CircleButton(icon: "square.and.arrow.up")
                    }
                } else {
                    if let mainImage = StorageManager.shared.loadUIImage(fileURL: selectedStorage.mainPath) {
                        ShareLink(
                            item: Image(uiImage: mainImage),
                            preview: SharePreview("Share Your Temp Photo", image: Image(uiImage: thumbnailImage))
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
                    withAnimation {
                        DeletionService.shared.manualDelete(modelContext: modelContext, storage: selectedStorage)
                    }
                }
            } message: {
                let ext = selectedStorage.mainPath.pathExtension == "mp4" ? "video" : "photo"
                Text("This \(ext) will be deleted permanently.")
                
            }
        }
    }
}
