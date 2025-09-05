import Foundation

// TMClassification conforms to Codable and Identifiable, now unified to prevent conflicts
struct TMClassification: Codable, Identifiable {
    let id: UUID
    let segment: TNName
    let genre: TNName?
    let subGenre: TNName?

    enum CodingKeys: String, CodingKey {
        case segment
        case genre
        case subGenre = "sub_genre"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()  // Generate UUID for each instance
        segment = try container.decode(TNName.self, forKey: .segment)
        genre = try container.decodeIfPresent(TNName.self, forKey: .genre)
        subGenre = try container.decodeIfPresent(TNName.self, forKey: .subGenre)
    }
}

struct TNName: Codable {
    let id: String
    let name: String
}

