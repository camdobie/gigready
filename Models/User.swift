import Foundation

struct AppUser: Identifiable, Codable {
    let id: String
    var email: String?
    var displayName: String?
    var venues: [String]
    var songs: [String]
    var backupMetadata: [BackupInfo]
    var createdAt: Date
    var updatedAt: Date

    init(id: String,
         email: String? = nil,
         displayName: String? = nil,
         venues: [String] = [],
         songs: [String] = [],
         backupMetadata: [BackupInfo] = [],
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.venues = venues
        self.songs = songs
        self.backupMetadata = backupMetadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct BackupInfo: Codable {
    let id: String
    var name: String
    var backupDate: Date
    var deviceName: String
    var backupType: String

    init(id: String = UUID().uuidString,
         name: String,
         backupDate: Date = Date(),
         deviceName: String = UIDevice.current.name,
         backupType: String = "manual") {
        self.id = id
        self.name = name
        self.backupDate = backupDate
        self.deviceName = deviceName
        self.backupType = backupType
    }
}
