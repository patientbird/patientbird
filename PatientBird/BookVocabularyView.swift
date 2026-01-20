import SwiftUI

struct BookVocabularyView: View {
    let bookId: String

    @State private var vocabulary: BookVocabulary?
    @State private var selectedDifficulty: WordDifficulty?
    @State private var searchText = ""

    private var filteredWords: [VocabularyWord] {
        guard let vocab = vocabulary else { return [] }

        var words = vocab.words

        if let difficulty = selectedDifficulty {
            words = words.filter { $0.difficulty == difficulty }
        }

        if !searchText.isEmpty {
            words = words.filter { $0.word.localizedCaseInsensitiveContains(searchText) }
        }

        return words.sorted { $0.word < $1.word }
    }

    var body: some View {
        Group {
            if let vocab = vocabulary {
                ScrollView {
                    VStack(spacing: 0) {
                        headerSection(vocab)
                        filterSection(vocab)
                        wordList
                    }
                }
                .background(Color.white)
            } else {
                ProgressView()
                    .tint(.black)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vocabulary = BookService.shared.getVocabulary(for: bookId)
        }
    }

    private func headerSection(_ vocab: BookVocabulary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(vocab.book.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)

            Text(vocab.book.author)
                .font(.system(size: 16))
                .foregroundColor(.gray)

            Text("\(vocab.words.count) vocabulary words to study")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    private func filterSection(_ vocab: BookVocabulary) -> some View {
        VStack(spacing: 12) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search words", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            // Difficulty filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All",
                        count: vocab.words.count,
                        isSelected: selectedDifficulty == nil
                    ) {
                        selectedDifficulty = nil
                    }

                    ForEach(WordDifficulty.allCases.sorted(by: { $0.sortOrder < $1.sortOrder }), id: \.self) { difficulty in
                        let count = vocab.wordsByDifficulty[difficulty]?.count ?? 0
                        if count > 0 {
                            FilterChip(
                                title: difficulty.rawValue,
                                count: count,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                selectedDifficulty = difficulty
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var wordList: some View {
        LazyVStack(spacing: 0) {
            ForEach(filteredWords) { word in
                NavigationLink(destination: WordDetailView(word: word)) {
                    WordRow(word: word)
                }
                .buttonStyle(.plain)

                if word.id != filteredWords.last?.id {
                    Divider()
                        .padding(.leading, 20)
                }
            }
        }
        .background(Color.white)
    }
}

struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                Text("\(count)")
                    .opacity(0.7)
            }
            .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            .foregroundColor(isSelected ? .white : .black)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.black : Color(.systemGray6))
            .cornerRadius(20)
        }
    }
}

struct WordRow: View {
    let word: VocabularyWord

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(word.word)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black)

                    if word.isNeologism {
                        Text("coined")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black)
                            .cornerRadius(3)
                    }
                }

                if let context = word.context {
                    Text(context)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white)
    }
}

#Preview {
    NavigationStack {
        BookVocabularyView(bookId: "frankenstein")
    }
}
