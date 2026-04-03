import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Combine

class FirebaseService: NSObject, ObservableObject {
    static let shared = FirebaseService()

    @Published var isAuthenticated = false
    @Published var currentUser: AppUser?
    @Published var errorMessage: String?

    private var dbRef: DatabaseReference?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        dbRef = Database.database().reference()
        setupAuthObserver()
    }

    private func setupAuthObserver() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                self?.isAuthenticated = true
                self?.loadUserData(userId: user.uid)
            } else {
                self?.isAuthenticated = false
                self?.currentUser = nil
            }
        }
    }

    // MARK: - Authentication

    func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error = error {
                self?.errorMessage = "Authentication failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - User Data

    func loadUserData(userId: String) {
        guard let dbRef = dbRef else { return }

        dbRef.child("users").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            if snapshot.exists() {
                if let userData = try? snapshot.data(as: AppUser.self) {
                    self?.currentUser = userData
                }
            } else {
                let newUser = AppUser(id: userId)
                self?.saveUser(newUser)
            }
        }
    }

    private func saveUser(_ user: AppUser) {
        guard let dbRef = dbRef else { return }

        do {
            let encodedUser = try JSONEncoder().encode(user)
            let userDict = try JSONSerialization.jsonObject(with: encodedUser) as? [String: Any]
            dbRef.child("users").child(user.id).setValue(userDict) { [weak self] error, _ in
                if let error = error {
                    self?.errorMessage = "Failed to save user: \(error.localizedDescription)"
                }
            }
        } catch {
            errorMessage = "Failed to encode user: \(error.localizedDescription)"
        }
    }

    // MARK: - Songs

    func saveSong(_ song: Song, for userId: String) {
        guard let dbRef = dbRef else { return }

        do {
            let encodedSong = try JSONEncoder().encode(song)
            let songDict = try JSONSerialization.jsonObject(with: encodedSong) as? [String: Any]
            dbRef.child("users").child(userId).child("songs").child(song.id).setValue(songDict) { [weak self] error, _ in
                if let error = error {
                    self?.errorMessage = "Failed to save song: \(error.localizedDescription)"
                }
            }
        } catch {
            errorMessage = "Failed to encode song: \(error.localizedDescription)"
        }
    }

    func loadSongs(for userId: String, completion: @escaping ([Song]) -> Void) {
        guard let dbRef = dbRef else { return }

        dbRef.child("users").child(userId).child("songs").observeSingleEvent(of: .value) { snapshot in
            var songs: [Song] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let data = try? snapshot.data(as: Song.self) {
                    songs.append(data)
                }
            }
            completion(songs)
        }
    }

    func deleteSong(_ songId: String, for userId: String) {
        guard let dbRef = dbRef else { return }

        dbRef.child("users").child(userId).child("songs").child(songId).removeValue { [weak self] error, _ in
            if let error = error {
                self?.errorMessage = "Failed to delete song: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Venues

    func saveVenue(_ venue: Venue, for userId: String) {
        guard let dbRef = dbRef else { return }

        do {
            let encodedVenue = try JSONEncoder().encode(venue)
            let venueDict = try JSONSerialization.jsonObject(with: encodedVenue) as? [String: Any]
            dbRef.child("users").child(userId).child("venues").child(venue.id).setValue(venueDict) { [weak self] error, _ in
                if let error = error {
                    self?.errorMessage = "Failed to save venue: \(error.localizedDescription)"
                }
            }
        } catch {
            errorMessage = "Failed to encode venue: \(error.localizedDescription)"
        }
    }

    func loadVenues(for userId: String, completion: @escaping ([Venue]) -> Void) {
        guard let dbRef = dbRef else { return }

        dbRef.child("users").child(userId).child("venues").observeSingleEvent(of: .value) { snapshot in
            var venues: [Venue] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let data = try? snapshot.data(as: Venue.self) {
                    venues.append(data)
                }
            }
            completion(venues)
        }
    }

    func deleteVenue(_ venueId: String, for userId: String) {
        guard let dbRef = dbRef else { return }

        dbRef.child("users").child(userId).child("venues").child(venueId).removeValue { [weak self] error, _ in
            if let error = error {
                self?.errorMessage = "Failed to delete venue: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Setlists

    func saveSetlist(_ setlist: Setlist, for userId: String) {
        guard let dbRef = dbRef else { return }

        do {
            let encodedSetlist = try JSONEncoder().encode(setlist)
            let setlistDict = try JSONSerialization.jsonObject(with: encodedSetlist) as? [String: Any]
            dbRef.child("users").child(userId).child("setlists").child(setlist.id).setValue(setlistDict) { [weak self] error, _ in
                if let error = error {
                    self?.errorMessage = "Failed to save setlist: \(error.localizedDescription)"
                }
            }
        } catch {
            errorMessage = "Failed to encode setlist: \(error.localizedDescription)"
        }
    }

    func loadSetlist(for userId: String, setlistId: String, completion: @escaping (Setlist?) -> Void) {
        guard let dbRef = dbRef else { return }

        dbRef.child("users").child(userId).child("setlists").child(setlistId).observeSingleEvent(of: .value) { snapshot in
            if let data = try? snapshot.data(as: Setlist.self) {
                completion(data)
            } else {
                completion(nil)
            }
        }
    }

    func deleteSetlist(_ setlistId: String, for userId: String) {
        guard let dbRef = dbRef else { return }

        dbRef.child("users").child(userId).child("setlists").child(setlistId).removeValue { [weak self] error, _ in
            if let error = error {
                self?.errorMessage = "Failed to delete setlist: \(error.localizedDescription)"
            }
        }
    }
}
