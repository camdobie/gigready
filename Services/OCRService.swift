import Foundation
import Vision
import UIKit

class OCRService {
    static let shared = OCRService()

    func extractTextFromImage(_ image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil, OCRError.invalidImage)
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let recognitionRequest = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil, OCRError.noTextFound)
                return
            }

            let text = observations
                .compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                .joined(separator: "\n")

            completion(text, nil)
        }

        // Use fast processing for better performance
        recognitionRequest.recognitionLevel = .accurate
        recognitionRequest.usesLanguageCorrection = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([recognitionRequest])
            } catch {
                completion(nil, error)
            }
        }
    }

    func extractTextFromImages(_ images: [UIImage], completion: @escaping ([String]?, Error?) -> Void) {
        var results: [String] = []
        let group = DispatchGroup()

        for image in images {
            group.enter()
            extractTextFromImage(image) { text, error in
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

    enum OCRError: LocalizedError {
        case invalidImage
        case noTextFound
        case processingFailed

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "Unable to process the image"
            case .noTextFound:
                return "No text found in the image"
            case .processingFailed:
                return "Failed to process image"
            }
        }
    }
}
