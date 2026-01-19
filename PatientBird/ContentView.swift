import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var entry: DictionaryEntry?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if entry == nil && errorMessage == nil {
                    Spacer()
                    searchField
                    Spacer()
                } else {
                    VStack(spacing: 0) {
                        searchField
                            .padding(.top, 20)

                        if let error = errorMessage {
                            Spacer()
                            Text(error)
                                .foregroundColor(.gray)
                                .font(.body)
                            Spacer()
                        } else if let entry = entry {
                            DefinitionView(entry: entry)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .background(Color.white)
        }
    }

    private var searchField: some View {
        HStack {
            TextField("Search word", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 18))
                .foregroundColor(.black)
                .onSubmit {
                    search()
                }

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    entry = nil
                    errorMessage = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1.5)
        )
    }

    private func search() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        errorMessage = nil
        entry = nil

        do {
            entry = try DictionaryService.shared.lookup(query)
        } catch let error as DictionaryError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Something went wrong"
        }
    }
}

#Preview {
    ContentView()
}
