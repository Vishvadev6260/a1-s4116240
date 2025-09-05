import Foundation
import CoreLocation

struct Event: Identifiable {
    let id: String
    let name: String
    let dateTime: String
    let venue: String
    let city: String
    let imageURL: String
    let classification: String
    let location: CLLocationCoordinate2D
}
