import Foundation

class ChordSelectorViewModel: ObservableObject {
    @Published var selectedBasicChord: String?
    @Published var searchQuery = ""
    @Published var showExtendedChords = false

    private let chordLibrary = ChordLibraryService.shared

    var basicChords: [String] {
        chordLibrary.basicChords
    }

    var extendedChords: [String] {
        guard let selectedChord = selectedBasicChord else { return [] }
        return chordLibrary.getExtendedChords(for: selectedChord)
    }

    var recentlyUsedChords: [String] {
        chordLibrary.recentlyUsedChords.prefix(5).map { String($0) }
    }

    var searchResults: [String] {
        if searchQuery.isEmpty {
            return []
        }
        return chordLibrary.searchChords(searchQuery)
    }

    func selectBasicChord(_ chord: String) {
        selectedBasicChord = chord
        showExtendedChords = false
    }

    func selectChord(_ chord: String) -> String {
        chordLibrary.addRecentChord(chord)
        return chord
    }

    func getChordCategories() -> [(category: String, chords: [String])] {
        var categories: [(String, [String])] = []

        if !recentlyUsedChords.isEmpty {
            categories.append(("Recently Used", Array(recentlyUsedChords)))
        }

        let majorChords = basicChords.filter { !$0.contains("m") }
        let minorChords = basicChords.filter { $0.contains("m") }

        if !majorChords.isEmpty {
            categories.append(("Major", majorChords))
        }
        if !minorChords.isEmpty {
            categories.append(("Minor", minorChords))
        }

        return categories
    }
}
