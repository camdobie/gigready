import Foundation
import Combine

class ImportViewModel: ObservableObject {
    @Published var importedSongs: [FileImportService.ImportedSong] = []
    @Published var isLoading = false
    @Published var progress: Double = 0
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var ugSearchResults: [UltimateGuitarService.TabResult] = []
    @Published var ugSearchQuery = ""

    private let firebaseService = FirebaseService.shared
    private let importService = FileImportService.shared
    private var userId: String

    init(userId: String) {
        self.userId = userId
    }

    // MARK: - File Import

    func importFiles(_ urls: [URL]) {
        isLoading = true
        progress = 0

        importService.importFiles(urls) { [weak self] songs, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let songs = songs {
                    self?.importedSongs = songs
                    self?.successMessage = "Successfully imported \(songs.count) song(s)"
                    self?.progress = 1.0
                }
            }
        }
    }

    func importFile(_ url: URL) {
        isLoading = true
        importService.importFile(url) { [weak self] song, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let song = song {
                    self?.importedSongs = [song]
                    self?.successMessage = "Successfully imported song"
                }
            }
        }
    }

    // MARK: - Ultimate Guitar Search

    func searchUltimateGuitar() {
        guard !ugSearchQuery.isEmpty else {
            errorMessage = "Please enter a song or artist name"
            return
        }

        isLoading = true
        importService.searchUltimateGuitar(ugSearchQuery) { [weak self] results, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Search failed: \(error.localizedDescription)"
                } else if let results = results {
                    self?.ugSearchResults = results
                }
            }
        }
    }

    func importFromUltimateGuitar(tabId: Int) {
        isLoading = true
        importService.importFromUltimateGuitar(tabId: String(tabId)) { [weak self] song, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let song = song {
                    self?.importedSongs = [song]
                    self?.successMessage = "Successfully imported from Ultimate Guitar"
                }
            }
        }
    }

    // MARK: - Save Imported Songs

    func saveImportedSongs(to setlistId: String, to setIndex: Int) {
        guard !importedSongs.isEmpty else {
            errorMessage = "No songs to save"
            return
        }

        isLoading = true

        // Save each song to Firebase
        let group = DispatchGroup()

        for importedSong in importedSongs {
            group.enter()
            firebaseService.saveSong(importedSong.song, for: userId) { [weak self] error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.successMessage = "Saved \(self?.importedSongs.count ?? 0) song(s)"
            self?.importedSongs = []
        }
    }

    // MARK: - Utils

    func removeSong(_ song: FileImportService.ImportedSong) {
        importedSongs.removeAll { $0.song.id == song.song.id }
    }

    func clearAll() {
        importedSongs = []
        errorMessage = nil
        successMessage = nil
    }
}

// Extension for FirebaseService to add completion handler
extension FirebaseService {
    func saveSong(_ song: Song, for userId: String, completion: @escaping (Error?) -> Void) {
        do {
            let encodedSong = try JSONEncoder().encode(song)
            let songDict = try JSONSerialization.jsonObject(with: encodedSong) as? [String: Any]

            if let dbRef = Database.database().reference() {
                dbRef.child("users").child(userId).child("songs").child(song.id).setValue(songDict) { error, _ in
                    completion(error)
                }
            } else {
                completion(NSError(domain: "FirebaseError", code: -1, userInfo: nil))
            }
        } catch {
            completion(error)
        }
    }
}
