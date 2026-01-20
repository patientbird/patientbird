import Foundation

class BookService {
    static let shared = BookService()

    private init() {}

    func getAllBooks() -> [Book] {
        return [
            Book(
                id: "frankenstein",
                title: "Frankenstein",
                author: "Mary Shelley",
                year: 1818,
                description: "The original science fiction novel exploring creation, responsibility, and what makes us human.",
                gutenbergURL: "https://www.gutenberg.org/ebooks/84",
                wordCount: 74000
            ),
            Book(
                id: "pride-and-prejudice",
                title: "Pride and Prejudice",
                author: "Jane Austen",
                year: 1813,
                description: "A witty exploration of love, class, and social expectations in Regency-era England.",
                gutenbergURL: "https://www.gutenberg.org/ebooks/1342",
                wordCount: 122000
            ),
            Book(
                id: "great-gatsby",
                title: "The Great Gatsby",
                author: "F. Scott Fitzgerald",
                year: 1925,
                description: "A portrait of the Jazz Age and the American Dream's promises and illusions.",
                gutenbergURL: nil,
                wordCount: 47000
            ),
            Book(
                id: "moby-dick",
                title: "Moby-Dick",
                author: "Herman Melville",
                year: 1851,
                description: "An epic tale of obsession, fate, and humanity's struggle against nature.",
                gutenbergURL: "https://www.gutenberg.org/ebooks/2701",
                wordCount: 206000
            ),
            Book(
                id: "literary-neologisms",
                title: "Literary Neologisms",
                author: "Various Authors",
                year: 2024,
                description: "Made-up words from famous books that have entered our vocabulary or deserve recognition.",
                gutenbergURL: nil,
                wordCount: 0
            )
        ]
    }

    func getVocabulary(for bookId: String) -> BookVocabulary? {
        guard let book = getAllBooks().first(where: { $0.id == bookId }) else {
            return nil
        }

        let words: [VocabularyWord]
        switch bookId {
        case "frankenstein":
            words = frankensteinVocabulary
        case "pride-and-prejudice":
            words = prideAndPrejudiceVocabulary
        case "great-gatsby":
            words = greatGatsbyVocabulary
        case "moby-dick":
            words = mobyDickVocabulary
        case "literary-neologisms":
            words = literaryNeologisms
        default:
            words = []
        }

        return BookVocabulary(book: book, words: words)
    }

    // MARK: - Frankenstein Vocabulary

    private var frankensteinVocabulary: [VocabularyWord] {
        [
            VocabularyWord(word: "galvanism", difficulty: .advanced, context: "I collected the instruments of life around me, that I might infuse a spark of being into the lifeless thing"),
            VocabularyWord(word: "countenance", difficulty: .intermediate, context: "His countenance bespoke bitter anguish"),
            VocabularyWord(word: "ardour", difficulty: .intermediate, context: "I pursued my undertaking with unremitting ardour"),
            VocabularyWord(word: "abhorred", difficulty: .intermediate, context: "I, the miserable and the abandoned, am an abortion, to be spurned at, and kicked, and trampled on"),
            VocabularyWord(word: "consternation", difficulty: .intermediate, context: "I beheld the wretch with consternation"),
            VocabularyWord(word: "benevolence", difficulty: .intermediate, context: "His benevolence was evident in all his actions"),
            VocabularyWord(word: "melancholy", difficulty: .intermediate, context: "A melancholy that nothing could dissipate"),
            VocabularyWord(word: "visage", difficulty: .advanced, context: "I beheld the accomplishment of my toils... the beauty of the dream vanished, and breathless horror and disgust filled my heart"),
            VocabularyWord(word: "physiognomy", difficulty: .advanced, context: "His physiognomy struck me with horror"),
            VocabularyWord(word: "charnel", difficulty: .advanced, context: "I collected bones from charnel-houses"),
            VocabularyWord(word: "prognosticate", difficulty: .advanced, context: "I prognosticated evil from it"),
            VocabularyWord(word: "ignominy", difficulty: .advanced, context: "The ignominy of his condition"),
            VocabularyWord(word: "filament", difficulty: .intermediate, context: "The minutest filament of his frame"),
            VocabularyWord(word: "chimera", difficulty: .literary, context: "My dreams were not chimeras of a sick imagination"),
            VocabularyWord(word: "torpor", difficulty: .advanced, context: "The torpor of sleep"),
            VocabularyWord(word: "diffidence", difficulty: .advanced, context: "His diffidence was excessive"),
            VocabularyWord(word: "pertinacity", difficulty: .advanced, context: "The pertinacity of my request"),
            VocabularyWord(word: "transitory", difficulty: .intermediate, context: "The transitory nature of life"),
            VocabularyWord(word: "pallid", difficulty: .intermediate, context: "His pallid skin scarcely covered the work of muscles"),
            VocabularyWord(word: "loathsome", difficulty: .intermediate, context: "A thing such as even Dante could not have conceived"),
        ]
    }

