import Foundation

struct Venue: Identifiable, Codable {
    let id: String
    var name: String
    var location: String?
    var performances: [String]
    var createdAt: Date
    var updatedAt: Date

    init(id: String = UUID().uuidString,
         name: String,
         location: String? = nil,
         performances: [String] = [],
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.location = location
        self.performances = performances
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct Performance: Identifiable, Codable {
    let id: String
    var name: String
    var venueId: String
    var setlistId: String
    var performanceDate: Date?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    init(id: String = UUID().uuidString,
         name: String,
         venueId: String,
         setlistId: String,
         performanceDate: Date? = nil,
         notes: String? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.venueId = venueId
        self.setlistId = setlistId
        self.performanceDate = performanceDate
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
