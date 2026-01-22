import SwiftUI

struct DefinitionView: View {
    let entry: DictionaryEntry
    let isDarkMode: Bool
    let fontDesign: Font.Design

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
                        .font(.system(size: 32, weight: .bold, design: fontDesign))
                        .foregroundColor(textColor)

                    if let phonetic = entry.phonetic, !phonetic.isEmpty {
                        Text(phonetic)
                            .font(.system(size: 18, design: fontDesign))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 24)

                // Meanings
                ForEach(entry.meanings) { meaning in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(meaning.partOfSpeech)
                            .font(.system(size: 14, weight: .semibold, design: fontDesign))
                            .foregroundColor(badgeText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(badgeBackground)
                            .cornerRadius(4)

                        ForEach(Array(meaning.definitions.prefix(3).enumerated()), id: \.element.id) { index, definition in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(definition.definition)
                                    .font(.system(size: 16, design: fontDesign))
                                    .foregroundColor(textColor)
                                    .fixedSize(horizontal: false, vertical: true)

                                if let example = definition.example, !example.isEmpty {
                                    Text("\"\(example)\"")
                                        .font(.system(size: 15, design: fontDesign))
                                        .italic()
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.leading, 4)

                            if index < min(meaning.definitions.count, 3) - 1 {
                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
    }
}
