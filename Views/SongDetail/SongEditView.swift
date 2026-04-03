import SwiftUI

struct SongEditView: View {
    @ObservedObject var viewModel: SongDetailViewModel
    let userId: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        viewModel.discardChanges()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .foregroundColor(.blue)

                    Spacer()

                    if viewModel.isEditing {
                        Button(action: {
                            viewModel.saveSong()
                            dismiss()
                        }) {
                            Text("Done")
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))

                // Content
                HStack(spacing: 0) {
                    // Left Panel - Metadata
                    VStack(alignment: .leading, spacing: 16) {
                        Button(action: { viewModel.isEditing.toggle() }) {
                            HStack(spacing: 8) {
                                Image(systemName: viewModel.isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                    .font(.system(size: 20))

                                Text(viewModel.isEditing ? "Editing" : "Edit Song")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Spacer()
                            }
                            .padding(12)
                            .background(viewModel.isEditing ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .foregroundColor(.primary)

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Song Name", systemImage: "music.note")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            if viewModel.isEditing {
                                TextField("Song name", text: $viewModel.song.name)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                Text(viewModel.song.name)
                                    .font(.headline)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Tempo (BPM)", systemImage: "metronome")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            if viewModel.isEditing {
                                TextField("BPM", value: $viewModel.song.tempo, format: .number)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                Text(viewModel.song.tempo.map { String($0) } ?? "—")
                                    .font(.body)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Cap Required", systemImage: "capoeira")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)

                                Spacer()

                                if viewModel.isEditing {
                                    Toggle("", isOn: $viewModel.song.capRequired)
                                } else {
                                    Text(viewModel.song.capRequired ? "Yes" : "No")
                                        .font(.body)
                                        .foregroundColor(viewModel.song.capRequired ? .orange : .secondary)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Chords", systemImage: "music.note")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            Text("\(viewModel.song.chords.count) chords")
                                .font(.body)
                                .foregroundColor(.blue)
                        }

                        Divider()

                        if viewModel.isEditing {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Edit Lyrics", systemImage: "doc.text.fill")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)

                                TextEditor(text: $viewModel.song.lyrics)
                                    .font(.system(.caption, design: .monospaced))
                                    .frame(minHeight: 150)
                                    .border(Color.gray.opacity(0.3))
                                    .cornerRadius(6)
                            }
                        }

                        Spacer()
                    }
                    .frame(maxWidth: 240)
                    .padding()
                    .background(Color(.systemGray6))

                    // Right Panel - Lyrics with Chords
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Lyrics & Chords")
                                .font(.headline)

                            Spacer()

                            Text(viewModel.isEditing ? "Tap words to add chords" : "")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))

                        LyricsRendererView(
                            song: viewModel.song,
                            isEditing: viewModel.isEditing,
                            onChordTapped: { lineIndex, wordIndex in
                                viewModel.selectedChordPosition = SongDetailViewModel.ChordPosition(
                                    lineIndex: lineIndex,
                                    wordIndex: wordIndex
                                )
                            },
                            onChordDeleted: { chordId in
                                viewModel.deleteChord(chordId)
                            }
                        )

                        Spacer()
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .sheet(item: $viewModel.selectedChordPosition) { position in
                ChordSelectorSheetView(
                    position: position,
                    viewModel: viewModel,
                    onSelectChord: { chordName in
                        viewModel.addChord(chordName, at: position)
                        viewModel.selectedChordPosition = nil
                    }
                )
            }
        }
    }
}

struct ChordSelectorSheetView: View {
    let position: SongDetailViewModel.ChordPosition
    @ObservedObject var viewModel: SongDetailViewModel
    let onSelectChord: (String) -> Void
    @StateObject private var chordVM = ChordSelectorViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Main Chords")
                        .font(.headline)
                        .padding(.horizontal)

                    FlowLayout {
                        ForEach(chordVM.basicChords, id: \.self) { chord in
                            ChordButtonView(chord: chord, action: {
                                let selected = chordVM.selectChord(chord)
                                onSelectChord(selected)
                                dismiss()
                            })
                        }
                    }
                    .padding(.horizontal)
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Search")
                            .font(.headline)

                        Spacer()
                    }
                    .padding(.horizontal)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search chords...", text: $chordVM.searchQuery)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                    .padding(.horizontal)

                    if !chordVM.searchResults.isEmpty {
                        FlowLayout {
                            ForEach(chordVM.searchResults, id: \.self) { chord in
                                ChordButtonView(chord: chord, action: {
                                    onSelectChord(chord)
                                    dismiss()
                                })
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.vertical)
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

struct ChordButtonView: View {
    let chord: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(chord)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(4)
        }
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
    let testSong = Song(name: "Test Song", lyrics: "Line 1\nLine 2")
    let viewModel = SongDetailViewModel(song: testSong, userId: "test-user")
    SongEditView(viewModel: viewModel, userId: "test-user")
}
