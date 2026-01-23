import WidgetKit
import SwiftUI

struct WordOfTheDayEntry: TimelineEntry {
    let date: Date
    let word: String
    let partOfSpeech: String
    let definition: String
}

struct Provider: TimelineProvider {
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

    private let definitions: [String: (String, String)] = [
        "ephemeral": ("adjective", "lasting for a very short time"),
        "serendipity": ("noun", "the occurrence of events by chance in a happy way"),
        "mellifluous": ("adjective", "sweet or musical; pleasant to hear"),
        "petrichor": ("noun", "a pleasant smell after rain falls on dry ground"),
        "luminous": ("adjective", "full of or shedding light; bright or shining"),
        "eloquent": ("adjective", "fluent or persuasive in speaking or writing"),
        "resilient": ("adjective", "able to recover quickly from difficulties"),
        "ethereal": ("adjective", "extremely delicate and light; heavenly"),
        "serene": ("adjective", "calm, peaceful, and untroubled"),
        "vivacious": ("adjective", "attractively lively and animated"),
        "ineffable": ("adjective", "too great to be expressed in words"),
        "sanguine": ("adjective", "optimistic or positive, especially in a difficult situation"),
        "ebullient": ("adjective", "cheerful and full of energy"),
        "halcyon": ("adjective", "denoting a happy, golden, or prosperous time"),
        "bucolic": ("adjective", "relating to the pleasant aspects of the countryside"),
        "effervescent": ("adjective", "vivacious and enthusiastic"),
        "incandescent": ("adjective", "emitting light as a result of being heated"),
        "redolent": ("adjective", "strongly reminiscent or suggestive of"),
        "sonorous": ("adjective", "imposingly deep and full in sound"),
        "dulcet": ("adjective", "sweet and soothing to hear"),
        "gossamer": ("adjective", "used to refer to something very light, thin, and delicate"),
        "languid": ("adjective", "lacking energy or vitality; weak or faint"),
        "limpid": ("adjective", "completely clear and transparent"),
        "lissome": ("adjective", "thin, supple, and graceful"),
        "lucid": ("adjective", "expressed clearly; easy to understand"),
        "quixotic": ("adjective", "exceedingly idealistic; unrealistic and impractical"),
        "sagacious": ("adjective", "having keen mental discernment and good judgment"),
        "salubrious": ("adjective", "health-giving; healthy"),
        "scintillating": ("adjective", "sparkling or shining brightly"),
        "sublime": ("adjective", "of outstanding spiritual or artistic worth"),
        "surreptitious": ("adjective", "kept secret because it would not be approved of"),
        "tenacious": ("adjective", "holding firmly to something; persistent"),
        "ubiquitous": ("adjective", "present, appearing, or found everywhere"),
        "verdant": ("adjective", "green with grass or other rich vegetation"),
        "wistful": ("adjective", "having or showing a feeling of vague longing"),
        "zealous": ("adjective", "having great energy or enthusiasm"),
        "aesthetic": ("adjective", "concerned with beauty or the appreciation of beauty"),
        "benevolent": ("adjective", "well meaning and kindly"),
        "diaphanous": ("adjective", "light, delicate, and translucent"),
        "resplendent": ("adjective", "impressive through being rich or colorful")
    ]

    func placeholder(in context: Context) -> WordOfTheDayEntry {
        WordOfTheDayEntry(date: Date(), word: "serendipity", partOfSpeech: "noun", definition: "the occurrence of events by chance in a happy way")
    }

    func getSnapshot(in context: Context, completion: @escaping (WordOfTheDayEntry) -> Void) {
        completion(getWordOfTheDay())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordOfTheDayEntry>) -> Void) {
        let entry = getWordOfTheDay()
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func getWordOfTheDay() -> WordOfTheDayEntry {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let year = calendar.component(.year, from: Date())
        let seed = dayOfYear + (year * 1000)
        let wordIndex = seed % curatedWords.count
        let selectedWord = curatedWords[wordIndex]

        if let (pos, def) = definitions[selectedWord] {
            return WordOfTheDayEntry(date: Date(), word: selectedWord, partOfSpeech: pos, definition: def)
        }
        return WordOfTheDayEntry(date: Date(), word: "serendipity", partOfSpeech: "noun", definition: "the occurrence of events by chance in a happy way")
    }
}

struct PatientBirdWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        let isSmall = family == .systemSmall

        VStack(spacing: isSmall ? 10 : 12) {
            // Search bar - opens app home
            Link(destination: URL(string: "patientbird://search")!) {
                HStack(spacing: 8) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: isSmall ? 16 : 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))

                    if !isSmall {
                        Text("Look up a word")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                    }
                }
                .padding(.horizontal, isSmall ? 16 : 14)
                .padding(.vertical, isSmall ? 14 : 12)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.12))
                .cornerRadius(isSmall ? 16 : 12)
            }

            // Word of the day - opens definition
            Link(destination: URL(string: "patientbird://word/\(entry.word)")!) {
                VStack(alignment: .leading, spacing: isSmall ? 3 : 5) {
                    Text("WORD OF THE DAY")
                        .font(.system(size: isSmall ? 9 : 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(0.5)

                    Text(entry.word)
                        .font(.system(size: isSmall ? 16 : 22, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(entry.partOfSpeech)
                        .font(.system(size: isSmall ? 10 : 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .italic()

                    if !isSmall {
                        Text(entry.definition)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
    }
}

struct PatientBirdWidget: Widget {
    let kind: String = "PatientBirdWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PatientBirdWidgetEntryView(entry: entry)
                .containerBackground(Color(white: 0.11), for: .widget)
        }
        .configurationDisplayName("Word of the Day")
        .description("Learn a new word every day.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    PatientBirdWidget()
} timeline: {
    WordOfTheDayEntry(date: .now, word: "serendipity", partOfSpeech: "noun", definition: "the occurrence of events by chance in a happy way")
}

#Preview(as: .systemMedium) {
    PatientBirdWidget()
} timeline: {
    WordOfTheDayEntry(date: .now, word: "serendipity", partOfSpeech: "noun", definition: "the occurrence of events by chance in a happy way")
}
