//
//  SwiftUIView.swift
//  batagor
//
//  Created by Tude Maha on 12/11/2025.
//

import SwiftUI

struct CircularScrollView: View {
    var storages: [Storage]
    @Binding var selectedStorage: Storage?
    @Binding var selectedThumbnail: Storage?
    var geo: GeometryProxy
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(storages, id: \.self) { storage in
                            if let thumbnail = StorageManager.shared.loadUIImage(fileURL: storage.thumbnailPath) {
                                ZStack {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFill()
                                }
                                .id(storage.id)
                                .frame(width: 40, height: 70)
                                .clipShape(.rect(cornerRadius: 5))
                                .offset(y: -(1.8 / 2) * UIScreen.main.bounds.width)
                                .visualEffect { content, geometryProxy in
                                    content
                                        .rotationEffect(
                                            .init(degrees: thumbnailRotation(geometryProxy)),
                                            anchor: .center
                                        )
                                        .offset(x: -geometryProxy.frame(in: .scrollView(axis: .horizontal)).minX)
                                }
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        vibrateLight()
                                        selectedStorage = storage
                                    }
                                }
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .safeAreaPadding(.horizontal, (geo.size.width * 0.5 - 20))
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .offset(y: geo.size.height * 0.83)
                //                        .scrollPosition(id: $selectedStorage)
                .onAppear {
                    withAnimation {
                        proxy.scrollTo(selectedStorage?.id)
                    }
                }
                .onChange(of: selectedThumbnail) { _, newValue in
                    if let new = newValue {
                        withAnimation {
                            proxy.scrollTo(new.id)
                        }
                    }
                }
            }
        }
    }
    
    nonisolated func thumbnailRotation(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        let width = proxy.size.width
        
        let progress = minX / width
        let angleForEachThumbnail: CGFloat = 6
        let cappedProgress = progress < 0 ? min(max(progress, -12), 0) : max(min(progress, 12), 0)
        
        return angleForEachThumbnail * cappedProgress
    }
}
    
//#Preview {
//    CircularScrollView()
//}
