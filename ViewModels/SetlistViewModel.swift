import Foundation
import Combine

class SetlistViewModel: ObservableObject {
    @Published var setlist: Setlist
    @Published var songs: [String: Song] = [:]
    @Published var sortOption: SortOption = .original
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firebaseService = FirebaseService.shared
    private var userId: String

    init(setlist: Setlist, userId: String) {
        self.setlist = setlist
        self.userId = userId
        loadSongs()
    }

    // MARK: - Song Management

    func loadSongs() {
        isLoading = true
        firebaseService.loadSongs(for: userId) { [weak self] songs in
            var songDict: [String: Song] = [:]
            for song in songs {
                songDict[song.id] = song
            }
            self?.songs = songDict
            self?.isLoading = false
        }
    }

    func addSongToSet(_ songId: String, setIndex: Int) {
        guard setIndex < setlist.sets.count else { return }
        if !setlist.sets[setIndex].songIds.contains(songId) {
            setlist.sets[setIndex].songIds.append(songId)
            saveSetlist()
        }
    }

    func removeSongFromSet(_ songId: String, setIndex: Int) {
        guard setIndex < setlist.sets.count else { return }
        setlist.sets[setIndex].songIds.removeAll { $0 == songId }
        saveSetlist()
    }

    func addSongToExtraSongs(_ songId: String) {
        if !setlist.extraSongs.contains(songId) {
            setlist.extraSongs.append(songId)
            setlist.extraSongs.sort { song1, song2 in
                let name1 = songs[song1]?.name ?? ""
                let name2 = songs[song2]?.name ?? ""
                return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
            }
            saveSetlist()
        }
    }

    func removeSongFromExtraSongs(_ songId: String) {
        setlist.extraSongs.removeAll { $0 == songId }
        saveSetlist()
    }

    func moveSong(_ songId: String, from sourceSetIndex: Int, to destinationSetIndex: Int) {
        removeSongFromSet(songId, setIndex: sourceSetIndex)
        addSongToSet(songId, setIndex: destinationSetIndex)
    }

    // MARK: - Set Management

    func createNewSet(name: String? = nil) {
        let setName = name ?? "Set \(setlist.sets.count + 1)"
        let newSet = SetGroup(name: setName, order: setlist.sets.count)
        setlist.sets.append(newSet)
        saveSetlist()
    }

    func deleteSet(_ setIndex: Int) {
        guard setIndex < setlist.sets.count else { return }
        let deletedSet = setlist.sets.remove(at: setIndex)
        for (index, _) in setlist.sets.enumerated() {
            setlist.sets[index].order = index
        }
        setlist.updatedAt = Date()
        saveSetlist()
    }

    // MARK: - Sorting

    func getSortedSongIds(for setIndex: Int) -> [String] {
        guard setIndex < setlist.sets.count else { return [] }
        let songIds = setlist.sets[setIndex].songIds

        switch sortOption {
        case .original:
            return songIds
        case .alphabetical:
            return songIds.sorted { id1, id2 in
                let name1 = songs[id1]?.name ?? ""
                let name2 = songs[id2]?.name ?? ""
                return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
            }
        case .tempoSlowToFast:
            return songIds.sorted { id1, id2 in
                let tempo1 = songs[id1]?.tempo ?? Int.max
                let tempo2 = songs[id2]?.tempo ?? Int.max
                return tempo1 < tempo2
            }
        case .tempoMixed:
            return songIds.sorted { id1, id2 in
                guard let tempo1 = songs[id1]?.tempo, let tempo2 = songs[id2]?.tempo else {
                    return false
                }
                let mid = 120
                let diff1 = abs(tempo1 - mid)
                let diff2 = abs(tempo2 - mid)
                return diff1 < diff2
            }
        case .randomized:
            return songIds.shuffled()
        }
    }

    func getExtraSongsAlphabetical() -> [String] {
        return setlist.extraSongs.sorted { id1, id2 in
            let name1 = songs[id1]?.name ?? ""
            let name2 = songs[id2]?.name ?? ""
            return name1.localizedCaseInsensitiveCompare(name2) == .orderedAscending
        }
    }

    // MARK: - Persistence

    func saveSetlist() {
        setlist.updatedAt = Date()
        firebaseService.saveSetlist(setlist, for: userId)
    }
}
