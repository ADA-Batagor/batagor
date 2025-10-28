//
//  GalleryItemView.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 21/10/25.
//

import SwiftUI

struct GalleryItemView: View {
    @EnvironmentObject var timer: SharedTimerManager
    
    let storage: Storage
    @State private var timeRemaining: TimeInterval = 0
    
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            if let image = StorageManager.shared.loadThumbnail(fileURL: storage.thumbnailPath) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
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
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.caption2)
                Text(formatTimeRemaining(timeRemaining))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .padding(8)
        }
        .onAppear{
            updateTimeRemaining()
        }
        .onChange(of: timer.currentTime) {
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        timeRemaining = storage.timeRemaining
    }
    
    private func formatTimeRemaining(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
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
