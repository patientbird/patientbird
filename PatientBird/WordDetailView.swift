import SwiftUI

struct WordDetailView: View {
    let word: VocabularyWord

    @State private var dictionaryEntry: DictionaryEntry?
    @State private var isLoading = true
    @State private var lookupFailed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Word header
                headerSection

                // Literary context (if available)
                if let context = word.context {
                    contextSection(context)
                }

                // Custom definition for neologisms
                if word.isNeologism, let customDef = word.customDefinition {
                    neologismSection(customDef)
                }

                // Dictionary definition
                dictionarySection

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await lookupWord()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(word.word)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)

                if word.isNeologism {
                    Text("Literary Coinage")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black)
                        .cornerRadius(4)
                }
            }

            HStack(spacing: 12) {
                Text(word.difficulty.rawValue)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                if let entry = dictionaryEntry, let phonetic = entry.phonetic, !phonetic.isEmpty {
                    Text(phonetic)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func contextSection(_ context: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Literary Context")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)

            Text(context)
                .font(.system(size: 15))
                .italic()
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func neologismSection(_ definition: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.black)
                Text("Author's Creation")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }

            Text(definition)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    @ViewBuilder
    private var dictionarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dictionary Definition")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(.black)
                    Spacer()
                }
                .padding(.vertical, 20)
            } else if let entry = dictionaryEntry {
                ForEach(entry.meanings) { meaning in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(meaning.partOfSpeech)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.black)
                            .cornerRadius(4)

                        ForEach(Array(meaning.definitions.prefix(2).enumerated()), id: \.element.id) { index, definition in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(definition.definition)
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: false, vertical: true)

                                if let example = definition.example, !example.isEmpty {
                                    Text("\"\(example)\"")
                                        .font(.system(size: 14))
                                        .italic()
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.leading, 4)
                        }
                    }
                }
            } else if lookupFailed {
                VStack(spacing: 8) {
                    if word.isNeologism {
                        Text("Not in standard dictionaries")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        Text("This word was invented by the author and hasn't entered standard dictionaries yet.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Definition not available")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
    }

    private func lookupWord() async {
        isLoading = true
        lookupFailed = false

        do {
            let entry = try await DictionaryService.shared.lookup(word.word)
            await MainActor.run {
                dictionaryEntry = entry
                isLoading = false
            }
        } catch {
            await MainActor.run {
                lookupFailed = true
                isLoading = false
            }
        }
    }
}

#Preview("Standard Word") {
    NavigationStack {
        WordDetailView(word: VocabularyWord(
            word: "countenance",
            difficulty: .intermediate,
            context: "His countenance bespoke bitter anguish"
        ))
    }
}

#Preview("Neologism") {
    NavigationStack {
        WordDetailView(word: VocabularyWord(
            word: "grotendous",
            difficulty: .literary,
            context: "Snow Crash by Neal Stephenson",
            customDefinition: "A portmanteau of 'grotesque' and 'horrendous' - something so awful it combines the worst of both qualities.",
            isNeologism: true
        ))
    }
}
