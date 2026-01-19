import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var entry: DictionaryEntry?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if entry == nil && !isLoading && errorMessage == nil {
                    Spacer()
                    searchField
                    Spacer()
                } else {
                    VStack(spacing: 0) {
                        searchField
                            .padding(.top, 20)

                        if isLoading {
                            Spacer()
                            ProgressView()
                                .tint(.black)
                            Spacer()
                        } else if let error = errorMessage {
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

        isLoading = true
        errorMessage = nil
        entry = nil

        Task {
            do {
                let result = try await DictionaryService.shared.lookup(query)
                await MainActor.run {
                    entry = result
                    isLoading = false
                }
            } catch let error as DictionaryError {
                await MainActor.run {
                    errorMessage = error.errorDescription
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Something went wrong"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
