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
    
    var body: some View {
        ZStack {
            Color(showToolbar ? .white : .black)
            
            if let storage = storage, let uiImage = UIImage(contentsOfFile: storage.mainPath.path()) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
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

//#Preview {
//    DetailView()
//}
