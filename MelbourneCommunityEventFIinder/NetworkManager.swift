import Foundation
import CoreLocation

final class NetworkManager: ObservableObject {
    private let apiKey = "4BS5jMwreXxo8OGkmvo9rlGuZQH2tkkv" // Replace with your actual API key
    @Published var events: [Event] = []
    @Published var lastError: String?

    private let baseURL = URL(string: "https://app.ticketmaster.com/discovery/v2/events.json")!

    func fetchEvents(city: String, countryCode: String = "AU", size: Int = 20) {
        lastError = nil

        var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "countryCode", value: countryCode),
            URLQueryItem(name: "city", value: city),
            URLQueryItem(name: "size", value: String(size))
        ]

        guard let url = comps.url else {
            DispatchQueue.main.async { self.lastError = "Invalid URL." }
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { self.lastError = error.localizedDescription }
                return
            }

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                DispatchQueue.main.async { self.lastError = "HTTP \(http.statusCode)" }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { self.lastError = "Empty response." }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(TMResponse.self, from: data)
                let tmEvents: [TMEvent] = decoded._embedded?.events ?? []

                let mapped: [Event] = tmEvents.map { e in
                    let imageURL = e.images?.first?.url ?? ""
                    let venueName = e.embedded?.venues?.first?.name ?? ""
                    let cityName = e.embedded?.venues?.first?.city.name ?? ""
                    let latitude = e.embedded?.venues?.first?.location?.latitude ?? 0.0
                    let longitude = e.embedded?.venues?.first?.location?.longitude ?? 0.0
                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                    let classificationLabel = e.embedded?.classifications?.first.flatMap { c in
                        let seg = c.segment.name
                        let gen = c.genre?.name
                        let sub = c.subGenre?.name
                        return [seg, gen, sub].compactMap { $0 }.joined(separator: ".")
                    } ?? ""

                    let uiDate = Self.formatDate(
                        localDate: e.dates?.start?.localDate,
                        localTime: e.dates?.start?.localTime,
                        iso8601:   e.dates?.start?.dateTime
                    )

                    return Event(
                        id: e.id,
                        name: e.name,
                        dateTime: uiDate,
                        venue: venueName,
                        city: cityName,
                        imageURL: imageURL,
                        classification: classificationLabel,
                        location: location
                    )
                }

                DispatchQueue.main.async { self.events = mapped }
            } catch {
                DispatchQueue.main.async { self.lastError = "Decoding error: \(error.localizedDescription)" }
            }
        }

        task.resume()
    }

    static func formatDate(localDate: String?, localTime: String?, iso8601: String?) -> String {
        if let d = localDate, let t = localTime {
            let composed = d + " " + t
            let inFmt = DateFormatter()
            inFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = inFmt.date(from: composed) {
                return outFormatter.string(from: date)
            }
        }

        if let iso = iso8601 {
            let isoFmt = ISO8601DateFormatter()
            if let date = isoFmt.date(from: iso) {
                return outFormatter.string(from: date)
            }
        }

        if let d = localDate { return d }
        return "TBA"
    }

    static var outFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy 'at' h:mm a"
        return f
    }()
}

