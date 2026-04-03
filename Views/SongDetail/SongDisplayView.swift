import SwiftUI

struct SongDisplayView: View {
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
            HStack(spacing: 0) {
                // Left Panel - Song Info
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

                        Button(action: { viewModel.isEditing = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.caption)
                                Text("Edit")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(song.name)
                            .font(.headline)

                        Divider()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Tempo", systemImage: "metronome")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text(song.tempo.map { String($0) } ?? "—")
                                .font(.body)
                        }

                        HStack {
                            Label("Cap", systemImage: "capoeira")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text(song.capRequired ? "Required" : "No")
                                .font(.body)
                                .foregroundColor(song.capRequired ? .orange : .secondary)
                        }

                        HStack {
                            Label("Chords", systemImage: "music.note")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text("\(song.chords.count)")
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                    Spacer()
                }
                .frame(maxWidth: 200)
                .padding()
                .background(Color(.systemGray6))

                // Right Panel - Lyrics
                VStack(spacing: 0) {
                    HStack {
                        Text("Lyrics")
                            .font(.headline)

                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))

                    LyricsRendererView(
                        song: song,
                        isEditing: false,
                        onChordTapped: { _, _ in },
                        onChordDeleted: { _ in }
                    )

                    Spacer()
                }
            }

            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.isEditing) {
                SongEditView(viewModel: viewModel, userId: userId)
            }
        }
    }
}

#Preview {
    let testSong = Song(
        name: "Test Song",
        lyrics: "Am          G\nI'm standing here\nD               A\nThinking about you"
    )
    SongDisplayView(song: testSong, userId: "test-user")
}
