import Foundation
import UIKit

class FileImportService {
    static let shared = FileImportService()

    private let chordExtractor = ChordExtractorService.shared
    private let pdfParser = PDFParsingService.shared
    private let wordParser = WordDocumentParsingService.shared
    private let ocrService = OCRService.shared

    // MARK: - Main Import Method

    func importFiles(_ urls: [URL], completion: @escaping ([ImportedSong]?, Error?) -> Void) {
        var importedSongs: [ImportedSong] = []
        let group = DispatchGroup()

        for url in urls {
            group.enter()
            importFile(url) { song, error in
                if let song = song {
                    importedSongs.append(song)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(importedSongs, nil)
        }
    }

    func importFile(_ url: URL, completion: @escaping (ImportedSong?, Error?) -> Void) {
        let fileExtension = url.pathExtension.lowercased()

        switch fileExtension {
        case "pdf":
            importPDF(url, completion: completion)
        case "docx", "doc":
            importWord(url, completion: completion)
        case "txt":
            importText(url, completion: completion)
        case "png", "jpg", "jpeg", "gif":
            importImage(url, completion: completion)
        default:
            completion(nil, ImportError.unsupportedFileType)
        }
    }

    // MARK: - PDF Import

    private func importPDF(_ url: URL, completion: @escaping (ImportedSong?, Error?) -> Void) {
        pdfParser.extractTextFromPDF(url: url) { [weak self] text, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let text = text else {
                completion(nil, ImportError.noContentExtracted)
                return
            }

            let metadata = self?.pdfParser.extractMetadata(from: url)
            let song = self?.createSongFromText(text, source: .pdf, fileName: url.lastPathComponent, metadata: metadata)
            completion(song, nil)
        }
    }

    // MARK: - Word Document Import

    private func importWord(_ url: URL, completion: @escaping (ImportedSong?, Error?) -> Void) {
        wordParser.extractTextFromWordDocument(url: url) { [weak self] text, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let text = text else {
                completion(nil, ImportError.noContentExtracted)
                return
            }

            let song = self?.createSongFromText(text, source: .word, fileName: url.lastPathComponent)
            completion(song, nil)
        }
    }

    // MARK: - Text File Import

    private func importText(_ url: URL, completion: @escaping (ImportedSong?, Error?) -> Void) {
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            let song = createSongFromText(text, source: .text, fileName: url.lastPathComponent)
            completion(song, nil)
        } catch {
            completion(nil, error)
        }
    }

    // MARK: - Image Import (OCR)

    private func importImage(_ url: URL, completion: @escaping (ImportedSong?, Error?) -> Void) {
        guard let image = UIImage(contentsOfFile: url.path) else {
            completion(nil, ImportError.invalidImage)
            return
        }

        ocrService.extractTextFromImage(image) { [weak self] text, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let text = text else {
                completion(nil, ImportError.noContentExtracted)
                return
            }

            let song = self?.createSongFromText(text, source: .image, fileName: url.lastPathComponent)
            completion(song, nil)
        }
    }

    // MARK: - Song Creation from Text

    private func createSongFromText(
        _ text: String,
        source: ImportSource,
        fileName: String,
        metadata: PDFParsingService.PDFMetadata? = nil
    ) -> ImportedSong {
        let (lyrics, chords) = chordExtractor.parseChordLyricsBlock(text)

        // Extract title from metadata or filename
        let title = metadata?.title ?? fileName.replacingOccurrences(of: ".\(fileName.split(separator: ".").last ?? "")", with: "")

        // Create ChordPlacement objects from extracted chords
        let chordPlacements = chords.map { line, word, chordName in
            ChordPlacement(
                chordName: chordName,
                lineIndex: line,
                wordIndex: word
            )
        }

        let song = Song(
            name: title,
            lyrics: lyrics,
            chords: chordPlacements,
            tempo: 120, // Default tempo
            capRequired: false
        )

        return ImportedSong(
            song: song,
            source: source,
            sourceFileName: fileName,
            chordCount: chordPlacements.count,
            lineCount: lyrics.split(separator: "\n").count
        )
    }

    // MARK: - Ultimate Guitar Integration

    func importFromUltimateGuitar(tabId: String, completion: @escaping (ImportedSong?, Error?) -> Void) {
        UltimateGuitarService.shared.fetchTabContent(tabId: tabId) { [weak self] tabContent, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let tabContent = tabContent, let content = tabContent.content else {
                completion(nil, ImportError.noContentExtracted)
                return
            }

            let song = self?.createSongFromText(
                content,
                source: .ultimateGuitar,
                fileName: "\(tabContent.artistName) - \(tabContent.songName)"
            )
            completion(song, nil)
        }
    }

    func searchUltimateGuitar(_ query: String, completion: @escaping ([UltimateGuitarService.TabResult]?, Error?) -> Void) {
        UltimateGuitarService.shared.searchTabs(query: query, completion: completion)
    }

    // MARK: - Models

    struct ImportedSong {
        let song: Song
        let source: ImportSource
        let sourceFileName: String
        let chordCount: Int
        let lineCount: Int
    }

    enum ImportSource: String {
        case pdf = "PDF"
        case word = "Word Document"
        case text = "Text File"
        case image = "Image (OCR)"
        case ultimateGuitar = "Ultimate Guitar"
    }

    enum ImportError: LocalizedError {
        case unsupportedFileType
        case noContentExtracted
        case invalidImage
        case parsingFailed

        var errorDescription: String? {
            switch self {
            case .unsupportedFileType:
                return "File type is not supported. Use PDF, Word, TXT, or image files."
            case .noContentExtracted:
                return "Unable to extract content from the file"
            case .invalidImage:
                return "Unable to load the image file"
            case .parsingFailed:
                return "Failed to parse the file content"
            }
        }
    }
}
