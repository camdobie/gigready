import Foundation
import Combine

class SongDetailViewModel: ObservableObject {
    @Published var song: Song
    @Published var isEditing = false
    @Published var selectedChordPosition: ChordPosition?
    @Published var chordLibrary = ChordLibraryService.shared
    @Published var errorMessage: String?

    private let firebaseService = FirebaseService.shared
    private var userId: String

    struct ChordPosition {
        let lineIndex: Int
        let wordIndex: Int
    }

    init(song: Song, userId: String) {
        self.song = song
        self.userId = userId
    }

    // MARK: - Song Editing

    func updateSongName(_ name: String) {
        song.name = name
        song.updatedAt = Date()
    }

    func updateLyrics(_ lyrics: String) {
        song.lyrics = lyrics
        song.updatedAt = Date()
    }

    func updateCapRequired(_ required: Bool) {
        song.capRequired = required
        song.updatedAt = Date()
    }

    func updateTempo(_ tempo: Int?) {
        song.tempo = tempo
        song.updatedAt = Date()
    }

    // MARK: - Chord Management

    func addChord(_ chordName: String, at position: ChordPosition) {
        let chordPlacement = ChordPlacement(
            chordName: chordName,
            lineIndex: position.lineIndex,
            wordIndex: position.wordIndex
        )
        song.chords.append(chordPlacement)
        song.updatedAt = Date()
        chordLibrary.addRecentChord(chordName)
    }

    func updateChord(_ chordId: String, newName: String) {
        if let index = song.chords.firstIndex(where: { $0.id == chordId }) {
            song.chords[index].chordName = newName
            song.updatedAt = Date()
        }
    }

    func deleteChord(_ chordId: String) {
        song.chords.removeAll { $0.id == chordId }
        song.updatedAt = Date()
    }

    func getChordsForLine(_ lineIndex: Int) -> [ChordPlacement] {
        return song.chords.filter { $0.lineIndex == lineIndex }
    }

    func getChordsForWord(_ lineIndex: Int, wordIndex: Int) -> [ChordPlacement] {
        return song.chords.filter { $0.lineIndex == lineIndex && $0.wordIndex == wordIndex }
    }

    // MARK: - Lyrics Analysis

    func getLyricsLines() -> [String] {
        return song.lyrics.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    }

    func getWords(for line: String) -> [String] {
        return line.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
    }

    // MARK: - Persistence

    func saveSong() {
        song.updatedAt = Date()
        firebaseService.saveSong(song, for: userId)
        isEditing = false
    }

    func discardChanges() {
        isEditing = false
    }
}
