import SwiftUI

enum FontChoice: String, CaseIterable {
    case sans = "sans"
    case serif = "serif"
    case mono = "mono"

    var displayName: String {
        switch self {
        case .sans: return "Aa"
        case .serif: return "Aa"
        case .mono: return "Aa"
        }
    }

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
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontChoice") private var fontChoice: String = FontChoice.sans.rawValue

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
        isDarkMode ? .gray : .gray
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
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
                    searchField
                    Spacer()
                } else {
                    VStack(spacing: 0) {
                        searchField
                            .padding(.top, 20)

                        if let error = errorMessage {
                            Spacer()
                            Text(error)
                                .foregroundColor(secondaryTextColor)
                                .font(.system(.body, design: selectedFont.design))
                            Spacer()
                        } else if let entry = entry {
                            DefinitionView(entry: entry, isDarkMode: isDarkMode, fontDesign: selectedFont.design)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .background(backgroundColor)
        }
    }

    private var searchField: some View {
        HStack {
            TextField("Search word", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 18, design: selectedFont.design))
                .foregroundColor(textColor)
                .disabled(!dictionaryService.isLoaded)
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
                        .foregroundColor(secondaryTextColor)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(textColor, lineWidth: 1.5)
        )
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
