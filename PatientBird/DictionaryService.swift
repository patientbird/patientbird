import Foundation

enum DictionaryError: Error, LocalizedError {
    case wordNotFound
    case networkError
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .wordNotFound:
            return "Word not found"
        case .networkError:
            return "Network error"
        case .invalidResponse:
            return "Invalid response"
        }
    }
}

class DictionaryService {
    static let shared = DictionaryService()
    private let baseURL = "https://api.dictionaryapi.dev/api/v2/entries/en/"

    private init() {}

    func lookup(_ word: String) async throws -> DictionaryEntry {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else {
            throw DictionaryError.wordNotFound
        }

        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: baseURL + encoded) else {
            throw DictionaryError.invalidResponse
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DictionaryError.networkError
        }

        if httpResponse.statusCode == 404 {
            throw DictionaryError.wordNotFound
        }

        guard httpResponse.statusCode == 200 else {
            throw DictionaryError.networkError
        }

        let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)

        guard let entry = entries.first else {
            throw DictionaryError.wordNotFound
        }

        return entry
    }
}
