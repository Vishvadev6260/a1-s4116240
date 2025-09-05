import Foundation

// TMResponse will hold the API response structure
struct TMResponse: Decodable {
    let _embedded: TMEmbedded?
}

struct TMEmbedded: Decodable {
    let events: [TMEvent]
}

struct TMEvent: Decodable {
    let id: String
    let name: String
    let images: [TMImage]?
    let dates: TMEventDates?
    let embedded: TMEventEmbedded?
    let classification: String?
}

struct TMImage: Decodable {
    let url: String
}

struct TMEventDates: Decodable {
    let start: TMEventStart?
}

struct TMEventStart: Decodable {
    let localDate: String?
    let localTime: String?
    let dateTime: String?
}

// Define TMEventEmbedded and ensure it conforms to Decodable
struct TMEventEmbedded: Decodable {
    let venues: [TMVenue]?
    let classifications: [TMClassification]? // Uses the TMClassification struct from TMClassification.swift
}

struct TMVenue: Decodable {
    let name: String
    let city: TMCity
    let location: TMLocation?
}

struct TMCity: Decodable {
    let name: String
}

struct TMLocation: Decodable {
    let latitude: Double
    let longitude: Double
}

