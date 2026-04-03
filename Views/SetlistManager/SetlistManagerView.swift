import SwiftUI

struct SetlistManagerView: View {
    let setlistId: String
    let userId: String
    @StateObject private var viewModel: SetlistViewModel?
    @State private var setlist: Setlist?
    @State private var songs: [String: Song] = [:]
    @State private var isLoading = true
    @State private var showAddSong = false

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else if let setlist = setlist, let viewModel = viewModel {
                VStack {
                    HStack {
                        Button(action: { /* Navigate back */ }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                        .foregroundColor(.blue)

                        Spacer()

                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(option.rawValue) {
                                    viewModel.sortOption = option
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }
                    .padding()

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
                                .frame(maxWidth: 300)
                            }

                            Button(action: {
                                viewModel.createNewSet()
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.blue)

                                    Text("Add Set")
                                        .font(.caption)
                                }
                                .frame(maxWidth: 300)
                                .frame(minHeight: 100)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Extra Songs")
                                .font(.headline)

                            Spacer()

                            Button(action: { showAddSong = true }) {
                                Image(systemName: "plus.circle")
                            }
                        }
                        .padding(.horizontal)

                        ExtraSongsDropdownView(
                            songs: viewModel.getExtraSongsAlphabetical().compactMap { songs[$0] },
                            onAddToSet: { songId, setIndex in
                                viewModel.addSongToSet(songId, setIndex: setIndex)
                            }
                        )
                        .padding(.horizontal)
                    }

                    Spacer()
                }
            }
        }
        .onAppear {
            loadSetlist()
        }
        .sheet(isPresented: $showAddSong) {
            Text("Add Song Sheet")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(set.name)
                    .font(.headline)

                Spacer()

                Button(action: {
                    viewModel.deleteSet(setIndex)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }

            VStack(spacing: 8) {
                ForEach(viewModel.getSortedSongIds(for: setIndex), id: \.self) { songId in
                    if let song = songs[songId] {
                        NavigationLink(destination: SongDetailView(song: song, userId: userId)) {
                            SongCellView(song: song)
                        }
                        .draggable(songId)
                    }
                }

                Color.clear
                    .frame(height: 40)
                    .onDrop(of: [.text], isTargeted: nil) { providers in
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
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .border(Color.gray.opacity(0.2))
    }
}

struct SongCellView: View {
    let song: Song

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(song.name)
                .font(.headline)
                .lineLimit(1)

            if let tempo = song.tempo {
                HStack(spacing: 4) {
                    Image(systemName: "metronome")
                        .font(.caption)
                    Text("\(tempo) BPM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if song.capRequired {
                HStack(spacing: 4) {
                    Image(systemName: "capoeira")
                        .font(.caption)
                    Text("Cap Required")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(6)
    }
}

struct ExtraSongsDropdownView: View {
    let songs: [Song]
    let onAddToSet: (String, Int) -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Extra Songs (\(songs.count))")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 0 : -90))
            }
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }

            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(songs) { song in
                        HStack {
                            Text(song.name)
                                .lineLimit(1)

                            Spacer()

                            Menu {
                                ForEach(0..<4, id: \.self) { setIndex in
                                    Button("Add to Set \(setIndex + 1)") {
                                        onAddToSet(song.id, setIndex)
                                    }
                                }
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

#Preview {
    SetlistManagerView(setlistId: "test-setlist", userId: "test-user")
}
