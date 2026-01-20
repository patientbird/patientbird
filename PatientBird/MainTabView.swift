import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Dictionary", systemImage: "character.book.closed")
                }

            BookListView()
                .tabItem {
                    Label("Books", systemImage: "books.vertical")
                }
        }
        .tint(.black)
    }
}

#Preview {
    MainTabView()
}
