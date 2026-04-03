import SwiftUI

struct BackupView: View {
    @StateObject private var viewModel: BackupViewModel
    @State private var showExportPicker = false
    @State private var showImportPicker = false
    @State private var showManualBackupSheet = false

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: BackupViewModel(userId: userId))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cloud Backup")
                        .font(.headline)

                    if let lastSync = viewModel.lastSyncDate {
                        HStack {
                            Image(systemName: "cloud.fill")
                            Text("Last synced: \(lastSync, style: .date) \(lastSync, style: .time)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: {
                        viewModel.enableCloudKitSync()
                    }) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.up")
                            Text("Enable CloudKit Sync")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Manual Backup")
                        .font(.headline)

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

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Backup History")
                            .font(.headline)

                        Spacer()

                        if !viewModel.backups.isEmpty {
                            Text("\(viewModel.backups.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if viewModel.backups.isEmpty {
                        Text("No backups yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        List {
                            ForEach(viewModel.backups) { backup in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(backup.name)
                                            .font(.headline)

                                        Spacer()

                                        Text(backup.backupType.capitalized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Text("\(backup.backupDate, style: .date) \(backup.backupDate, style: .time)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Text(backup.deviceName)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
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

                Spacer()

                if let successMessage = viewModel.successMessage {
                    Text(successMessage)
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Backup & Restore")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BackupView(userId: "test-user")
}
