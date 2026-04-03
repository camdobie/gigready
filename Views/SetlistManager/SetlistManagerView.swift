import SwiftUI

struct SetlistManagerView: View {
    let setlistId: String
    let userId: String
    @StateObject private var viewModel: SetlistViewModel?
    @State private var setlist: Setlist?
    @State private var songs: [String: Song] = [:]
    @State private var isLoading = true
    @State private var showImport = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else if let setlist = setlist, let viewModel = viewModel {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                        .foregroundColor(.blue)

                        Spacer()

                        Text(setlist.name)
                            .font(.headline)

                        Spacer()

                        Menu {
                            Section("View") {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Button {
                                        withAnimation {
                                            viewModel.sortOption = option
                                        }
                                    } label: {
                                        HStack {
                                            Text(option.rawValue)
                                            if viewModel.sortOption == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }

                            Section("Actions") {
                                Button(action: { showImport = true }) {
                                    Label("Import Songs", systemImage: "arrow.down.doc")
                                }

                                Button(action: { viewModel.createNewSet() }) {
                                    Label("Add Set", systemImage: "plus")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(setlist.sets.indices, id: \.self) { index in
                                SetColumnView(
                                    set: setlist.sets[index],
                                    songs: songs,
                                    viewModel: viewModel,
                                    setIndex: index,
                                    userId: userId
                                )
                                .frame(minWidth: 280, maxWidth: 320)
                            }

                            VStack(spacing: 12) {
                                Button(action: { viewModel.createNewSet() }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.blue)

                                        Text("Add Set")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 100)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }

                                Spacer()
                            }
                            .frame(minWidth: 280, maxWidth: 320)
                        }
                        .padding()
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Extra Songs")
                                .font(.headline)

                            Spacer()

                            Text("(\(viewModel.getExtraSongsAlphabetical().count))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        ExtraSongsDropdownView(
                            extraSongIds: viewModel.getExtraSongsAlphabetical(),
                            songs: songs,
                            viewModel: viewModel
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)

                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadSetlist()
        }
        .sheet(isPresented: $showImport) {
            ImportView(userId: userId)
        }
    }

    private func loadSetlist() {
        let firebaseService = FirebaseService.shared
        firebaseService.loadSetlist(for: userId, setlistId: setlistId) { loadedSetlist in
            DispatchQueue.main.async {
                self.setlist = loadedSetlist ?? Setlist(id: setlistId, name: "Setlist")
                if let setlist = self.setlist {
                    let viewModel = SetlistViewModel(setlist: setlist, userId: userId)
                    self._viewModel = StateObject(wrappedValue: viewModel)
                    self.songs = viewModel.songs
                }
                isLoading = false
            }
        }
    }
}

struct SetColumnView: View {
    let set: SetGroup
    let songs: [String: Song]
    let viewModel: SetlistViewModel
    let setIndex: Int
    let userId: String
    @State private var draggedSongId: String?
    @State private var isDropTarget = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(set.name)
                    .font(.headline)

                Spacer()

                Text("\(viewModel.getSortedSongIds(for: setIndex).count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)

                Menu {
                    Button(role: .destructive) {
                        viewModel.deleteSet(setIndex)
                    } label: {
                        Label("Delete Set", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color(.systemGray6))

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 8) {
                    ForEach(viewModel.getSortedSongIds(for: setIndex), id: \.self) { songId in
                        if let song = songs[songId] {
                            NavigationLink(destination: SongDetailView(song: song, userId: userId)) {
                                SongCellView(song: song, onDelete: {
                                    viewModel.removeSongFromSet(songId, setIndex: setIndex)
                                })
                            }
                            .draggable(songId)
                        }
                    }

                    VStack {
                        HStack {
                            Image(systemName: "arrow.down")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("Drop here to add")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            isDropTarget
                                ? Color.blue.opacity(0.2)
                                : Color(.systemGray5)
                        )
                        .cornerRadius(6)
                        .onDrop(of: [.text], isTargeted: $isDropTarget) { providers in
                            if let provider = providers.first {
                                let _ = provider.loadObject(ofClass: String.self) { draggedId, _ in
                                    if let draggedId = draggedId {
                                        DispatchQueue.main.async {
                                            if viewModel.setlist.extraSongs.contains(draggedId) {
                                                viewModel.addSongToSet(draggedId, setIndex: setIndex)
                                                viewModel.removeSongFromExtraSongs(draggedId)
                                            }
                                        }
                                    }
                                }
                            }
                            return true
                        }
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: .infinity)
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct SongCellView: View {
    let song: Song
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(song.name)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    if let tempo = song.tempo {
                        HStack(spacing: 3) {
                            Image(systemName: "metronome")
                                .font(.caption)
                            Text("\(tempo)")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }

                    if song.capRequired {
                        HStack(spacing: 3) {
                            Image(systemName: "capoeira")
                                .font(.caption)
                            Text("Cap")
                                .font(.caption2)
                        }
                        .foregroundColor(.orange)
                    }

                    Spacer()
                }
            }

            Menu {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(10)
        .background(Color.blue.opacity(0.08))
        .cornerRadius(6)
    }
}

struct ExtraSongsDropdownView: View {
    let extraSongIds: [String]
    let songs: [String: Song]
    let viewModel: SetlistViewModel
    @State private var isExpanded = false
    @State private var searchText = ""

    var filteredSongs: [String] {
        let filtered = extraSongIds.filter { songId in
            if searchText.isEmpty {
                return true
            }
            return songs[songId]?.name.localizedCaseInsensitiveContains(searchText) ?? false
        }
        return filtered
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack(spacing: 12) {
                    Image(systemName: "music.note.list")
                        .font(.headline)
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Extra Songs")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text("\(extraSongIds.count) available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(12)
                .background(Color(.systemGray6))
            }

            if isExpanded {
                Divider()

                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.caption)

                        TextField("Search songs...", text: $searchText)
                            .font(.caption)
                    }
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
                    .padding(12)

                    // Songs list
                    if filteredSongs.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "music.note")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)

                            Text(searchText.isEmpty ? "No extra songs" : "No matches")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                    } else {
                        ScrollView(.vertical, showsIndicators: true) {
                            VStack(spacing: 6) {
                                ForEach(filteredSongs, id: \.self) { songId in
                                    if let song = songs[songId] {
                                        ExtraSongCell(
                                            song: song,
                                            viewModel: viewModel,
                                            songId: songId
                                        )
                                        .draggable(songId)
                                    }
                                }
                            }
                            .padding(12)
                        }
                        .frame(maxHeight: 250)
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ExtraSongCell: View {
    let song: Song
    let viewModel: SetlistViewModel
    let songId: String
    @State private var selectedSet: Int?

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(song.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let tempo = song.tempo {
                        Label("\(tempo)", systemImage: "metronome")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    if song.capRequired {
                        Label("Cap", systemImage: "capoeira")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            Menu {
                Button(role: .destructive) {
                    viewModel.removeSongFromExtraSongs(songId)
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(8)
        .background(Color.blue.opacity(0.06))
        .cornerRadius(6)
    }
}

#Preview {
    SetlistManagerView(setlistId: "test-setlist", userId: "test-user")
}
