//
//  widget.swift
//  widget
//
//  Created by Gede Pramananda Kusuma Wisesa on 28/10/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> GalleryEntry {
        GalleryEntry(date: Date(), media: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GalleryEntry) -> Void) {
        let entry = GalleryEntry(date: Date(), media: [])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GalleryEntry>) -> Void) {
        Task {
            let currentDate = Date()
            let media = await fetchRecentMedia(limit: 4)
            print(media)
            let entry = GalleryEntry(date: currentDate, media: media)
            print(entry)
            
            let nextUpdate: Date
            if media.isEmpty {
                nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            } else {
                nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
            }
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            completion(timeline)
        }
        
    }
    
    @MainActor private func fetchRecentMedia(limit: Int) -> [Storage] {
        print("fetchRecentMedia: running fetch media func")
        let modelContext = SharedModelContainer.shared.mainContext
        
        let descriptor = FetchDescriptor<Storage>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        
        guard let allStorages = try? modelContext.fetch(descriptor) else {
            print("fetchRecentMedia: failed to fetch all storages")
            return []
        }
        
        let validMedia = allStorages.filter{!$0.isExpired}.prefix(limit)
        return validMedia.compactMap { storage in
            guard StorageManager.shared.loadUIImage(fileURL: storage.thumbnailPath) != nil else {
                print("fetchRecentMedia: thumbnail not found \(storage.thumbnailPath)")
                return nil
            }
            return storage
        }
    }

}

// MARK: - Helper Functions
  func loadThumbnailForWidget(fileURL: URL, maxDimension: CGFloat = 400) -> UIImage? {
      guard let fullImage = StorageManager.shared.loadUIImage(fileURL: fileURL) else {
          return nil
      }

      return fullImage.resizedForWidget(maxDimension: maxDimension)
  }

struct GalleryEntry: TimelineEntry {
    let date: Date
    let media: [Storage]
}

struct widgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(media: entry.media)
        case .systemMedium:
            MediumWidgetView(media: entry.media)
        case .systemLarge:
            LargeWidgetView(media: entry.media)
        default:
            SmallWidgetView(media: entry.media)
        }
    }
}

// MARK: - Small Widget (1 photo)
struct SmallWidgetView: View {
    let media: [Storage]

    var body: some View {
        if let media = media.first {
            let mediaImage = loadThumbnailForWidget(fileURL: media.thumbnailPath)
            if let mediaImage = mediaImage {
                GeometryReader { geometry in
                    Image(uiImage: mediaImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .cornerRadius(8)
                }
                .widgetURL(URL(string: "batagor://gallery"))
            }
        } else {
            EmptyWidgetView()
        }
    }
}

// MARK: - Medium Widget (2 photos)
struct MediumWidgetView: View {
    let media: [Storage]

    var body: some View {
        if media.isEmpty {
            EmptyWidgetView()
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent media")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                
                HStack(spacing: 8) {
                    ForEach(media.prefix(3)) { mediaItem in
                        let mediaImage = loadThumbnailForWidget(fileURL: mediaItem.thumbnailPath)
                        if let mediaImage = mediaImage {
                            GeometryReader { geometry in
                                Image(uiImage: mediaImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.width)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .widgetURL(URL(string: "batagor://gallery"))
        }
    }
}

// MARK: - Large Widget (2x2 grid photos)
struct LargeWidgetView: View {
    let media: [Storage]

    var body: some View {
        if media.isEmpty {
            EmptyWidgetView()
        } else {
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    ForEach(media.prefix(2)) { media in
                        let mediaImage = loadThumbnailForWidget(fileURL: media.thumbnailPath)
                        if let mediaImage = mediaImage {
                            Image(uiImage: mediaImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .clipped()
                        }
                    }
                }

                if media.count > 2 {
                    HStack(spacing: 2) {
                        ForEach(media.prefix(2)) { media in
                            let mediaImage = loadThumbnailForWidget(fileURL: media.thumbnailPath)
                            if let mediaImage = mediaImage {
                                Image(uiImage: mediaImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Empty State
struct EmptyWidgetView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
            Text("No Photos")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - UIImage Widget Extension
extension UIImage {
    func resizedForWidget(maxDimension: CGFloat) -> UIImage {
        if size.width <= maxDimension && size.height <= maxDimension {
            return self
        }
        
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}


struct widget: Widget {
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            widgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Recents")
        .description("View your most recent captured media")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

//extension ConfigurationAppIntent {
//    fileprivate static var smiley: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "😀"
//        return intent
//    }
//    
//    fileprivate static var starEyes: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "🤩"
//        return intent
//    }
//}

// MARK: - Previews

// MARK: - Preview Sample Data
extension GalleryEntry {
    static var sampleMedia: [Storage] {
        (1...4).map { index in
            Storage(
                mainPath: URL(fileURLWithPath: "/tmp/sample\(index).jpg"),
                thumbnailPath: URL(fileURLWithPath:
                                    "/tmp/sample\(index)_thumb.jpg")
            )
        }
    }
    
    static var sampleEntry: GalleryEntry {
        GalleryEntry(date: .now, media: sampleMedia)
    }
}


#Preview(as: .systemSmall) {
    widget()
} timeline: {
//    GalleryEntry.sampleEntry
    GalleryEntry(date: Date(), media: [])
}

#Preview(as: .systemMedium) {
    widget()
} timeline: {
//    GalleryEntry.sampleEntry
    GalleryEntry(date: Date(), media: [])
}

#Preview(as: .systemLarge) {
    widget()
} timeline: {
//    GalleryEntry.sampleEntry
    GalleryEntry(date: Date(), media: [])
}
