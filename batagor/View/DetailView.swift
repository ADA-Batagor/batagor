//
//  DetailView.swift
//  batagor
//
//  Created by Tude Maha on 30/10/2025.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var storage: Storage?
    
    @State private var showToolbar: Bool = true
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        ZStack {
            Color(showToolbar ? .white : .black)
            
            ZStack {
                if let storage = storage, let uiImage = UIImage(contentsOfFile: storage.mainPath.path()) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
                
                VStack {
                    if showToolbar {
                        HStack {
                            Button {
                                storage = nil
                            } label: {
                                CircleButton(icon: "chevron.backward")
                            }
                            
                            Spacer()
                            
                            if let storage = storage {
                                RemainingTime(storage: storage, variant: .large)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    if showToolbar {
                        HStack {
                            if let storage = storage,
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
                                    if let storage = storage {
                                        withAnimation {
                                            DeletionService.shared.manualDelete(modelContext: modelContext, storage: storage)
                                        }
                                    }
                                }
                            } message: {
                                if let storage = storage,
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
            
        }
        .ignoresSafeArea(.all)
        .onTapGesture {
            withAnimation(.easeInOut) {
                showToolbar.toggle()
            }
        }
    }
}

#Preview {
    DetailView(storage: .constant(
        Storage(
            mainPath: URL(string: "https://example.com")!,
            thumbnailPath: URL(string: "https://example.com")!
        )
    ))
}
