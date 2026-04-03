import SwiftUI
import PhotosUI

struct ImportView: View {
    @StateObject private var viewModel: ImportViewModel
    @State private var showFilePicker = false
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @Environment(\.dismiss) var dismiss

    let userId: String

    init(userId: String) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: ImportViewModel(userId: userId))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView {
                    // Tab 1: Ultimate Guitar
                    UltimateGuitarTab(viewModel: viewModel)
                        .tabItem {
                            Label("Ultimate Guitar", systemImage: "globe")
                        }

                    // Tab 2: File Import
                    FileImportTab(
                        viewModel: viewModel,
                        showFilePicker: $showFilePicker,
                        showPhotoPicker: $showPhotoPicker
                    )
                    .tabItem {
                        Label("Files", systemImage: "doc.fill")
                    }

                    // Tab 3: Preview & Save
                    if !viewModel.importedSongs.isEmpty {
                        ImportPreviewTab(viewModel: viewModel, onDismiss: { dismiss() })
                            .tabItem {
                                Label("Preview", systemImage: "checkmark.circle")
                            }
                    }
                }
                .padding()

                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                        Text(errorMessage)
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                }

                if let successMessage = viewModel.successMessage {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text(successMessage)
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.1))
                }
            }
            .navigationTitle("Import Songs")
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.pdf, .plainText],
                allowsMultipleSelection: true,
                onCompletion: { result in
                    switch result {
                    case .success(let urls):
                        viewModel.importFiles(urls)
                    case .failure(let error):
                        viewModel.errorMessage = error.localizedDescription
                    }
                }
            )
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhotoItems,
                maxSelectionCount: 10,
                matching: .images
            )
            .onChange(of: selectedPhotoItems) { newItems in
                Task {
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                let tempURL = FileManager.default.temporaryDirectory
                                    .appendingPathComponent(UUID().uuidString)
                                    .appendingPathExtension("jpg")
                                try? image.jpegData(compressionQuality: 0.8)?.write(to: tempURL)
                                viewModel.importFile(tempURL)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Tab Views

struct UltimateGuitarTab: View {
    @ObservedObject var viewModel: ImportViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                TextField("Song or artist name...", text: $viewModel.ugSearchQuery)
                    .textFieldStyle(.roundedBorder)

                Button(action: { viewModel.searchUltimateGuitar() }) {
                    Image(systemName: "magnifyingglass")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }

            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.ugSearchResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)

                    Text("Search Ultimate Guitar")
                        .font(.headline)

                    Text("Enter a song title or artist name to find tabs with chords")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(viewModel.ugSearchResults) { tab in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tab.songName)
                                        .font(.headline)
                                        .lineLimit(1)

                                    Text(tab.artistName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                if let rating = tab.rating {
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                        Text(String(format: "%.1f", rating))
                                            .font(.caption)
                                    }
                                }
                            }

                            HStack(spacing: 8) {
                                Button(action: { viewModel.importFromUltimateGuitar(tabId: tab.id) }) {
                                    HStack {
                                        Image(systemName: "arrow.down.circle")
                                        Text("Import")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color.blue)
                                    .cornerRadius(4)
                                }

                                Spacer()

                                Link(destination: URL(string: tab.url) ?? URL(fileURLWithPath: "")) {
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }

            Spacer()
        }
    }
}

struct FileImportTab: View {
    @ObservedObject var viewModel: ImportViewModel
    @Binding var showFilePicker: Bool
    @Binding var showPhotoPicker: Bool

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Button(action: { showFilePicker = true }) {
                    HStack {
                        Image(systemName: "doc.fill")
                        Text("Choose PDF or Text File")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Button(action: { showPhotoPicker = true }) {
                    HStack {
                        Image(systemName: "photo.fill")
                        Text("Take Photo (OCR)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Text("Supports PDF, Word, TXT, PNG, JPG")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else if !viewModel.importedSongs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Imported Songs (\(viewModel.importedSongs.count))")
                        .font(.headline)

                    List {
                        ForEach(viewModel.importedSongs) { importedSong in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(importedSong.song.name)
                                    .font(.headline)

                                HStack(spacing: 12) {
                                    Label("\(importedSong.lineCount) lines", systemImage: "lines.measurement.vertical")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    Label("\(importedSong.chordCount) chords", systemImage: "music.note")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Text(importedSong.source.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)

                    Text("Import Your Files")
                        .font(.headline)

                    Text("Upload PDFs, Word documents, or photos with lyrics and chords")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
    }
}

struct ImportPreviewTab: View {
    @ObservedObject var viewModel: ImportViewModel
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("\(viewModel.importedSongs.count) song(s) ready to import")
                .font(.headline)

            List {
                ForEach(viewModel.importedSongs) { importedSong in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(importedSong.song.name)
                            .font(.headline)

                        HStack(spacing: 12) {
                            Label("\(importedSong.lineCount) lines", systemImage: "lines.measurement.vertical")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Label("\(importedSong.chordCount) chords", systemImage: "music.note")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if !importedSong.song.lyrics.isEmpty {
                            Text(importedSong.song.lyrics.prefix(100))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        viewModel.removeSong(viewModel.importedSongs[index])
                    }
                }
            }
            .listStyle(.plain)

            HStack(spacing: 12) {
                Button(action: { viewModel.clearAll() }) {
                    Text("Clear")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray4))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }

                Button(action: { onDismiss() }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Save Songs")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ImportView(userId: "test-user")
}
