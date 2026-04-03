import Foundation
import CloudKit
import Combine

class CloudKitSyncService: NSObject, ObservableObject {
    static let shared = CloudKitSyncService()

    @Published var isSyncEnabled = false
    @Published var lastSyncDate: Date?
    @Published var syncInProgress = false
    @Published var syncError: Error?
    @Published var syncProgress: Double = 0

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private var cancellables = Set<AnyCancellable>()

    override init() {
        container = CKContainer.default()
        privateDatabase = container.privateCloudDatabase

        super.init()

        checkCloudKitAvailability()
        loadSyncPreferences()
    }

    // MARK: - Availability Check

    func checkCloudKitAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isSyncEnabled = true
                default:
                    self?.isSyncEnabled = false
                    if let error = error {
                        self?.syncError = error
                    }
                }
            }
        }
    }

    // MARK: - Sync Operations

    func syncSetlist(_ setlist: Setlist, userId: String, completion: @escaping (Bool) -> Void) {
        guard isSyncEnabled else {
            completion(false)
            return
        }

        syncInProgress = true
        syncProgress = 0.2

        let record = CKRecord(recordType: "Setlist")
        record["id"] = setlist.id
        record["name"] = setlist.name
        record["userId"] = userId
        record["updatedAt"] = setlist.updatedAt

        // Encode sets as JSON for storage
        do {
            let setsData = try JSONEncoder().encode(setlist.sets)
            record["sets"] = setsData

            let songsData = try JSONEncoder().encode(setlist.extraSongs)
            record["extraSongs"] = songsData

            syncProgress = 0.5
        } catch {
            DispatchQueue.main.async {
                self.syncProgress = 0
                self.syncInProgress = false
                self.syncError = error
            }
            completion(false)
            return
        }

        privateDatabase.save(record) { [weak self] record, error in
            DispatchQueue.main.async {
                self?.syncProgress = 1.0
                self?.syncInProgress = false

                if let error = error {
                    self?.syncError = error
                    completion(false)
                } else {
                    self?.lastSyncDate = Date()
                    UserDefaults.standard.set(Date(), forKey: "lastCloudKitSync")
                    completion(true)
                }
            }
        }
    }

    func syncSong(_ song: Song, userId: String, completion: @escaping (Bool) -> Void) {
        guard isSyncEnabled else {
            completion(false)
            return
        }

        syncInProgress = true
        syncProgress = 0.2

        let record = CKRecord(recordType: "Song")
        record["id"] = song.id
        record["name"] = song.name
        record["userId"] = userId
        record["updatedAt"] = song.updatedAt
        record["capRequired"] = song.capRequired
        record["tempo"] = song.tempo ?? -1

        do {
            let lyricsData = try JSONEncoder().encode(song.lyrics)
            record["lyrics"] = String(data: lyricsData, encoding: .utf8) ?? ""

            let chordsData = try JSONEncoder().encode(song.chords)
            record["chords"] = chordsData

            syncProgress = 0.5
        } catch {
            DispatchQueue.main.async {
                self.syncProgress = 0
                self.syncInProgress = false
                self.syncError = error
            }
            completion(false)
            return
        }

        privateDatabase.save(record) { [weak self] record, error in
            DispatchQueue.main.async {
                self?.syncProgress = 1.0
                self?.syncInProgress = false

                if let error = error {
                    self?.syncError = error
                    completion(false)
                } else {
                    self?.lastSyncDate = Date()
                    UserDefaults.standard.set(Date(), forKey: "lastCloudKitSync")
                    completion(true)
                }
            }
        }
    }

    func fetchAllSetlists(for userId: String, completion: @escaping ([Setlist]?, Error?) -> Void) {
        guard isSyncEnabled else {
            completion(nil, CloudKitError.notAvailable)
            return
        }

        let predicate = NSPredicate(format: "userId == %@", userId)
        let query = CKQuery(recordType: "Setlist", predicate: predicate)

        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }

                var setlists: [Setlist] = []
                for record in records ?? [] {
                    if let setlist = self.parseSetlistRecord(record) {
                        setlists.append(setlist)
                    }
                }

                completion(setlists, nil)
            }
        }
    }

    // MARK: - Preferences

    func enableSync() {
        UserDefaults.standard.set(true, forKey: "cloudKitSyncEnabled")
        isSyncEnabled = true
        checkCloudKitAvailability()
    }

    func disableSync() {
        UserDefaults.standard.set(false, forKey: "cloudKitSyncEnabled")
        isSyncEnabled = false
    }

    private func loadSyncPreferences() {
        let enabled = UserDefaults.standard.bool(forKey: "cloudKitSyncEnabled")
        if let lastSync = UserDefaults.standard.object(forKey: "lastCloudKitSync") as? Date {
            lastSyncDate = lastSync
        }
        isSyncEnabled = enabled
    }

    // MARK: - Parsing

    private func parseSetlistRecord(_ record: CKRecord) -> Setlist? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String else {
            return nil
        }

        var sets: [SetGroup] = []
        if let setsData = record["sets"] as? Data {
            sets = (try? JSONDecoder().decode([SetGroup].self, from: setsData)) ?? []
        }

        var extraSongs: [String] = []
        if let songsData = record["extraSongs"] as? Data {
            extraSongs = (try? JSONDecoder().decode([String].self, from: songsData)) ?? []
        }

        return Setlist(id: id, name: name, sets: sets, extraSongs: extraSongs)
    }

    enum CloudKitError: LocalizedError {
        case notAvailable
        case syncFailed
        case decodingFailed

        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "CloudKit is not available. Check your iCloud settings."
            case .syncFailed:
                return "Failed to sync with CloudKit"
            case .decodingFailed:
                return "Failed to decode data from CloudKit"
            }
        }
    }
}
