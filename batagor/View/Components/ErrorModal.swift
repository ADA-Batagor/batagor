//
//  ErrorModal.swift
//  batagor
//
//  Created by Tude Maha on 30/10/2025.
//

import SwiftUI

struct ErrorModal: View {
    var body: some View {
        VStack {
            Image(systemName: "figure.fishing")
                .resizable()
                .scaledToFit()
                .containerRelativeFrame(.vertical) { height, _ in
                    height * 0.1
                }
            Text("You take too much.")
                .font(.title.bold())
            Text("Go fishing, cuy!")
        }
        .padding()
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 20))
        .padding(.bottom, 50)
    }
}

#Preview {
    ErrorModal()
}
