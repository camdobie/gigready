import SwiftUI

struct SongDetailView: View {
    let song: Song
    let userId: String
    @StateObject private var viewModel: SongDetailViewModel
    @Environment(\.dismiss) var dismiss

    init(song: Song, userId: String) {
        self.song = song
        self.userId = userId
        _viewModel = StateObject(wrappedValue: SongDetailViewModel(song: song, userId: userId))
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Button(action: { dismiss() }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                            }
                            .foregroundColor(.blue)

                            Spacer()
                        }

                        if viewModel.isEditing {
                            TextField("Song Name", text: $viewModel.song.name)
                                .textFieldStyle(.roundedBorder)
                                .font(.headline)
                        } else {
                            Text(viewModel.song.name)
                                .font(.headline)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Cap Required")
                                Spacer()
                                Toggle("", isOn: $viewModel.song.capRequired)
                            }

                            HStack {
                                Text("Tempo (BPM)")
                                Spacer()
                                if viewModel.isEditing {
                                    TextField("BPM", value: $viewModel.song.tempo, format: .number)
                                        .keyboardType(.numberPad)
                                        .frame(width: 60)
                                        .textFieldStyle(.roundedBorder)
                                } else {
                                    Text(viewModel.song.tempo.map(String.init) ?? "—")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Spacer()

                        HStack {
                            if viewModel.isEditing {
                                Button("Cancel") {
                                    viewModel.discardChanges()
                                }
                                .foregroundColor(.red)

                                Spacer()

                                Button("Save") {
                                    viewModel.saveSong()
                                }
                                .foregroundColor(.blue)
                            } else {
                                Button(action: { viewModel.isEditing = true }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.2)
                    .padding()
                    .background(Color(.systemGray6))

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Lyrics")
                            .font(.headline)
                            .padding()

                        LyricsWithChordsView(
                            song: viewModel.song,
                            isEditing: viewModel.isEditing,
                            onAddChord: { lineIndex, wordIndex in
                                viewModel.selectedChordPosition = SongDetailViewModel.ChordPosition(
                                    lineIndex: lineIndex,
                                    wordIndex: wordIndex
                                )
                            }
                        )
                        .padding()

                        Spacer()
                    }
                }
            }
            .sheet(item: $viewModel.selectedChordPosition) { position in
                ChordSelectorModalView(
                    position: position,
                    onSelectChord: { chordName in
                        viewModel.addChord(chordName, at: position)
                        viewModel.selectedChordPosition = nil
                    }
                )
            }
        }
    }
}

struct LyricsWithChordsView: View {
    let song: Song
    let isEditing: Bool
    let onAddChord: (Int, Int) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(song.lyrics.split(separator: "\n", omittingEmptySubsequences: false).indices, id: \.self) { lineIndex in
                    let line = String(song.lyrics.split(separator: "\n")[lineIndex])
                    VStack(alignment: .leading, spacing: 0) {
                        let words = line.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
                        let chordsForLine = song.chords.filter { $0.lineIndex == lineIndex }

                        HStack(spacing: 2) {
                            ForEach(words.indices, id: \.self) { wordIndex in
                                VStack(alignment: .leading, spacing: 0) {
                                    if let chord = chordsForLine.first(where: { $0.wordIndex == wordIndex }) {
                                        ChordBadgeView(chord: chord, isEditing: isEditing)
                                    }

                                    if isEditing {
                                        HStack(spacing: 2) {
                                            Text(words[wordIndex])
                                            Button(action: {
                                                onAddChord(lineIndex, wordIndex)
                                            }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    } else {
                                        Text(words[wordIndex])
                                    }
                                }
                            }
                            Spacer()
                        }

                        Divider()
                            .padding(.vertical, 4)
                    }
                }
            }
            .font(.system(.body, design: .default))
        }
    }
}

struct ChordBadgeView: View {
    let chord: ChordPlacement
    let isEditing: Bool

    var body: some View {
        Text(chord.chordName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background(Color.orange)
            .cornerRadius(3)
    }
}

struct ChordSelectorModalView: View {
    let position: SongDetailViewModel.ChordPosition
    let onSelectChord: (String) -> Void
    @StateObject private var viewModel = ChordSelectorViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 12) {
                    ForEach(viewModel.getChordCategories(), id: \.category) { category, chords in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category)
                                .font(.headline)
                                .padding(.horizontal)

                            FlowLayout {
                                ForEach(chords, id: \.self) { chord in
                                    Button(action: {
                                        let selected = viewModel.selectChord(chord)
                                        onSelectChord(selected)
                                        dismiss()
                                    }) {
                                        Text(chord)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(4)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Divider()

                    SearchableChordList(viewModel: viewModel, onSelectChord: { chord in
                        onSelectChord(chord)
                        dismiss()
                    })
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Select Chord")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SearchableChordList: View {
    @ObservedObject var viewModel: ChordSelectorViewModel
    let onSelectChord: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SearchBar(text: $viewModel.searchQuery)

            if !viewModel.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Search Results")
                        .font(.headline)

                    FlowLayout {
                        ForEach(viewModel.searchResults, id: \.self) { chord in
                            Button(action: {
                                onSelectChord(chord)
                            }) {
                                Text(chord)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search chords...", text: $text)
                .textFieldStyle(.roundedBorder)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

struct FlowLayout: Layout {
    func sizeThatFits(proposal: ProposedSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var totalSize: CGSize = .zero
        var lineWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if lineWidth + size.width > (proposal.width ?? 0) {
                totalSize.width = max(totalSize.width, lineWidth)
                totalSize.height += size.height + 8
                lineWidth = size.width
            } else {
                lineWidth += size.width + 8
            }
        }

        totalSize.width = max(totalSize.width, lineWidth)
        return totalSize
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += size.height + 8
            }

            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + 8
        }
    }
}

#Preview {
    SongDetailView(song: Song(name: "Test Song", lyrics: "Line 1\nLine 2"), userId: "test-user")
}
