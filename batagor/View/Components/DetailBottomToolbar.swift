//
//  DetailBottomToolbar.swift
//  batagor
//
//  Created by Tude Maha on 11/11/2025.
//

import SwiftUI

struct DetailBottomToolbar: View {
    var selectedStorage: Storage
    
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
        }
    }
}

#Preview {
    DetailBottomToolbar(selectedStorage: Storage(
            mainPath: URL(string: "https://example.com")!,
            thumbnailPath: URL(string: "https://example.com")!
        )
    )
}
