import SwiftUI

enum FontChoice: String, CaseIterable {
    case sans = "sans"
    case serif = "serif"
    case mono = "mono"

    var design: Font.Design {
        switch self {
        case .sans: return .default
        case .serif: return .serif
        case .mono: return .monospaced
        }
    }
}

struct ContentView: View {
    @StateObject private var dictionaryService = DictionaryService.shared
    @State private var searchText = ""
    @State private var entry: DictionaryEntry?
    @State private var errorMessage: String?
    @State private var recentSearchesCache: [String] = []
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontChoice") private var fontChoice: String = FontChoice.sans.rawValue
    @AppStorage("recentSearches") private var recentSearchesData: Data = Data()
    @FocusState private var isSearchFocused: Bool

    private var selectedFont: FontChoice {
        FontChoice(rawValue: fontChoice) ?? .sans
    }

    private var backgroundColor: Color {
        isDarkMode ? .black : Color(red: 0.98, green: 0.96, blue: 0.92)
    }

    private var textColor: Color {
        isDarkMode ? .white : .black
    }

    private var secondaryTextColor: Color {
        .gray
    }

    private var showRecentSearches: Bool {
        isSearchFocused && searchText.isEmpty && !recentSearchesCache.isEmpty && entry == nil && errorMessage == nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                    .onTapGesture {
                        isSearchFocused = false
                    }

                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        if entry != nil || errorMessage != nil {
                            Button(action: resetToHome) {
                                Image(systemName: "house")
                                    .font(.system(size: 18))
                                    .foregroundColor(textColor)
                            }
                        }
                        Spacer()
                        Button(action: {
                            cycleFont()
                        }) {
                            Text("Aa")
                                .font(.system(size: 18, design: selectedFont.design))
                                .foregroundColor(textColor)
                        }
                        Button(action: {
                            isDarkMode.toggle()
                        }) {
                            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 20))
                                .foregroundColor(textColor)
                        }
                    }
                    .padding(.top, 12)

                    if entry == nil && errorMessage == nil {
                        Spacer()
                        if dictionaryService.loadFailed {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                Text("Failed to load dictionary")
                                    .font(.system(.body, design: selectedFont.design))
                                    .foregroundColor(secondaryTextColor)
                            }
                        } else if !dictionaryService.isLoaded {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Loading dictionary...")
                                    .font(.system(.body, design: selectedFont.design))
                                    .foregroundColor(secondaryTextColor)
                            }
                        } else {
                            VStack(spacing: 0) {
                                searchField
                                if showRecentSearches {
                                    recentSearchesView
                                }
                            }
                        }
                        Spacer()
                    } else {
                        VStack(spacing: 0) {
                            searchField
                                .padding(.top, 20)

                            if let error = errorMessage {
                                Spacer()
                                VStack(spacing: 20) {
                                    Text(error)
                                        .foregroundColor(secondaryTextColor)
                                        .font(.system(.body, design: selectedFont.design))

                                    if error == DictionaryError.wordNotFound.errorDescription {
                                        HStack(spacing: 16) {
                                            Button(action: openWikipedia) {
                                                Label("Wikipedia", systemImage: "book.closed")
                                                    .font(.system(.subheadline, design: selectedFont.design))
                                            }
                                            .buttonStyle(.bordered)
                                            .tint(textColor)

                                            Button(action: openWebSearch) {
                                                Label("Search Web", systemImage: "magnifyingglass")
                                                    .font(.system(.subheadline, design: selectedFont.design))
                                            }
                                            .buttonStyle(.bordered)
                                            .tint(textColor)
                                        }
                                    }
                                }
                                Spacer()
                            } else if let entry = entry {
                                DefinitionView(entry: entry, isDarkMode: isDarkMode, fontDesign: selectedFont.design)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            loadRecentSearches()
        }
    }

    private var searchField: some View {
        HStack {
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search word")
                        .font(.system(size: 18, design: selectedFont.design))
                        .foregroundColor(isDarkMode ? .gray : .gray)
                }
                TextField("", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: 18, design: selectedFont.design))
                    .foregroundColor(textColor)
                    .disabled(!dictionaryService.isLoaded)
                    .focused($isSearchFocused)
                    .onSubmit {
                        search()
                    }
            }

            if !searchText.isEmpty {
                Button(action: clearSearch) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(secondaryTextColor)
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(textColor, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isSearchFocused = true
        }
        .opacity(dictionaryService.isLoaded ? 1 : 0.5)
    }

    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(recentSearchesCache, id: \.self) { word in
                Button(action: {
                    searchText = word
                    search()
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14))
                            .foregroundColor(secondaryTextColor)
                        Text(word)
                            .font(.system(size: 16, design: selectedFont.design))
                            .foregroundColor(textColor)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                }
            }

            Button(action: {
                clearRecentSearches()
            }) {
                Text("Clear history")
                    .font(.system(size: 14, design: selectedFont.design))
                    .foregroundColor(secondaryTextColor)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.top, 8)
    }

    private func loadRecentSearches() {
        recentSearchesCache = (try? JSONDecoder().decode([String].self, from: recentSearchesData)) ?? []
    }

    private func saveRecentSearches() {
        recentSearchesData = (try? JSONEncoder().encode(recentSearchesCache)) ?? Data()
    }

    private func clearRecentSearches() {
        recentSearchesCache = []
        saveRecentSearches()
    }

    private func cycleFont() {
        let allCases = FontChoice.allCases
        if let currentIndex = allCases.firstIndex(of: selectedFont) {
            let nextIndex = (currentIndex + 1) % allCases.count
            fontChoice = allCases[nextIndex].rawValue
        }
    }

    private func search() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        isSearchFocused = false
        errorMessage = nil
        entry = nil

        do {
            entry = try DictionaryService.shared.lookup(query)
            addToRecentSearches(query.lowercased())
        } catch let error as DictionaryError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Something went wrong"
        }
    }

    private func addToRecentSearches(_ word: String) {
        recentSearchesCache.removeAll { $0 == word }
        recentSearchesCache.insert(word, at: 0)
        if recentSearchesCache.count > 10 {
            recentSearchesCache = Array(recentSearchesCache.prefix(10))
        }
        saveRecentSearches()
    }

    private func clearSearch() {
        searchText = ""
        entry = nil
        errorMessage = nil
        isSearchFocused = true
    }

    private func resetToHome() {
        searchText = ""
        entry = nil
        errorMessage = nil
        isSearchFocused = false
    }

    private func openWikipedia() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://en.wikipedia.org/wiki/\(encoded)") else {
            return
        }
        UIApplication.shared.open(url)
    }

    private func openWebSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.google.com/search?q=define+\(encoded)") else {
            return
        }
        UIApplication.shared.open(url)
    }
}

#Preview {
    ContentView()
}
