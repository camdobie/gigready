import SwiftUI

struct BackupView: View {
    @StateObject private var viewModel: BackupViewModel
    @StateObject private var cloudKitSync = CloudKitSyncService.shared
    @State private var showExportPicker = false
    @State private var showImportPicker = false

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: BackupViewModel(userId: userId))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // CloudKit Status
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("iCloud Sync", systemImage: "icloud.fill")
                                .font(.headline)

                            Spacer()

                            if cloudKitSync.syncInProgress {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: cloudKitSync.isSyncEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(cloudKitSync.isSyncEnabled ? .green : .red)
                            }
                        }

                        if cloudKitSync.isSyncEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                if let lastSync = cloudKitSync.lastSyncDate {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                            .font(.caption)

                                        Text("Last synced: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.secondary)
                                }

                                Button(action: {
                                    cloudKitSync.syncSetlist(
                                        Setlist(id: UUID().uuidString, name: "Sync"),
                                        userId: viewModel.userId,
                                        completion: { success in
                                            if success {
                                                viewModel.successMessage = "Synced to iCloud"
                                            }
                                        }
                                    )
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Sync Now")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                            }
                        } else {
                            Text("iCloud sync is disabled. Enable it to automatically sync your setlists across devices.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button(action: {
                                cloudKitSync.enableSync()
                            }) {
                                HStack {
                                    Image(systemName: "icloud.and.arrow.up")
                                    Text("Enable iCloud Sync")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    // Manual Backup
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Manual Backup", systemImage: "doc.fill")
                            .font(.headline)

                        Text("Export and import setlists as files for manual backup and sharing")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            Button(action: { showExportPicker = true }) {
                                HStack {
                                    Image(systemName: "arrow.down.doc")
                                    Text("Export")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }

                            Button(action: { showImportPicker = true }) {
                                HStack {
                                    Image(systemName: "arrow.up.doc")
                                    Text("Import")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    // Backup History
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Backup History", systemImage: "list.bullet")
                                .font(.headline)

                            Spacer()

                            if !viewModel.backups.isEmpty {
                                Text("\(viewModel.backups.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }

                        if viewModel.backups.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.badge.plus")
                                    .font(.system(size: 32))
                                    .foregroundColor(.secondary)

                                Text("No backups yet")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        } else {
                            List {
                                ForEach(viewModel.backups) { backup in
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(backup.name)
                                                .font(.headline)

                                            Spacer()

                                            Text(backup.backupType.capitalized)
                                                .font(.caption2)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.orange.opacity(0.1))
                                                .cornerRadius(4)
                                                .foregroundColor(.orange)
                                        }

                                        HStack(spacing: 12) {
                                            Label(backup.backupDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                                                .font(.caption)
                                                .foregroundColor(.secondary)

                                            Label(backup.deviceName, systemImage: "iphone")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .onDelete { offsets in
                                    for index in offsets {
                                        viewModel.deleteBackup(viewModel.backups[index])
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .frame(maxHeight: 300)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    // Messages
                    if let successMessage = viewModel.successMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(successMessage)
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(errorMessage)
                                .font(.caption)
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }

                    Spacer()
                        .frame(height: 1)
                }
                .padding()
            }
            .navigationTitle("Backup & Restore")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BackupView(userId: "test-user")
}
