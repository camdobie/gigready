import Foundation
import Combine

class BackupViewModel: ObservableObject {
    @Published var backups: [BackupInfo] = []
    @Published var isLoading = false
    @Published var lastSyncDate: Date?
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let firebaseService = FirebaseService.shared
    private var userId: String

    init(userId: String) {
        self.userId = userId
        loadBackupHistory()
    }

    // MARK: - Backup Operations

    func createManualBackup(name: String, setlist: Setlist) {
        isLoading = true
        do {
            let backup = BackupInfo(
                name: name,
                backupType: "manual"
            )

            var updatedUser = firebaseService.currentUser ?? AppUser(id: userId)
            updatedUser.backupMetadata.append(backup)

            DispatchQueue.main.async {
                self.isLoading = false
                self.successMessage = "Backup created successfully"
                self.lastSyncDate = Date()
                self.backups.append(backup)
            }
        }
    }

    func exportSetlistAsJSON(_ setlist: Setlist) -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            return try encoder.encode(setlist)
        } catch {
            errorMessage = "Failed to export setlist: \(error.localizedDescription)"
            return nil
        }
    }

    func importSetlistFromJSON(_ data: Data) -> Setlist? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Setlist.self, from: data)
        } catch {
            errorMessage = "Failed to import setlist: \(error.localizedDescription)"
            return nil
        }
    }

    func deleteBackup(_ backup: BackupInfo) {
        if let index = backups.firstIndex(where: { $0.id == backup.id }) {
            backups.remove(at: index)
            successMessage = "Backup deleted"
        }
    }

    // MARK: - CloudKit Sync (Placeholder)

    func enableCloudKitSync() {
        isLoading = true
        // Implementation will be added in Phase 5
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.successMessage = "CloudKit sync enabled"
            self.lastSyncDate = Date()
        }
    }

    func disableCloudKitSync() {
        isLoading = true
        // Implementation will be added in Phase 5
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.successMessage = "CloudKit sync disabled"
        }
    }

    // MARK: - Private Methods

    private func loadBackupHistory() {
        isLoading = true
        if let backupMetadata = firebaseService.currentUser?.backupMetadata {
            self.backups = backupMetadata.sorted { $0.backupDate > $1.backupDate }
        }
        isLoading = false
    }
}
