import Foundation

class UltimateGuitarService {
    static let shared = UltimateGuitarService()

    private let baseURL = URL(string: "https://api.ultimate-guitar.com/v1")!
    private let session = URLSession.shared

    // MARK: - Search

    func searchTabs(query: String, completion: @escaping ([TabResult]?, Error?) -> Void) {
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let endpoint = baseURL.appendingPathComponent("search")

        var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "type", value: "Chords"),
            URLQueryItem(name: "limit", value: "10"),
        ]

        guard let url = components?.url else {
            completion(nil, UGError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, UGError.noData)
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.results, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }

    // MARK: - Fetch Tab Content

    func fetchTabContent(tabId: String, completion: @escaping (TabContent?, Error?) -> Void) {
        let endpoint = baseURL.appendingPathComponent("tabs").appendingPathComponent(tabId)

        var request = URLRequest(url: endpoint)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, UGError.noData)
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TabContentResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.tab, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }

    // MARK: - Models

    struct SearchResponse: Codable {
        let results: [TabResult]?
    }

    struct TabResult: Codable, Identifiable {
        let id: Int
        let songName: String
        let artistName: String
        let rating: Double?
        let numberOfRatings: Int?
        let type: String
        let url: String
        let votes: Int?

        enum CodingKeys: String, CodingKey {
            case id
            case songName = "song_name"
            case artistName = "artist_name"
            case rating
            case numberOfRatings = "number_of_ratings"
            case type
            case url
            case votes
        }
    }

    struct TabContentResponse: Codable {
        let tab: TabContent?
    }

    struct TabContent: Codable {
        let id: Int
        let songName: String
        let artistName: String
        let content: String?
        let rating: Double?
        let numberOfRatings: Int?
        let difficulty: String?

        enum CodingKeys: String, CodingKey {
            case id
            case songName = "song_name"
            case artistName = "artist_name"
            case content
            case rating
            case numberOfRatings = "number_of_ratings"
            case difficulty
        }
    }

    enum UGError: LocalizedError {
        case invalidURL
        case noData
        case decodingFailed
        case networkError

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL for Ultimate Guitar request"
            case .noData:
                return "No data received from Ultimate Guitar"
            case .decodingFailed:
                return "Failed to decode Ultimate Guitar response"
            case .networkError:
                return "Network error while fetching from Ultimate Guitar"
            }
        }
    }
}