    // MARK: - Pride and Prejudice Vocabulary

    private var prideAndPrejudiceVocabulary: [VocabularyWord] {
        [
            VocabularyWord(word: "impertinence", difficulty: .intermediate, context: "Your mother insists upon my staying, and I cannot refuse to indulge such impertinence"),
            VocabularyWord(word: "civility", difficulty: .intermediate, context: "She was determined to be civil, quiet, and unembarrassing"),
            VocabularyWord(word: "vexation", difficulty: .intermediate, context: "The vexation of Mrs. Bennet was excessive"),
            VocabularyWord(word: "candour", difficulty: .intermediate, context: "Jane's candour in assessing Mr. Bingley's character"),
            VocabularyWord(word: "amiable", difficulty: .intermediate, context: "Mr. Bingley was amiable and handsome"),
            VocabularyWord(word: "condescension", difficulty: .advanced, context: "His condescension was such an unexpected honour"),
            VocabularyWord(word: "felicity", difficulty: .intermediate, context: "Domestic felicity was the height of her ambition"),
            VocabularyWord(word: "discernment", difficulty: .intermediate, context: "Elizabeth prided herself on her discernment"),
            VocabularyWord(word: "propitious", difficulty: .advanced, context: "The circumstances were not propitious"),
            VocabularyWord(word: "acquiescence", difficulty: .advanced, context: "Her acquiescence was not difficult to obtain"),
            VocabularyWord(word: "mortification", difficulty: .intermediate, context: "Her mortification was complete"),
            VocabularyWord(word: "supercilious", difficulty: .advanced, context: "His supercilious manner offended everyone"),
            VocabularyWord(word: "effusion", difficulty: .advanced, context: "Effusions of gratitude"),
            VocabularyWord(word: "censure", difficulty: .intermediate, context: "Liable to censure from the world"),
            VocabularyWord(word: "affability", difficulty: .advanced, context: "Her affability and condescension"),
            VocabularyWord(word: "solace", difficulty: .intermediate, context: "She found solace in music"),
            VocabularyWord(word: "caprice", difficulty: .intermediate, context: "Subject to the caprice of others"),
            VocabularyWord(word: "fastidious", difficulty: .advanced, context: "Too fastidious for country society"),
            VocabularyWord(word: "rectitude", difficulty: .advanced, context: "His moral rectitude was unquestionable"),
            VocabularyWord(word: "probity", difficulty: .advanced, context: "A man of probity and honour"),
        ]
    }

    // MARK: - The Great Gatsby Vocabulary

    private var greatGatsbyVocabulary: [VocabularyWord] {
        [
            VocabularyWord(word: "orgastic", difficulty: .literary, context: "Gatsby believed in the green light, the orgastic future", customDefinition: "Fitzgerald's coinage suggesting ecstatic, orgiastic—a climactic moment of fulfillment", isNeologism: true),
            VocabularyWord(word: "supercilious", difficulty: .advanced, context: "Two shining, arrogant eyes had established dominance over his face"),
            VocabularyWord(word: "truculent", difficulty: .advanced, context: "Tom Buchanan's truculent manner"),
            VocabularyWord(word: "contiguous", difficulty: .advanced, context: "The less fashionable of the two, though this is a most superficial tag to express the bizarre and not a little sinister contrast between them"),
            VocabularyWord(word: "facet", difficulty: .intermediate, context: "Every facet of Gatsby's personality"),
            VocabularyWord(word: "feigned", difficulty: .intermediate, context: "His feigned interest in her problems"),
            VocabularyWord(word: "languid", difficulty: .intermediate, context: "Her languid movements suggested boredom"),
            VocabularyWord(word: "vacuous", difficulty: .advanced, context: "The vacuous bursts of laughter"),
            VocabularyWord(word: "punctilious", difficulty: .advanced, context: "His punctilious attention to etiquette"),
            VocabularyWord(word: "innuendo", difficulty: .intermediate, context: "Rumors and innuendo about Gatsby's wealth"),
            VocabularyWord(word: "hauteur", difficulty: .advanced, context: "Daisy's natural hauteur"),
            VocabularyWord(word: "debauchery", difficulty: .advanced, context: "The debauchery of the Jazz Age"),
            VocabularyWord(word: "ineffable", difficulty: .advanced, context: "Something ineffable about his smile"),
            VocabularyWord(word: "meretricious", difficulty: .advanced, context: "The meretricious beauty of his mansion"),
            VocabularyWord(word: "nebulous", difficulty: .intermediate, context: "His nebulous origins"),
            VocabularyWord(word: "sauntered", difficulty: .intermediate, context: "He sauntered across the lawn"),
            VocabularyWord(word: "inconsequential", difficulty: .intermediate, context: "Inconsequential chatter filled the room"),
            VocabularyWord(word: "presumptuous", difficulty: .intermediate, context: "It was presumptuous of him to assume"),
            VocabularyWord(word: "ectoplasm", difficulty: .advanced, context: "Like some kind of ectoplasm of the past"),
            VocabularyWord(word: "caterwauling", difficulty: .intermediate, context: "The caterwauling of saxophones"),
        ]
    }

