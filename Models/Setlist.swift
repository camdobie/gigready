import Foundation

struct Setlist: Identifiable, Codable {
    let id: String
    var name: String
    var sets: [SetGroup]
    var extraSongs: [String]
    var createdAt: Date
    var updatedAt: Date

    init(id: String = UUID().uuidString,
         name: String,
         sets: [SetGroup] = [],
         extraSongs: [String] = [],
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.sets = sets
        self.extraSongs = extraSongs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct SetGroup: Identifiable, Codable {
    let id: String
    var name: String
    var songIds: [String]
    var order: Int

    init(id: String = UUID().uuidString,
         name: String,
         songIds: [String] = [],
         order: Int = 0) {
        self.id = id
        self.name = name
        self.songIds = songIds
        self.order = order
    }
}

enum SortOption: String, CaseIterable {
    case original = "Original"
    case alphabetical = "Alphabetical"
    case tempoMixed = "Tempo Mixed"
    case tempoSlowToFast = "Slow to Fast"
    case randomized = "Randomized"
}
