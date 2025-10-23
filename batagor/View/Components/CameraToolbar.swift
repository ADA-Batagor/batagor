//
//  CameraToolbar.swift
//  batagor
//
//  Created by Tude Maha on 22/10/2025.
//

import SwiftUI

struct CameraToolbar: View {
    private let lineWidth = CGFloat(4.0)
    
    var body: some View {
        HStack {
            Image(systemName: "photo.on.rectangle")
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .fill(.white)
                Button {
                    
                } label: {
                    Circle()
                        .inset(by: lineWidth * 1.2)
                        .fill(.white)
                }
            }
            
            Spacer()
            
            Button {
                Task {
                    
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

#Preview {
    CameraToolbar()
}
