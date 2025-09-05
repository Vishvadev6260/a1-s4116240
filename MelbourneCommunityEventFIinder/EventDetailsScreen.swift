import SwiftUI
import MapKit

struct EventDetailsScreen: View {
    let event: Event // Event passed from the previous screen
    
    // Pre-calculate the region for the map
    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: event.location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    // Pre-calculate the map locations (in case there are multiple locations)
    private var mapLocations: [MapLocation] {
        [MapLocation(coordinate: event.location)] // Use actual event location
    }

    // Simplify the image loading logic
    private func loadImage(from url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                Image(systemName: "photo.fill").foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxHeight: 250)
    }

    // Simplify map annotation view
    private func createMapAnnotation(for location: MapLocation) -> some View {
        Image(systemName: "mappin.and.ellipse.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.blue)
            .frame(width: 25, height: 25)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event name
                Text(event.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                // Event Date
                Text("Date: \(event.dateTime)")
                    .font(.headline)
                
                // Event Venue
                Text("Venue: \(event.venue)")
                    .font(.subheadline)
                
                // Event City
                Text("City: \(event.city)")
                    .font(.subheadline)

                // Map for the event's location
                Map(coordinateRegion: .constant(region)) {
                    // Simplified annotations logic
                    ForEach(mapLocations, id: \.id) { location in
                        Annotation(coordinate: location.coordinate) {
                            createMapAnnotation(for: location)
                        }
                    }
                }
                .frame(height: 200)
                .padding()

                // Event image if available
                loadImage(from: event.imageURL)

                // Add more event details if needed
            }
            .padding() // Add padding for spacing around the content
        }
        .navigationTitle(event.name)
    }
}

// Supporting MapLocation struct for the map annotation
struct MapLocation: Identifiable, Hashable {
    let id = UUID() // Automatically generate a unique ID
    let coordinate: CLLocationCoordinate2D

    // Implement Equatable and Hashable so the map works correctly
    static func == (lhs: MapLocation, rhs: MapLocation) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}

