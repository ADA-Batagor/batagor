//
//  GalleryCount.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 05/11/25.
//

import SwiftUI

struct GalleryCount: View {
    let currentCount: Int
    let totalLimit: Int = 24
    
    var body: some View {
        HStack(spacing: 8) {
            CircularProgress(
                current: currentCount,
                total: totalLimit,
                lineWidth: 2.5,
                size: 18
            )
            
            Text("\(currentCount) / \(totalLimit) Media")
                .font(.spaceGroteskSemiBold(size: 17))
                .foregroundStyle(.batagorDark)
            
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

#Preview {
    GalleryCount(currentCount: 5)
}
