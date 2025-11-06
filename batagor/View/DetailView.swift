//
//  DetailView.swift
//  batagor
//
//  Created by Tude Maha on 30/10/2025.
//

import SwiftUI

struct DetailView: View {
    @Binding var storage: Storage?
    
    @State private var showToolbar: Bool = true
    
    // --- ADD THIS FORMATTER ---
    private var formattedFileSize: String {
        guard let storage = storage else { return "..." }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: storage.fileSizeInBytes)
    }
    
    var body: some View {
        ZStack {
            Color(showToolbar ? .white : .black)
                .ignoresSafeArea(.all) // Move this modifier
            
            ZStack {
                if let storage = storage, let uiImage = UIImage(contentsOfFile: storage.mainPath.path()) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
                
                // This VStack is for the toolbars
                VStack {
                    // --- TOP TOOLBAR ---
                    HStack {
                        Button {
                            storage = nil
                        } label: {
                            Label("Back", systemImage: "chevron.backward") // Improved the button
                        }
                        .foregroundStyle(.primary)
                        .padding(12)
                        .background(.thinMaterial, in: Capsule())
                        
                        Spacer()
                    }
                    
                    Spacer()
                        
                    // --- BOTTOM TOOLBAR ---
                    HStack {
                        Button {
                            // --- ADD SHARE LOGIC ---
                            shareMedia()
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .foregroundStyle(.primary)
                        .padding(12)
                        .background(.thinMaterial, in: Capsule())

                        
                        Spacer()
                        
                        // --- MODIFIED THIS TEXT ---
                        Text(formattedFileSize) // Display the formatted file size
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .padding(12)
                            .background(.thinMaterial, in: Capsule())
                    }
                }
                .padding(.vertical, 50)
                .padding(.top, 20)
                .padding(.horizontal, 30)
                .opacity(showToolbar ? 1 : 0) // Hide toolbars when tapped
            }
            
        }
        .ignoresSafeArea(.all) // Keep this one for the ZStack
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showToolbar.toggle()
            }
        }
    }
    
    // --- ADD THIS HELPER FUNCTION ---
    private func shareMedia() {
        guard let storage = storage else { return }
        let url = storage.mainPath
        
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // Find the active window scene to present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityController, animated: true, completion: nil)
        }
    }
}

//#Preview {
//    DetailView()
//}
