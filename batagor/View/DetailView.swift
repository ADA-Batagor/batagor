import SwiftUI
import CoreLocation
import MapKit

struct DetailView: View {
    @Binding var storage: Storage?
    
    @State private var showToolbar: Bool = true
    @State private var placemarkInfo: PlacemarkInfo?
    
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
                    
                    // Location info overlay
                    if let storage = storage, storage.coordinate != nil {
                        LocationInfoView(storage: storage, placemarkInfo: $placemarkInfo)
                            .padding(.bottom, 20)
                    }
                        
                    HStack {
                        Button {
                            
                        } label: {
                            Text("Share")
                        }
                        
                        Spacer()
                        
                        Text("Expired")
                    }
                }
                .padding(.vertical, 50)
                .padding(.top, 20)
                .padding(.horizontal, 30)
                .opacity(showToolbar ? 1 : 0)
            }
            
        }
        .ignoresSafeArea(.all)
        .onTapGesture {
            withAnimation(.easeInOut) {
                showToolbar.toggle()
            }
        }
        .task {
            // Reverse geocode location when view appears
            if let storage = storage, let coordinate = storage.coordinate {
                await reverseGeocodeLocation(coordinate)
            }
        }
    }
    
    private func reverseGeocodeLocation(_ coordinate: CLLocationCoordinate2D) async {
        // Try MKLocalSearch first for better building/business names
        await searchForBuilding(coordinate: coordinate)
        
        // Fallback to CLGeocoder for address details
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                var info = PlacemarkInfo(from: placemark)
                
                // If MKLocalSearch found a better name, keep it
                if let existingName = placemarkInfo?.name, !existingName.isEmpty {
                    info.name = existingName
                }
                
                placemarkInfo = info
            }
        } catch {
            print("Reverse geocoding error: \(error.localizedDescription)")
        }
    }
    
    private func searchForBuilding(coordinate: CLLocationCoordinate2D) async {
        let request = MKLocalSearch.Request()
        request.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
        request.resultTypes = [.pointOfInterest, .address]
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            
            // Find the closest item to our coordinate
            let sortedItems = response.mapItems.sorted { item1, item2 in
                let loc1 = item1.placemark.coordinate
                let loc2 = item2.placemark.coordinate
                let dist1 = distance(from: coordinate, to: loc1)
                let dist2 = distance(from: coordinate, to: loc2)
                return dist1 < dist2
            }
            
            // Use the closest item if it's within 50 meters
            if let closest = sortedItems.first,
               distance(from: coordinate, to: closest.placemark.coordinate) < 50 {
                // Prioritize business name over street address
                if let name = closest.name, !name.isEmpty {
                    var tempInfo = PlacemarkInfo(from: closest.placemark)
                    tempInfo.name = name
                    placemarkInfo = tempInfo
                }
            }
        } catch {
            print("Local search error: \(error.localizedDescription)")
        }
    }
    
    private func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
}

// Struct to hold all placemark information
struct PlacemarkInfo {
    var name: String?                    // Building/landmark name
    let thoroughfare: String?            // Street name
    let subThoroughfare: String?         // Street number
    let locality: String?                // City
    let subLocality: String?             // Neighborhood/district
    let administrativeArea: String?      // State/province
    let postalCode: String?              // ZIP/postal code
    let country: String?                 // Country
    let isoCountryCode: String?          // Country code (e.g., "US")
    let areasOfInterest: [String]?       // Points of interest
    
    var shortDescription: String {
        // Prioritize building/landmark name, then street, then city
        if let name = name {
            return name
        } else if let thoroughfare = thoroughfare {
            return thoroughfare
        } else if let locality = locality {
            return locality
        }
        return "Unknown Location"
    }
    
    var fullAddress: String {
        var components: [String] = []
        
        if let name = name {
            components.append(name)
        }
        if let subThoroughfare = subThoroughfare, let thoroughfare = thoroughfare {
            components.append("\(subThoroughfare) \(thoroughfare)")
        } else if let thoroughfare = thoroughfare {
            components.append(thoroughfare)
        }
        if let subLocality = subLocality {
            components.append(subLocality)
        }
        if let locality = locality {
            components.append(locality)
        }
        if let administrativeArea = administrativeArea {
            components.append(administrativeArea)
        }
        if let postalCode = postalCode {
            components.append(postalCode)
        }
        if let country = country {
            components.append(country)
        }
        
        return components.joined(separator: ", ")
    }
    
