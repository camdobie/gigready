import Foundation

class WordDocumentParsingService {
    static let shared = WordDocumentParsingService()

    func extractTextFromWordDocument(url: URL, completion: @escaping (String?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Create a temporary directory for extracting the DOCX
                let tempDirectory = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)

                try FileManager.default.createDirectory(
                    at: tempDirectory,
                    withIntermediateDirectories: true
                )

                // Extract DOCX (which is a ZIP file)
                try FileManager.default.unzipItem(at: url, to: tempDirectory)

                // Read the document.xml file which contains the text
                let documentXMLPath = tempDirectory
                    .appendingPathComponent("word/document.xml")

                guard FileManager.default.fileExists(atPath: documentXMLPath.path) else {
                    throw WordError.invalidDocxStructure
                }

                let xmlContent = try String(contentsOf: documentXMLPath, encoding: .utf8)
                let extractedText = parseWordXML(xmlContent)

                // Cleanup
                try FileManager.default.removeItem(at: tempDirectory)

                DispatchQueue.main.async {
                    completion(extractedText, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }

    func extractTextFromWordDocuments(_ urls: [URL], completion: @escaping ([String]?, Error?) -> Void) {
        var results: [String] = []
        let group = DispatchGroup()

        for url in urls {
            group.enter()
            extractTextFromWordDocument(url: url) { text, error in
                if let text = text {
                    results.append(text)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(results, nil)
        }
    }

    // Parse Word XML and extract text content
    private func parseWordXML(_ xml: String) -> String {
        // Remove XML tags while preserving line breaks and text content
        var text = xml

        // Replace paragraph tags with newlines
        text = text.replacingOccurrences(of: "</w:p>", with: "\n")

        // Remove most common Word XML tags
        let patterns = [
            "<[^>]+>", // All XML tags
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                text = regex.stringByReplacingMatches(
                    in: text,
                    options: [],
                    range: range,
                    withTemplate: ""
                )
            }
        }

        // Decode HTML entities
        text = decodeHTMLEntities(text)

        // Remove extra whitespace while preserving paragraph breaks
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        let cleanedLines = lines.map { String($0).trimmingCharacters(in: .whitespaces) }
        let result = cleanedLines.joined(separator: "\n")

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func decodeHTMLEntities(_ text: String) -> String {
        var result = text
        let entities = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'",
            "&#x27;": "'",
            "&#39;": "'",
            "&nbsp;": " ",
            "&#160;": " ",
        ]

        for (entity, character) in entities {
            result = result.replacingOccurrences(of: entity, with: character)
        }

        return result
    }

    enum WordError: LocalizedError {
        case invalidDocxFile
        case invalidDocxStructure
        case unzipFailed
        case parsingFailed

        var errorDescription: String? {
            switch self {
            case .invalidDocxFile:
                return "Unable to read the Word document"
            case .invalidDocxStructure:
                return "The Word document structure is invalid"
            case .unzipFailed:
                return "Failed to extract the Word document"
            case .parsingFailed:
                return "Failed to parse the Word document"
            }
        }
    }
}

// MARK: - ZIP Extraction Extension
extension FileManager {
    func unzipItem(at sourceURL: URL, to destinationURL: URL) throws {
        // Note: This would typically use a library like ZipArchive
        // For now, we'll use Foundation's built-in capabilities
        let data = try Data(contentsOf: sourceURL)
        try unzipData(data, to: destinationURL)
    }

    private func unzipData(_ data: Data, to destinationURL: URL) throws {
        // This is a simplified implementation
        // In production, use a library like ZipArchive or SSZipArchive
        #if os(iOS)
        // Use native Foundation APIs or third-party library
        // For now, we'll assume the file can be extracted
        guard let archive = Archive(data: data) else {
            throw NSError(domain: "ZipError", code: 1)
        }

        for entry in archive {
            let entryPath = destinationURL.appendingPathComponent(entry.path)
            if entry.path.hasSuffix("/") {
                try FileManager.default.createDirectory(
                    at: entryPath,
                    withIntermediateDirectories: true
                )
            } else {
                try FileManager.default.createDirectory(
                    at: entryPath.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                if let data = try archive.extract(entry) {
                    try data.write(to: entryPath)
                }
            }
        }
        #endif
    }
}

// Placeholder Archive class - use a real ZIP library in production
class Archive {
    let data: Data

    init?(data: Data) {
        self.data = data
    }

    func makeIterator() -> AnyIterator<Entry> {
        return AnyIterator { nil }
    }

    struct Entry {
        let path: String
    }
}

extension Archive: Sequence {
    typealias Element = Entry
}

func extract(_ entry: Archive.Entry) throws -> Data? {
    return nil
}
