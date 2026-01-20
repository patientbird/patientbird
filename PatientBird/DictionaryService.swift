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
    private var websterDictionary: [String: String] = [:]
    private var supplementaryDictionary: [String: String] = [:]
    @Published var isLoaded = false

    private init() {
        Task.detached(priority: .userInitiated) {
            // Load Webster's first - this enables search
            await self.loadWebster()

            // Then load supplementary dictionary in background
            await self.loadSupplementary()
        }
    }

    private func loadWebster() async {
        guard let url = Bundle.main.url(forResource: "dictionary", withExtension: "json") else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([String: String].self, from: data)
            await MainActor.run {
                self.websterDictionary = decoded
                self.isLoaded = true
            }
        } catch {
            print("Failed to load Webster's dictionary: \(error)")
        }
    }

    private func loadSupplementary() async {
        guard let url = Bundle.main.url(forResource: "supplementary", withExtension: "json") else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([String: String].self, from: data)
            await MainActor.run {
                self.supplementaryDictionary = decoded
            }
        } catch {
            print("Failed to load supplementary dictionary: \(error)")
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

        // Try Webster's first
        if let definition = websterDictionary[trimmed] {
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

        // Fall back to supplementary dictionary
        if let definition = supplementaryDictionary[trimmed] {
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

        throw DictionaryError.wordNotFound
    }
}
