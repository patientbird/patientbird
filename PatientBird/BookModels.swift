import Foundation

struct Book: Identifiable, Codable {
    let id: String
    let title: String
    let author: String
    let year: Int
    let description: String
    let gutenbergURL: String?
    let wordCount: Int

    var displayYear: String {
        return String(year)
    }
}

struct VocabularyWord: Identifiable, Codable, Hashable {
    var id: String { word }
    let word: String
    let difficulty: WordDifficulty
    let context: String?
    let customDefinition: String?
    let isNeologism: Bool

    init(word: String, difficulty: WordDifficulty = .intermediate, context: String? = nil, customDefinition: String? = nil, isNeologism: Bool = false) {
        self.word = word
        self.difficulty = difficulty
        self.context = context
        self.customDefinition = customDefinition
        self.isNeologism = isNeologism
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
    }

    static func == (lhs: VocabularyWord, rhs: VocabularyWord) -> Bool {
        lhs.word == rhs.word
    }
}

enum WordDifficulty: String, Codable, CaseIterable {
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case literary = "Literary"

    var sortOrder: Int {
        switch self {
        case .literary: return 0
        case .advanced: return 1
        case .intermediate: return 2
        }
    }
}

struct BookVocabulary: Identifiable {
    var id: String { book.id }
    let book: Book
    let words: [VocabularyWord]

    var wordsByDifficulty: [WordDifficulty: [VocabularyWord]] {
        Dictionary(grouping: words, by: { $0.difficulty })
    }

    var neologisms: [VocabularyWord] {
        words.filter { $0.isNeologism }
    }
}
