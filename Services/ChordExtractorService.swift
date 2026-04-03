import Foundation

class ChordExtractorService {
    static let shared = ChordExtractorService()

    // Comprehensive regex pattern for chord detection
    // Matches: Am, Am7, Amaj7, A#m, Bbsus4, Cadd9, G/B, etc.
    private let chordPattern = try! NSRegularExpression(
        pattern: #"([A-G](?:b|#)?(?:m|M)?(?:7|9|11|13)?(?:sus|add|maj|min|dim|aug)?(?:\/[A-G](?:b|#)?)?)"#,
        options: [.caseInsensitive]
    )

    func extractChords(from text: String) -> [String] {
        let nsString = text as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let matches = chordPattern.matches(in: text, options: [], range: range)

        return matches.compactMap { match in
            let chordRange = match.range
            guard chordRange.location != NSNotFound else { return nil }
            return nsString.substring(with: chordRange)
        }
    }

    func isValidChord(_ text: String) -> Bool {
        let nsString = text as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let matches = chordPattern.matches(in: text, options: [], range: range)
        return !matches.isEmpty
    }

    func parseChordLine(_ line: String) -> [(chord: String, position: Int)] {
        var chordPositions: [(String, Int)] = []
        let nsString = line as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let matches = chordPattern.matches(in: line, options: [], range: range)

        for match in matches {
            let chordRange = match.range
            let chord = nsString.substring(with: chordRange)
            chordPositions.append((chord, chordRange.location))
        }

        return chordPositions
    }

    // Detect if a line contains chords (heuristics)
    func isChordLine(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        // A chord line typically:
        // 1. Is short (under 60 chars)
        // 2. Contains multiple chord-like patterns
        // 3. Has irregular spacing

        let chords = extractChords(from: line)
        guard chords.count >= 1 else { return false }

        // Check spacing patterns - chords are usually spaced apart
        let positions = parseChordLine(line).map { $0.position }
        if positions.count > 1 {
            let gaps = (1..<positions.count).map { positions[$0] - positions[$0 - 1] }
            let avgGap = gaps.reduce(0, +) / gaps.count
            return avgGap > 3 // Chords are spaced at least 3+ characters apart
        }

        return true
    }

    // Parse a combined chord+lyrics structure
    // Input: alternating chord and lyric lines
    // Output: structured lyrics with chord placements
    func parseChordLyricsBlock(_ text: String) -> (lyrics: String, chords: [(line: Int, word: Int, chord: String)]) {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var lyricsLines: [String] = []
        var extractedChords: [(Int, Int, String)] = []

        var i = 0
        while i < lines.count {
            let currentLine = lines[i]

            if isChordLine(currentLine) {
                // Current line is chords, next line should be lyrics
                let chordPositions = parseChordLine(currentLine)
                if i + 1 < lines.count {
                    let lyricLine = lines[i + 1]
                    let wordCount = lyricLine.split(separator: " ").count
                    let lyricsIndex = lyricsLines.count

                    // Map chord positions to word indices
                    for (chord, charPos) in chordPositions {
                        let wordIndex = estimateWordIndex(charPos, in: lyricLine)
                        extractedChords.append((lyricsIndex, wordIndex, chord))
                    }

                    lyricsLines.append(lyricLine)
                    i += 2
                } else {
                    i += 1
                }
            } else {
                // Regular lyric line
                lyricsLines.append(currentLine)
                i += 1
            }
        }

        let combinedLyrics = lyricsLines.joined(separator: "\n")
        return (combinedLyrics, extractedChords)
    }

    // Estimate which word index corresponds to a character position
    private func estimateWordIndex(_ charPosition: Int, in line: String) -> Int {
        let words = line.split(separator: " ", omittingEmptySubsequences: false).map(String.init)
        var currentPos = 0

        for (index, word) in words.enumerated() {
            let wordEnd = currentPos + word.count
            if charPosition <= wordEnd {
                return index
            }
            currentPos = wordEnd + 1 // +1 for the space
        }

        return max(0, words.count - 1)
    }
}
