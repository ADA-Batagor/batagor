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
            
            ZStack {
                if let storage = storage, let uiImage = UIImage(contentsOfFile: storage.mainPath.path()) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }
                
                VStack {
                    HStack {
                        Button {
                            storage = nil
                        } label: {
                            Text("Back")
                        }
                        
                        Spacer()
                    }

                    Spacer()
                        
                    HStack {
                        Button {
                            
                        } label: {
                            Text("Sharee")
                        }
                        
                        Spacer()
                        
                        Text("Expired")
                    }
                }
                .padding(.vertical, 50)
                .padding(.top, 20)
                .padding(.horizontal, 30)
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
