import SwiftUI

struct LyricsRendererView: View {
    let song: Song
    let isEditing: Bool
    let onChordTapped: (Int, Int) -> Void
    let onChordDeleted: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                let lines = song.lyrics.split(separator: "\n", omittingEmptySubsequences: false)

                ForEach(Array(lines.enumerated()), id: \.offset) { lineIndex, line in
                    LyricLineView(
                        lineIndex: lineIndex,
                        text: String(line),
                        song: song,
                        isEditing: isEditing,
                        onChordTapped: onChordTapped,
                        onChordDeleted: onChordDeleted
                    )
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct LyricLineView: View {
    let lineIndex: Int
    let text: String
    let song: Song
    let isEditing: Bool
    let onChordTapped: (Int, Int) -> Void
    let onChordDeleted: (String) -> Void

    var chordsOnThisLine: [ChordPlacement] {
        song.chords.filter { $0.lineIndex == lineIndex }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Chord line
            if !chordsOnThisLine.isEmpty {
                HStack(spacing: 2) {
                    let words = text.split(separator: " ", omittingEmptySubsequences: false).map(String.init)

                    ForEach(Array(words.enumerated()), id: \.offset) { wordIndex, _ in
                        VStack(alignment: .leading, spacing: 0) {
                            let wordChords = chordsOnThisLine.filter { $0.wordIndex == wordIndex }

                            if !wordChords.isEmpty {
                                HStack(spacing: 2) {
                                    ForEach(wordChords) { chord in
                                        ChordDisplayBadge(
                                            chord: chord,
                                            isEditing: isEditing,
                                            onDelete: { onChordDeleted(chord.id) }
                                        )
                                    }
                                }
                            }

                            Spacer()
                                .frame(height: 4)
                        }
                    }

                    Spacer()
                }
                .font(.caption2)
                .lineLimit(1)
            }

            // Lyric line
            HStack(spacing: 0) {
                let words = text.split(separator: " ", omittingEmptySubsequences: false).map(String.init)

                ForEach(Array(words.enumerated()), id: \.offset) { wordIndex, word in
                    HStack(spacing: 0) {
                        if isEditing && !chordsOnThisLine.filter({ $0.wordIndex == wordIndex }).isEmpty {
                            Button(action: { onChordTapped(lineIndex, wordIndex) }) {
                                HStack(spacing: 1) {
                                    Text(word)
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                            }
                            .foregroundColor(.primary)
                        } else if isEditing {
                            Button(action: { onChordTapped(lineIndex, wordIndex) }) {
                                HStack(spacing: 2) {
                                    Text(word)
                                    Image(systemName: "plus.circle")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                        .opacity(0.3)
                                }
                            }
                            .foregroundColor(.primary)
                        } else {
                            Text(word)
                        }

                        if wordIndex < words.count - 1 {
                            Text(" ")
                        }
                    }
                }

                Spacer()
            }
            .font(.body)
            .lineLimit(nil)
        }
        .padding(.vertical, 4)
    }
}

struct ChordDisplayBadge: View {
    let chord: ChordPlacement
    let isEditing: Bool
    let onDelete: () -> Void

    var body: some View {
        if isEditing {
            Menu {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Text(chord.chordName)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(Color.orange)
                    .cornerRadius(3)
            }
        } else {
            Text(chord.chordName)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.vertical, 2)
                .padding(.horizontal, 6)
                .background(Color.orange)
                .cornerRadius(3)
        }
    }
}

#Preview {
    let testSong = Song(
        name: "Test Song",
        lyrics: "Am          G\nI'm standing here\nD               A\nThinking about you"
    )

    LyricsRendererView(
        song: testSong,
        isEditing: false,
        onChordTapped: { _, _ in },
        onChordDeleted: { _ in }
    )
}