    // MARK: - Moby-Dick Vocabulary

    private var mobyDickVocabulary: [VocabularyWord] {
        [
            VocabularyWord(word: "cetology", difficulty: .literary, context: "A systematic classification of whales", customDefinition: "The branch of zoology dealing with whales, dolphins, and porpoises"),
            VocabularyWord(word: "leviathan", difficulty: .advanced, context: "The great leviathan of the deep"),
            VocabularyWord(word: "hogshead", difficulty: .advanced, context: "Casks and hogsheads of whale oil"),
            VocabularyWord(word: "blubber", difficulty: .intermediate, context: "The blubber room aboard the Pequod"),
            VocabularyWord(word: "forecastle", difficulty: .advanced, context: "The sailors gathered in the forecastle"),
            VocabularyWord(word: "harpoon", difficulty: .intermediate, context: "Queequeg's deadly harpoon"),
            VocabularyWord(word: "ambergris", difficulty: .advanced, context: "The precious ambergris from the whale's gut"),
            VocabularyWord(word: "spermaceti", difficulty: .literary, context: "The spermaceti found in the whale's head", customDefinition: "A waxy substance found in the head cavities of sperm whales, once used in candles and ointments"),
            VocabularyWord(word: "portentous", difficulty: .advanced, context: "A portentous sign of doom"),
            VocabularyWord(word: "ineffable", difficulty: .advanced, context: "The ineffable whiteness of the whale"),
            VocabularyWord(word: "monomaniac", difficulty: .advanced, context: "Ahab's monomaniac pursuit"),
            VocabularyWord(word: "circumambulate", difficulty: .advanced, context: "To circumambulate the entire ocean"),
            VocabularyWord(word: "inscrutable", difficulty: .advanced, context: "The inscrutable malice of the whale"),
            VocabularyWord(word: "apotheosis", difficulty: .advanced, context: "The apotheosis of evil"),
            VocabularyWord(word: "malignity", difficulty: .advanced, context: "The malignity that had plagued him"),
            VocabularyWord(word: "perdition", difficulty: .advanced, context: "Sailing towards perdition"),
            VocabularyWord(word: "doubloon", difficulty: .intermediate, context: "The gold doubloon nailed to the mast"),
            VocabularyWord(word: "prognostication", difficulty: .advanced, context: "Dark prognostications of the voyage"),
            VocabularyWord(word: "immutable", difficulty: .advanced, context: "The immutable nature of fate"),
            VocabularyWord(word: "preternatural", difficulty: .advanced, context: "A preternatural whiteness"),
        ]
    }

    // MARK: - Literary Neologisms

