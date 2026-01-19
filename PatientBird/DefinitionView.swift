import SwiftUI

struct DefinitionView: View {
    let entry: DictionaryEntry
    let isDarkMode: Bool

    private var textColor: Color {
        isDarkMode ? .white : .black
    }

    private var badgeBackground: Color {
        isDarkMode ? .white : .black
    }

    private var badgeText: Color {
        isDarkMode ? .black : .white
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Word and phonetic
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.word)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(textColor)

                    if let phonetic = entry.phonetic, !phonetic.isEmpty {
                        Text(phonetic)
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 24)

                // Meanings
                ForEach(entry.meanings) { meaning in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(meaning.partOfSpeech)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(badgeText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(badgeBackground)
                            .cornerRadius(4)

                        ForEach(Array(meaning.definitions.prefix(3).enumerated()), id: \.element.id) { _, definition in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(definition.definition)
                                    .font(.system(size: 16))
                                    .foregroundColor(textColor)
                                    .fixedSize(horizontal: false, vertical: true)

                                if let example = definition.example, !example.isEmpty {
                                    Text("\"\(example)\"")
                                        .font(.system(size: 15))
                                        .italic()
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.leading, 4)
                        }
                    }
                }

                Spacer(minLength: 40)
            }
        }
        .scrollIndicators(.hidden)
    }
}
