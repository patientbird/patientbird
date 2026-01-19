import Foundation

enum DictionaryError: Error, LocalizedError {
    case wordNotFound
    case dictionaryNotLoaded

    var errorDescription: String? {
        switch self {
        case .wordNotFound:
            return "Word not found"
        case .dictionaryNotLoaded:
            return "Dictionary loading..."
        }
    }
}

@MainActor
class DictionaryService: ObservableObject {
    static let shared = DictionaryService()
    private var dictionary: [String: String] = [:]
    @Published var isLoaded = false

    private init() {
        Task {
            await loadDictionary()
        }
    }

    private func loadDictionary() async {
        guard let url = Bundle.main.url(forResource: "dictionary", withExtension: "json") else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            dictionary = try JSONDecoder().decode([String: String].self, from: data)
            isLoaded = true
        } catch {
            print("Failed to load dictionary: \(error)")
        }
    }

    func lookup(_ word: String) throws -> DictionaryEntry {
        guard isLoaded else {
            throw DictionaryError.dictionaryNotLoaded
        }

        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else {
            throw DictionaryError.wordNotFound
        }

        guard let definition = dictionary[trimmed] else {
            throw DictionaryError.wordNotFound
        }

        return DictionaryEntry(
            word: trimmed,
            phonetic: nil,
            meanings: [
                Meaning(
                    partOfSpeech: "definition",
                    definitions: [Definition(definition: definition, example: nil)]
                )
            ]
        )
    }
}
