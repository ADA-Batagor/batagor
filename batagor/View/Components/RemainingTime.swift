//
//  RemainingTime.swift
//  batagor
//
//  Created by Tude Maha on 03/11/2025.
//

import SwiftUI

struct RemainingTime: View {
    @EnvironmentObject var timer: SharedTimerManager

    @State private var timeRemaining: TimeInterval = 0
    
    let storage: Storage
    var variant: variants = .small
    
    var body: some View {
        if variant == .small {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.spaceGroteskRegular(size: 13))
                    .foregroundStyle(.batagorLight)
                Text(TimeFormatter.formatTimeRemaining(timeRemaining))
                    .font(.spaceGroteskRegular(size: 13))
                    .foregroundStyle(.batagorLight)
                    .monospacedDigit()
            }
            .padding(.horizontal, 10)
            .onAppear{
                updateTimeRemaining()
            }
            .onChange(of: timer.currentTime) {
                updateTimeRemaining()
            }
        } else {
            HStack(spacing: 4) {
                Text((TimeFormatter.formatTimeRemaining(timeRemaining)))
                    .font(.spaceGroteskRegular(size: 24))
                    .foregroundStyle(.batagorDark)
                    .monospacedDigit()
            }
            .padding(.horizontal, 10)
            .background(.batagorPrimary)
            .cornerRadius(12)
            .onAppear{
                updateTimeRemaining()
            }
            .onChange(of: timer.currentTime) {
                updateTimeRemaining()
            }
        }
        
        
    }
    
    private func updateTimeRemaining() {
        timeRemaining = storage.timeRemaining
    }
    
    enum variants {
        case small, large
    }
}

#Preview {
    RemainingTime(
        storage: Storage(
            mainPath: URL(string: "https://example.com")!,
            thumbnailPath: URL(string: "https://example.com")!
        )
    )
}
