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

// Structure to decode the new dictionary format
private struct RawDefinition: Codable {
    let pos: String
    let def: String
    let ex: String?
}

struct WordOfTheDay {
    let word: String
    let partOfSpeech: String
    let definition: String
}

@MainActor
class DictionaryService: ObservableObject {
    static let shared = DictionaryService()
    private var dictionary: [String: [RawDefinition]] = [:]
    @Published var isLoaded = false
    @Published var loadFailed = false
    @Published var wordOfTheDay: WordOfTheDay?

    // Curated list of interesting words
    private let curatedWords = [
        "ephemeral", "serendipity", "mellifluous", "petrichor", "luminous",
        "eloquent", "resilient", "ethereal", "serene", "vivacious",
        "ineffable", "sanguine", "ebullient", "halcyon", "bucolic",
        "effervescent", "incandescent", "redolent", "sonorous", "dulcet",
        "gossamer", "languid", "limpid", "lissome", "lucid",
        "quixotic", "sagacious", "salubrious", "scintillating", "sublime",
        "surreptitious", "tenacious", "ubiquitous", "verdant", "wistful",
        "zealous", "aesthetic", "benevolent", "diaphanous", "resplendent"
    ]

    private init() {
        Task.detached(priority: .userInitiated) {
            await self.loadDictionary()
        }
    }

    private func loadDictionary() async {
        guard let url = Bundle.main.url(forResource: "modern_dictionary", withExtension: "json") else {
            await MainActor.run {
                self.loadFailed = true
            }
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([String: [RawDefinition]].self, from: data)
            await MainActor.run {
                self.dictionary = decoded
                self.isLoaded = true
                self.updateWordOfTheDay()
            }
        } catch {
            print("Failed to load dictionary: \(error)")
            await MainActor.run {
                self.loadFailed = true
            }
        }
    }

    private func updateWordOfTheDay() {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let year = calendar.component(.year, from: Date())
        let seed = dayOfYear + (year * 1000)

        let wordIndex = seed % curatedWords.count
        let selectedWord = curatedWords[wordIndex]

        if let rawDefs = dictionary[selectedWord],
           let firstDef = rawDefs.first {
            wordOfTheDay = WordOfTheDay(
                word: selectedWord,
                partOfSpeech: firstDef.pos.lowercased(),
                definition: firstDef.def
            )
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

        guard let rawDefs = dictionary[trimmed] else {
            throw DictionaryError.wordNotFound
        }

        return makeEntry(word: trimmed, rawDefinitions: rawDefs)
    }

    private func makeEntry(word: String, rawDefinitions: [RawDefinition]) -> DictionaryEntry {
        // Group definitions by part of speech
        var grouped: [String: [Definition]] = [:]

        for raw in rawDefinitions {
            let def = Definition(definition: raw.def, example: raw.ex)
            if grouped[raw.pos] != nil {
                grouped[raw.pos]?.append(def)
            } else {
                grouped[raw.pos] = [def]
            }
        }

        // Convert to Meaning objects
        let meanings = grouped.map { pos, defs in
            Meaning(partOfSpeech: pos.lowercased(), definitions: defs)
        }.sorted { $0.partOfSpeech < $1.partOfSpeech }

        return DictionaryEntry(
            word: word,
            phonetic: nil,
            meanings: meanings
        )
    }
}