    private var literaryNeologisms: [VocabularyWord] {
        [
            VocabularyWord(
                word: "grotendous",
                difficulty: .literary,
                context: "Snow Crash by Neal Stephenson",
                customDefinition: "A portmanteau of 'grotesque' and 'horrendous' - something so awful it combines the worst of both qualities. Coined by Neal Stephenson in his 1992 cyberpunk novel Snow Crash.",
                isNeologism: true
            ),
            VocabularyWord(
                word: "hobbit",
                difficulty: .literary,
                context: "The Hobbit / Lord of the Rings by J.R.R. Tolkien",
                customDefinition: "A member of an imaginary race similar to humans, of small stature and with hairy feet. Created by J.R.R. Tolkien, possibly derived from 'hole' + 'rabbit' or Old English 'holbytla' (hole-dweller).",
                isNeologism: true
            ),
            VocabularyWord(
                word: "muggle",
                difficulty: .literary,
                context: "Harry Potter series by J.K. Rowling",
                customDefinition: "A person who lacks magical ability or is unaware of the magical world. Now used colloquially to mean an outsider or someone unfamiliar with a particular activity or skill.",
                isNeologism: true
            ),
            VocabularyWord(
                word: "grok",
                difficulty: .literary,
                context: "Stranger in a Strange Land by Robert A. Heinlein",
                customDefinition: "To understand something intuitively or by empathy; to establish rapport. From Martian, meaning literally 'to drink' but metaphorically 'to become one with.' Now common in programming culture.",
                isNeologism: true
            ),
            VocabularyWord(
                word: "doublethink",
                difficulty: .literary,
                context: "1984 by George Orwell",
                customDefinition: "The acceptance of contrary opinions or beliefs at the same time, especially as a result of political indoctrination. Central concept in Orwell's dystopian vision.",
                isNeologism: true
            ),
            VocabularyWord(
                word: "newspeak",
                difficulty: .literary,
                context: "1984 by George Orwell",
                customDefinition: "Ambiguous euphemistic language used chiefly in political propaganda. The controlled language created by the totalitarian state in Orwell's novel.",
                isNeologism: true
            ),
            VocabularyWord(
                word: "cyberspace",
                difficulty: .literary,
                context: "Neuromancer by William Gibson",
                customDefinition: "The notional environment in which communication over computer networks occurs. Coined by William Gibson in 1982, popularized in his 1984 novel Neuromancer.",
                isNeologism: true
            ),
            VocabularyWord(
                word: "quark",
                difficulty: .literary,
                context: "Finnegans Wake by James Joyce",
                customDefinition: "Originally a nonsense word in Joyce's 'Three quarks for Muster Mark!' Later adopted by physicist Murray Gell-Mann for fundamental subatomic particles.",
                isNeologism: true
            ),
            VocabularyWord(
                word: "chortle",
                difficulty: .literary,
                context: "Through the Looking-Glass by Lewis Carroll",
                customDefinition: "A breathy, gleeful laugh. A portmanteau of 'chuckle' and 'snort' invented by Lewis Carroll in 1871. One of few literary coinages to enter standard English.",
                isNeologism: true
            ),
            VocabularyWord(
                word: "nerd",
                difficulty: .literary,
                context: "If I Ran the Zoo by Dr. Seuss",
                customDefinition: "Though its exact origin is debated, 'nerd' first appeared in print in Dr. Seuss's 1950 book as a fantastical creature. Now means a person devoted to intellectual or academic pursuits.",
                isNeologism: true
            ),
            VocabularyWord(
                word: "pandemonium",
                difficulty: .literary,
                context: "Paradise Lost by John Milton",
                customDefinition: "Wild uproar or chaos. Originally the name of the capital of Hell in Milton's epic poem (1667), from Greek 'pan' (all) + 'daimon' (demon).",
                isNeologism: true
            ),
            VocabularyWord(
                word: "robot",
                difficulty: .literary,
                context: "R.U.R. by Karel Čapek",
                customDefinition: "A machine capable of carrying out complex actions automatically. Coined by Karel Čapek in his 1920 play, from Czech 'robota' meaning forced labor or drudgery.",
                isNeologism: true
            ),
            VocabularyWord(
                word: "utopia",
                difficulty: .literary,
                context: "Utopia by Thomas More",
                customDefinition: "An imagined perfect place or state of things. Coined by Thomas More in 1516 from Greek 'ou' (not) + 'topos' (place), literally 'no-place.' Deliberately ambiguous with 'eu-topos' (good place).",
                isNeologism: true
            ),
            VocabularyWord(
                word: "serendipity",
                difficulty: .literary,
                context: "Coined by Horace Walpole, inspired by The Three Princes of Serendip",
                customDefinition: "The occurrence of events by chance in a happy way. Coined in 1754 by Horace Walpole after a Persian fairy tale where princes 'were always making discoveries, by accidents and sagacity, of things they were not in quest of.'",
                isNeologism: true
            ),
            VocabularyWord(
                word: "yahoo",
                difficulty: .literary,
                context: "Gulliver's Travels by Jonathan Swift",
                customDefinition: "A rude, uncouth person. In Swift's 1726 satire, Yahoos are brutish humanoid creatures contrasted with the rational Houyhnhnms (horses).",
                isNeologism: true
            ),
        ]
    }
}
