import Foundation

struct DictionaryEntry: Codable, Identifiable {
    let id = UUID()
    let word: String
    let phonetic: String?
    let meanings: [Meaning]

    enum CodingKeys: String, CodingKey {
        case word, phonetic, meanings
    }
}

struct Meaning: Codable, Identifiable {
    let id = UUID()
    let partOfSpeech: String
    let definitions: [Definition]

    enum CodingKeys: String, CodingKey {
        case partOfSpeech, definitions
    }
}

struct Definition: Codable, Identifiable {
    let id = UUID()
    let definition: String
    let example: String?

    enum CodingKeys: String, CodingKey {
        case definition, example
    }
}