    init(from placemark: CLPlacemark) {
        self.name = placemark.name
        self.thoroughfare = placemark.thoroughfare
        self.subThoroughfare = placemark.subThoroughfare
        self.locality = placemark.locality
        self.subLocality = placemark.subLocality
        self.administrativeArea = placemark.administrativeArea
        self.postalCode = placemark.postalCode
        self.country = placemark.country
        self.isoCountryCode = placemark.isoCountryCode
        self.areasOfInterest = placemark.areasOfInterest
    }
}

struct LocationInfoView: View {
    let storage: Storage
    @Binding var placemarkInfo: PlacemarkInfo?
    @State private var showFullInfo = false
    
    var body: some View {
        VStack(spacing: 8) {
            if showFullInfo {
                // Full location details
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Building/Landmark name (prominent)
                        if let name = placemarkInfo?.name {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "building.2.fill")
                                    .foregroundColor(.purple)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Building/Place")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(name)
                                        .font(.headline)
                                }
                            }
                        }
                        
                        // Areas of Interest
                        if let areasOfInterest = placemarkInfo?.areasOfInterest, !areasOfInterest.isEmpty {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Points of Interest")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(areasOfInterest.joined(separator: ", "))
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        // Street Address
                        if let subThoroughfare = placemarkInfo?.subThoroughfare,
                           let thoroughfare = placemarkInfo?.thoroughfare {
                            LocationDetailRow(
                                icon: "signpost.right.fill",
                                color: .blue,
                                label: "Street",
                                value: "\(subThoroughfare) \(thoroughfare)"
                            )
                        } else if let thoroughfare = placemarkInfo?.thoroughfare {
                            LocationDetailRow(
                                icon: "signpost.right.fill",
                                color: .blue,
                                label: "Street",
                                value: thoroughfare
                            )
                        }
                        
                        // Neighborhood
                        if let subLocality = placemarkInfo?.subLocality {
                            LocationDetailRow(
                                icon: "map.fill",
                                color: .teal,
                                label: "Neighborhood",
                                value: subLocality
                            )
                        }
                        
                        // City & State
                        if let locality = placemarkInfo?.locality {
                            let cityState = if let state = placemarkInfo?.administrativeArea {
                                "\(locality), \(state)"
                            } else {
                                locality
                            }
                            LocationDetailRow(
                                icon: "building.2.crop.circle.fill",
                                color: .indigo,
                                label: "City",
                                value: cityState
                            )
                        }
                        
                        // Country
                        if let country = placemarkInfo?.country {
                            LocationDetailRow(
                                icon: "globe",
                                color: .red,
                                label: "Country",
                                value: country
                            )
                        }
                        
                        Divider()
                        
                        // GPS Coordinates
                        if let lat = storage.latitude, let lon = storage.longitude {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.blue)
                                    Text("Coordinates")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text(String(format: "%.6f, %.6f", lat, lon))
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }
                        
                        // Altitude
                        if let altitude = storage.altitude {
                            HStack {
                                Image(systemName: "mountain.2.fill")
                                    .foregroundColor(.green)
                                Text(String(format: "%.1f m altitude", altitude))
                                    .font(.caption)
                            }
                        }
                        
                        Divider()
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            // Open in Maps
                            if let coordinate = storage.coordinate {
                                Button {
                                    openInMaps(coordinate: coordinate)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "map.fill")
                                        Text("Maps")
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Copy address
                            if let fullAddress = placemarkInfo?.fullAddress {
                                Button {
                                    UIPasteboard.general.string = fullAddress
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.doc.fill")
                                        Text("Copy")
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.3))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 400)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(radius: 10)
            } else {
                // Compact location button
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showFullInfo = true
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(placemarkInfo?.shortDescription ?? "Location")
                            .font(.subheadline)
                            .lineLimit(1)
                        Image(systemName: "chevron.up")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                }
            }
        }
        .onTapGesture {
            if showFullInfo {
                withAnimation(.spring(response: 0.3)) {
                    showFullInfo = false
                }
            }
        }
    }
    
    private func openInMaps(coordinate: CLLocationCoordinate2D) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = placemarkInfo?.name ?? placemarkInfo?.fullAddress ?? "Photo Location"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        ])
    }
}

struct LocationDetailRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
            }
        }
    }
}
