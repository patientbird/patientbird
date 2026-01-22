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
    @State private var showingCredits = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontChoice") private var fontChoice: String = FontChoice.sans.rawValue
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
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                            }
                        }
                        Spacer()
                        Button(action: {
                            cycleFont()
                        }) {
                            Text("Aa")
                                .font(.system(size: 18, design: selectedFont.design))
                                .foregroundColor(textColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        Button(action: {
                            isDarkMode.toggle()
                        }) {
                            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 20))
                                .foregroundColor(textColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
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
                            searchField
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
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    showingCredits = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(textColor)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showingCredits) {
            CreditsView(isDarkMode: isDarkMode, fontDesign: selectedFont.design)
        }
    }

    private var searchField: some View {
        HStack {
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search word")
                        .font(.system(size: 18, design: selectedFont.design))
                        .foregroundColor(.gray)
                }
                TextField("", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: 18, design: selectedFont.design))
                    .foregroundColor(textColor)
                    .tint(textColor)
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
        } catch let error as DictionaryError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Something went wrong"
        }
    }

    private func clearSearch() {
        searchText = ""
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

struct CreditsView: View {
    let isDarkMode: Bool
    let fontDesign: Font.Design
    @Environment(\.dismiss) private var dismiss

    private var backgroundColor: Color {
        isDarkMode ? .black : Color(red: 0.98, green: 0.96, blue: 0.92)
    }

    private var textColor: Color {
        isDarkMode ? .white : .black
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("App developed by PatientBird")
                        .font(.system(size: 22, weight: .bold, design: fontDesign))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 16) {
                        Text("Dictionary Data")
                            .font(.system(size: 18, weight: .semibold, design: fontDesign))
                            .foregroundColor(textColor)

                        Text("Definitions from Wiktionary, licensed under CC BY-SA 4.0")
                            .font(.system(size: 14, design: fontDesign))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

                        Link("View License", destination: URL(string: "https://creativecommons.org/licenses/by-sa/4.0/")!)
                            .font(.system(size: 14, design: fontDesign))
                            .foregroundColor(textColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )

                    Spacer()
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(textColor)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
