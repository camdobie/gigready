import Foundation
import PDFKit

class PDFParsingService {
    static let shared = PDFParsingService()

    func extractTextFromPDF(url: URL, completion: @escaping (String?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let pdfDocument = PDFDocument(url: url) else {
                DispatchQueue.main.async {
                    completion(nil, PDFError.invalidPDF)
                }
                return
            }

            let pageCount = pdfDocument.pageCount
            var fullText = ""

            for pageIndex in 0..<pageCount {
                if let page = pdfDocument.page(at: pageIndex) {
                    if let pageText = page.string {
                        fullText += pageText + "\n"
                    }
                }
            }

            DispatchQueue.main.async {
                if fullText.isEmpty {
                    completion(nil, PDFError.noTextExtracted)
                } else {
                    completion(fullText, nil)
                }
            }
        }
    }

    func extractTextFromPDFs(_ urls: [URL], completion: @escaping ([String]?, Error?) -> Void) {
        var results: [String] = []
        let group = DispatchGroup()

        for url in urls {
            group.enter()
            extractTextFromPDF(url: url) { text, error in
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

    // Extract metadata from PDF (useful for pre-filling song info)
    func extractMetadata(from url: URL) -> PDFMetadata? {
        guard let pdfDocument = PDFDocument(url: url) else {
            return nil
        }

        let documentAttributes = pdfDocument.documentAttributes ?? [:]
        let title = documentAttributes[PDFDocumentAttribute.titleAttribute] as? String
        let author = documentAttributes[PDFDocumentAttribute.authorAttribute] as? String
        let subject = documentAttributes[PDFDocumentAttribute.subjectAttribute] as? String

        return PDFMetadata(
            title: title ?? url.deletingPathExtension().lastPathComponent,
            author: author,
            subject: subject
        )
    }

    enum PDFError: LocalizedError {
        case invalidPDF
        case noTextExtracted
        case processingFailed

        var errorDescription: String? {
            switch self {
            case .invalidPDF:
                return "Unable to read the PDF file"
            case .noTextExtracted:
                return "No text content found in PDF"
            case .processingFailed:
                return "Failed to process PDF"
            }
        }
    }

    struct PDFMetadata {
        let title: String
        let author: String?
        let subject: String?
    }
}
