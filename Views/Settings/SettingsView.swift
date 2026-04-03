import SwiftUI

struct SettingsView: View {
    let userId: String
    @StateObject private var cloudKitSync = CloudKitSyncService.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    HStack {
                        Text("User ID")
                        Spacer()
                        Text(userId)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Section("Sync & Backup") {
                    NavigationLink(destination: BackupView(userId: userId)) {
                        HStack {
                            Label("Backup & Restore", systemImage: "arrow.triangle.2.circlepath")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }

                    Toggle(isOn: $cloudKitSync.isSyncEnabled) {
                        Label("iCloud Sync", systemImage: "icloud.fill")
                    }
                    .onChange(of: cloudKitSync.isSyncEnabled) { newValue in
                        if newValue {
                            cloudKitSync.enableSync()
                        } else {
                            cloudKitSync.disableSync()
                        }
                    }

                    if let lastSync = cloudKitSync.lastSyncDate {
                        HStack {
                            Label("Last Sync", systemImage: "clock")
                            Spacer()
                            Text(lastSync.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("Display") {
                    HStack {
                        Label("Theme", systemImage: "paintpalette")
                        Spacer()
                        Text("Light")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Text Size", systemImage: "textformat")
                        Spacer()
                        Text("Default")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("About") {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("GigReady")
                            .font(.caption)
                            .fontWeight(.semibold)

                        Text("Professional setlist and lyrics manager for musicians")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    SettingsView(userId: "test-user")
}
