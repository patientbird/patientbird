import Foundation
import AVFoundation

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

    // Speech synthesizer for pronunciation
    private let speechSynthesizer = AVSpeechSynthesizer()

    // Blocklist for names and political figures to keep app neutral
    private let blockedWords: Set<String> = [
        "donald trump", "donaldtrump"
    ]

    // App Group identifier for sharing with widget
    private let appGroupID = "group.com.patientbird.dictionary"

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
        // Filter for good WOTD candidates
        let candidates = dictionary.keys.filter { word in
            // Must be 4-15 characters
            guard word.count >= 4 && word.count <= 15 else { return false }
            // Must be only letters (no spaces, hyphens, numbers)
            guard word.allSatisfy({ $0.isLetter }) else { return false }
            // Must not be in blocklist
            guard !blockedWords.contains(word) else { return false }
            // Must have a valid definition
            guard let defs = dictionary[word], !defs.isEmpty else { return false }
            return true
        }.sorted() // Sort for consistent ordering

        guard !candidates.isEmpty else { return }

        // Use date-based seed for deterministic daily selection
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let year = calendar.component(.year, from: Date())
        let seed = dayOfYear + (year * 1000)

        let wordIndex = seed % candidates.count
        let selectedWord = candidates[wordIndex]

        if let rawDefs = dictionary[selectedWord],
           let firstDef = rawDefs.first {
            let wotd = WordOfTheDay(
                word: selectedWord,
                partOfSpeech: firstDef.pos.lowercased(),
                definition: firstDef.def
            )
            wordOfTheDay = wotd

            // Save to App Group for widget access
            if let sharedDefaults = UserDefaults(suiteName: appGroupID) {
                sharedDefaults.set(selectedWord, forKey: "wotd_word")
                sharedDefaults.set(firstDef.pos.lowercased(), forKey: "wotd_pos")
                sharedDefaults.set(firstDef.def, forKey: "wotd_def")
                sharedDefaults.set(Date(), forKey: "wotd_date")
            }
        }
    }

    func refreshWordOfTheDayIfNeeded() {
        guard isLoaded else { return }

        // Check if day has changed since last update
        let calendar = Calendar.current
        if let lastDate = UserDefaults(suiteName: appGroupID)?.object(forKey: "wotd_date") as? Date {
            if calendar.isDateInToday(lastDate) {
                return // Already updated today
            }
        }

        updateWordOfTheDay()
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

        // Check blocklist
        if blockedWords.contains(trimmed) {
            throw DictionaryError.wordNotFound
        }

        guard let rawDefs = dictionary[trimmed] else {
            throw DictionaryError.wordNotFound
        }

        return makeEntry(word: trimmed, rawDefinitions: rawDefs)
    }

    func speak(_ word: String) {
        speechSynthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.0

        speechSynthesizer.speak(utterance)
    }

    func findSuggestion(_ word: String) -> String? {
        guard isLoaded else { return nil }

        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return nil }

        // Already exists, no suggestion needed
        if dictionary[trimmed] != nil { return nil }

        var bestMatch: String?
        var bestDistance = Int.max

        // Only check words within reasonable length difference
        let wordLength = trimmed.count
        let maxLengthDiff = 3
        let maxDistance = min(3, wordLength / 2 + 1) // Scale with word length

        for dictWord in dictionary.keys {
            // Skip if length difference is too large
            if abs(dictWord.count - wordLength) > maxLengthDiff {
                continue
            }

            let distance = levenshteinDistance(trimmed, dictWord)

            if distance < bestDistance && distance <= maxDistance {
                bestDistance = distance
                bestMatch = dictWord
            }

            // Perfect match found within tolerance
            if distance == 1 {
                return dictWord
            }
        }

        return bestMatch
    }

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count

        if m == 0 { return n }
        if n == 0 { return m }

        // Use two rows instead of full matrix for memory efficiency
        var prevRow = Array(0...n)
        var currRow = Array(repeating: 0, count: n + 1)

        for i in 1...m {
            currRow[0] = i

            for j in 1...n {
                let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                currRow[j] = min(
                    currRow[j - 1] + 1,      // insertion
                    prevRow[j] + 1,           // deletion
                    prevRow[j - 1] + cost     // substitution
                )
            }

            swap(&prevRow, &currRow)
        }

        return prevRow[n]
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
