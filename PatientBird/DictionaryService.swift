import Foundation

enum DictionaryError: Error, LocalizedError {
    case wordNotFound
    case dictionaryNotLoaded
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .wordNotFound:
            return "Word not found"
        case .dictionaryNotLoaded:
            return "Dictionary loading..."
        case .loadFailed:
            return "Failed to load dictionary"
        }
    }
}

@MainActor
class DictionaryService: ObservableObject {
    static let shared = DictionaryService()
    private var websterDictionary: [String: String] = [:]
    private var supplementaryDictionary: [String: String] = [:]
    @Published var isLoaded = false
    @Published var loadFailed = false

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
            await MainActor.run {
                self.loadFailed = true
            }
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
            await MainActor.run {
                self.loadFailed = true
            }
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
        if loadFailed {
            throw DictionaryError.loadFailed
        }
        guard isLoaded else {
            throw DictionaryError.dictionaryNotLoaded
        }

        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else {
            throw DictionaryError.wordNotFound
        }

        // Try Webster's first, then fall back to supplementary
        if let definition = websterDictionary[trimmed] ?? supplementaryDictionary[trimmed] {
            return makeEntry(word: trimmed, definition: definition)
        }

        throw DictionaryError.wordNotFound
    }

    private func makeEntry(word: String, definition: String) -> DictionaryEntry {
        let cleanedDefinitions = cleanDefinition(definition)

        return DictionaryEntry(
            word: word,
            phonetic: nil,
            meanings: [
                Meaning(
                    partOfSpeech: "definition",
                    definitions: cleanedDefinitions.map { Definition(definition: $0, example: nil) }
                )
            ]
        )
    }

    private func cleanDefinition(_ raw: String) -> [String] {
        // Split on double newlines to get separate meanings/paragraphs
        let paragraphs = raw.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var results: [String] = []

        for paragraph in paragraphs {
            // Skip cross-reference lines and technical details
            if paragraph.hasPrefix("--") || paragraph.hasPrefix("Note:") {
                continue
            }

            // Skip paragraphs that look like tables or lists of data
            if paragraph.contains("Symbol.Name.") || paragraph.contains("º min") {
                continue
            }

            // Clean up the paragraph
            var cleaned = paragraph
                .replacingOccurrences(of: "\n", with: " ")
                .replacingOccurrences(of: "  ", with: " ")

            // Truncate very long paragraphs (keep first ~300 chars ending at word boundary)
            if cleaned.count > 350 {
                if let endIndex = cleaned.index(cleaned.startIndex, offsetBy: 300, limitedBy: cleaned.endIndex),
                   let spaceIndex = cleaned[endIndex...].firstIndex(of: " ") {
                    cleaned = String(cleaned[..<spaceIndex]) + "..."
                }
            }

            results.append(cleaned)

            // Limit to 3 definitions
            if results.count >= 3 {
                break
            }
        }

        // If no valid paragraphs found, return original (truncated)
        if results.isEmpty {
            let truncated = String(raw.prefix(400))
            return [truncated.count < raw.count ? truncated + "..." : truncated]
        }

        return results
    }
}
