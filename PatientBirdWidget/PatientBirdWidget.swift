import WidgetKit
import SwiftUI

struct WordOfTheDayEntry: TimelineEntry {
    let date: Date
    let word: String
    let partOfSpeech: String
    let definition: String
}

struct Provider: TimelineProvider {
    // App Group identifier - must match the main app
    private let appGroupID = "group.com.patientbird.dictionary"

    // Fallback for when app hasn't shared data yet
    private let fallbackWord = "serendipity"
    private let fallbackPos = "noun"
    private let fallbackDef = "the occurrence of events by chance in a happy way"

    func placeholder(in context: Context) -> WordOfTheDayEntry {
        WordOfTheDayEntry(date: Date(), word: fallbackWord, partOfSpeech: fallbackPos, definition: fallbackDef)
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
        // Try to read from shared App Group
        if let sharedDefaults = UserDefaults(suiteName: appGroupID),
           let word = sharedDefaults.string(forKey: "wotd_word"),
           let pos = sharedDefaults.string(forKey: "wotd_pos"),
           let def = sharedDefaults.string(forKey: "wotd_def") {
            return WordOfTheDayEntry(date: Date(), word: word, partOfSpeech: pos, definition: def)
        }

        // Fallback if app hasn't run yet
        return WordOfTheDayEntry(date: Date(), word: fallbackWord, partOfSpeech: fallbackPos, definition: fallbackDef)
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
                            .lineLimit(3)
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
