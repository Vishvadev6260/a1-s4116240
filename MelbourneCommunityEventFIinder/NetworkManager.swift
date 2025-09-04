//
//  NetworkManager.swift
//  MelbourneCommunityEventFinder
//
//  Created by You on 2025-09-04.
//

import Foundation

// MARK: - UI Event model (what the view uses)
struct Event: Identifiable, Codable {
    let id: String
    let name: String
    let dateTime: String
    let venue: String
    let city: String
    let imageURL: String
}

// MARK: - Ticketmaster API response models (minimal, decoded from /discovery/v2/events.json)
private struct TMResponse: Decodable {
    let embedded: TMEmbedded?

    enum CodingKeys: String, CodingKey { case embedded = "_embedded" }
}
private struct TMEmbedded: Decodable { let events: [TMEvent]? }

private struct TMEvent: Decodable {
    let id: String
    let name: String
    let dates: TMDates?
    let images: [TMImage]?
    let embedded: TMEventEmbedded?

    enum CodingKeys: String, CodingKey {
        case id, name, dates, images
        case embedded = "_embedded"
    }
}
private struct TMImage: Decodable { let url: String }
private struct TMDates: Decodable { let start: TMStart? }
private struct TMStart: Decodable { let localDate: String?; let localTime: String?; let dateTime: String? }
private struct TMEventEmbedded: Decodable { let venues: [TMVenue]? }
private struct TMVenue: Decodable { let name: String?; let city: TMCity? }
private struct TMCity: Decodable { let name: String? }

// MARK: - Network Manager
final class NetworkManager: ObservableObject {

    // Replace with your Ticketmaster Consumer Key
    private let apiKey = "4BS5jMwreXxo8OGkmvo9rlGuZQH2tkkv"

    @Published var events: [Event] = []
    @Published var lastError: String?

    // Base URL for Ticketmaster Discovery API
    private let baseURL = URL(string: "https://app.ticketmaster.com/discovery/v2/events.json")!

    /// Fetch events by city (defaults to AU). Adjust `size` to change page size.
    func fetchEvents(city: String, countryCode: String = "AU", size: Int = 20) {
        lastError = nil

        // Build URL with proper query items (safe encoding)
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

        // Fire request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Network-level error
            if let error = error {
                DispatchQueue.main.async { self.lastError = error.localizedDescription }
                return
            }

            // HTTP status debugging (non-2xx)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                DispatchQueue.main.async { self.lastError = "HTTP \(http.statusCode)" }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { self.lastError = "Empty response." }
                return
            }

            // Decode and map to our Event model
            do {
                let decoded = try JSONDecoder().decode(TMResponse.self, from: data)
                let tmEvents = decoded.embedded?.events ?? []

                let mapped: [Event] = tmEvents.map { e in
                    // Pick first image (if any)
                    let imageURL = e.images?.first?.url ?? ""

                    // Venue & city
                    let venueName = e.embedded?.venues?.first?.name ?? ""
                    let cityName  = e.embedded?.venues?.first?.city?.name ?? ""

                    // Human-readable date/time
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
                        imageURL: imageURL
                    )
                }

                DispatchQueue.main.async { self.events = mapped }
            } catch {
                // If decoding fails, surface a short message (data often still OK to print for debugging)
                DispatchQueue.main.async { self.lastError = "Decoding error: \(error.localizedDescription)" }
            }
        }

        task.resume()
    }
}

// MARK: - Date helpers
private extension NetworkManager {
    /// Try to produce a nice local string like “10 Sep 2025 at 7:30 pm”
    static func formatDate(localDate: String?, localTime: String?, iso8601: String?) -> String {
        // 1) If Ticketmaster gave us localDate + localTime, combine those.
        if let d = localDate, let t = localTime {
            let composed = d + " " + t   // "YYYY-MM-DD HH:mm:ss"
            let inFmt = DateFormatter()
            inFmt.calendar = Calendar(identifier: .gregorian)
            inFmt.locale = Locale(identifier: "en_US_POSIX")
            inFmt.timeZone = .current
            inFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"

            if let date = inFmt.date(from: composed) {
                return outFormatter.string(from: date)
            }
        }

        // 2) Else try ISO8601 `dateTime` (UTC)
        if let iso = iso8601 {
            let isoFmt = ISO8601DateFormatter()
            isoFmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFmt.date(from: iso) {
                return outFormatter.string(from: date)
            }
            // try without fractional seconds
            isoFmt.formatOptions = [.withInternetDateTime]
            if let date = isoFmt.date(from: iso) {
                return outFormatter.string(from: date)
            }
        }

        // 3) Fallback to whatever we have
        if let d = localDate, let t = localTime { return "\(d) \(t)" }
        if let d = localDate { return d }
        return "TBA"
    }

    static var outFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.timeZone = .current
        f.dateFormat = "d MMM yyyy 'at' h:mm a"
        return f
    }()
}

