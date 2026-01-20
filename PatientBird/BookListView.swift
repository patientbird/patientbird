import SwiftUI

struct BookListView: View {
    private let books = BookService.shared.getAllBooks()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection

                    LazyVStack(spacing: 16) {
                        ForEach(books) { book in
                            NavigationLink(destination: BookVocabularyView(bookId: book.id)) {
                                BookCard(book: book)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .background(Color.white)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Book Vocab")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)

            Text("Preview vocabulary before you read")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }
}

struct BookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)

                    Text(book.author)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(book.displayYear)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.black)
                    .cornerRadius(4)
            }

            Text(book.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(2)

            if book.wordCount > 0 {
                HStack(spacing: 16) {
                    Label("\(formatWordCount(book.wordCount)) words", systemImage: "doc.text")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)

                    if let vocabulary = BookService.shared.getVocabulary(for: book.id) {
                        Label("\(vocabulary.words.count) vocab", systemImage: "textformat.abc")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            } else if let vocabulary = BookService.shared.getVocabulary(for: book.id) {
                Label("\(vocabulary.words.count) words", systemImage: "textformat.abc")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private func formatWordCount(_ count: Int) -> String {
        if count >= 1000 {
            return "\(count / 1000)k"
        }
        return "\(count)"
    }
}

#Preview {
    BookListView()
}
