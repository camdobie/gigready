import Foundation

struct Song: Identifiable, Codable {
    let id: String
    var name: String
    var lyrics: String
    var chords: [ChordPlacement]
    var tempo: Int?
    var capRequired: Bool
    var createdAt: Date
    var updatedAt: Date

    init(id: String = UUID().uuidString,
         name: String,
         lyrics: String,
         chords: [ChordPlacement] = [],
         tempo: Int? = nil,
         capRequired: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.lyrics = lyrics
        self.chords = chords
        self.tempo = tempo
        self.capRequired = capRequired
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct ChordPlacement: Identifiable, Codable {
    let id: String
    var chordName: String
    var lineIndex: Int
    var wordIndex: Int
    var characterOffset: Int

    init(id: String = UUID().uuidString,
         chordName: String,
         lineIndex: Int,
         wordIndex: Int,
         characterOffset: Int = 0) {
        self.id = id
        self.chordName = chordName
        self.lineIndex = lineIndex
        self.wordIndex = wordIndex
        self.characterOffset = characterOffset
    }
}
