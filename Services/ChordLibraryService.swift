import Foundation

class ChordLibraryService {
    static let shared = ChordLibraryService()

    let basicChords = [
        "C", "D", "E", "F", "G", "A", "B",
        "Cm", "Dm", "Em", "Fm", "Gm", "Am", "Bm"
    ]

    let extendedChords: [String: [String]] = [
        "C": ["C7", "Cadd9", "Csus2", "Caug", "Cdim"],
        "D": ["D7", "Dadd9", "Dsus2", "Daug", "Ddim"],
        "E": ["E7", "Eadd9", "Esus2", "Eaug", "Edim"],
        "F": ["F7", "Fadd9", "Fsus2", "Faug", "Fdim"],
        "G": ["G7", "Gadd9", "Gsus2", "Gaug", "Gdim"],
        "A": ["A7", "Aadd9", "Asus2", "Aaug", "Adim"],
        "B": ["B7", "Badd9", "Bsus2", "Baug", "Bdim"],
        "Cm": ["Cm7", "Cmadd9", "Cmsus2", "Cmaug", "Cmdim"],
        "Dm": ["Dm7", "Dmadd9", "Dmsus2", "Dmaug", "Dmdim"],
        "Em": ["Em7", "Emadd9", "Emsus2", "Emaug", "Emdim"],
        "Fm": ["Fm7", "Fmadd9", "Fmsus2", "Fmaug", "Fmdim"],
        "Gm": ["Gm7", "Gmadd9", "Gmsus2", "Gmaug", "Gmdim"],
        "Am": ["Am7", "Amadd9", "Amsus2", "Amaug", "Amdim"],
        "Bm": ["Bm7", "Bmadd9", "Bmsus2", "Bmaug", "Bmdim"]
    ]

    var recentlyUsedChords: [String] = [] {
        didSet {
            saveRecentChords()
        }
    }

    init() {
        loadRecentChords()
    }

    func getExtendedChords(for chord: String) -> [String] {
        return extendedChords[chord] ?? []
    }

    func addRecentChord(_ chord: String) {
        if !recentlyUsedChords.contains(chord) {
            recentlyUsedChords.insert(chord, at: 0)
        } else if let index = recentlyUsedChords.firstIndex(of: chord) {
            recentlyUsedChords.remove(at: index)
            recentlyUsedChords.insert(chord, at: 0)
        }

        if recentlyUsedChords.count > 10 {
            recentlyUsedChords.removeLast()
        }
    }

    func searchChords(_ query: String) -> [String] {
        let allChords = basicChords + extendedChords.values.flatMap { $0 }
        return allChords.filter { $0.lowercased().contains(query.lowercased()) }
    }

    private func saveRecentChords() {
        UserDefaults.standard.set(recentlyUsedChords, forKey: "recentlyUsedChords")
    }

    private func loadRecentChords() {
        if let saved = UserDefaults.standard.array(forKey: "recentlyUsedChords") as? [String] {
            recentlyUsedChords = saved
        }
    }
}
