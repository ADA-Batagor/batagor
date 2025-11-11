//
//  GalleryItemView.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/10/25.
//

import SwiftUI
import CoreLocation

struct GalleryItemView: View {
    let storage: Storage
    
    @Binding var isSelecting: Bool
    @Binding var isSelected: Bool
    @Binding var isSwiped: Bool
    
    @State private var selectedStorage: Storage?
    @State private var showCover: Bool = false
    
    @StateObject private var geocodeManager = ReverseGeocodeManager()
    
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            if let image = StorageManager.shared.loadUIImage(fileURL: storage.thumbnailPath) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .onTapGesture {
                        if isSelecting {
                            isSelected.toggle()
                        } else if !isSwiped {
                            selectedStorage = storage
                            showCover = true
                        }
                    }
            }
        }
        .overlay(alignment: .bottom) {
            if !isSelecting {
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .black.opacity(0.6), location: 0.0),
                            Gradient.Stop(color: .black.opacity(0.3), location: 0.5),
                            Gradient.Stop(color: .clear, location: 1.0)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 80)
                    
                    ProgressView(value: Double(storage.timeRemaining), total: 86400)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.blueBase))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .frame(height: 6)
                    VStack {
                        HStack {
                            RemainingTime(storage: storage, variant: .small)
                            
                            Spacer()
                            
                            HStack {
                                if let locationName = storage.locationName {
                                    Text(locationName)
                                        .font(.spaceGroteskRegular(size: 13))
                                        .foregroundColor(Color.lightBase)
                                } else {
                                    Text("No location")
                                        .font(.spaceGroteskRegular(size: 13))
                                        .foregroundColor(Color.lightBase)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding(.bottom, 12)
                    }
                }
                .clipShape(
                    UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: 0,
                            bottomLeading: 12,
                            bottomTrailing: 12,
                            topTrailing: 0
                        )
                    )
                )
            }
            
             if isSelecting && isSelected {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.blueBase, lineWidth: 3)
                    
                    Circle()
                        .fill(Color.blueBase)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.darkBase)
                        )
                        .padding(8)
                }
            }
            
        }
        .fullScreenCover(isPresented: $showCover) {
            DetailView(selectedStorage: $selectedStorage, showCover: $showCover)
        }
    }
}

#Preview {
    GalleryItemView(storage: Storage(
        createdAt: Date(),
        expiredAt: 20000,
        mainPath: URL(string: "https://images.unsplash.com/photo-1761405378282-e819a65cb493?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1364")!,
        thumbnailPath: URL(string: "https://images.unsplash.com/photo-1761405378282-e819a65cb493?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1364")!
        
    ), isSelecting: .constant(false), isSelected: .constant(true), isSwiped: .constant(false))
    .environmentObject(SharedTimerManager.shared)
}
