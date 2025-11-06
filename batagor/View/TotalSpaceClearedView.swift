//
//  TotalSpaceClearedView.swift
//  batagor
//
//  Created by Fuad Fajri on 06/11/25.
//

import SwiftUI

struct TotalSpaceClearedView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var totalSpaceCleared: String = "0 MB"
    
    // Formatter for bytes
    private let formatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.allowedUnits = [.useAll]
        f.countStyle = .file
        return f
    }()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundStyle(.brown)
                    .padding(.top, 40)
                
                Text("Total Space Cleared")
                    .font(.title2.weight(.semibold))
                
                Text(totalSpaceCleared)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.brown)
                
                Text("This is the total amount of storage 'batagor' has automatically cleaned up for you over time.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Space Saved")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadTotal()
            }
        }
    }
    
    private func loadTotal() {
        let totalInBytes = UserDefaults.standard.integer(forKey: DeletionService.totalSpaceClearedKey)
        self.totalSpaceCleared = formatter.string(fromByteCount: Int64(totalInBytes))
    }
}

#Preview {
    TotalSpaceClearedView()
}
