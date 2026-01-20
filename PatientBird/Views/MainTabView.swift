import SwiftUI

struct MainTabView: View {
    @StateObject private var collectionManager = CollectionManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoveryView()
                .tabItem {
                    Label("Discover", systemImage: "camera.viewfinder")
                }
                .tag(0)

            SanctuaryView()
                .tabItem {
                    Label("Sanctuary", systemImage: "globe.americas.fill")
                }
                .tag(1)
                .badge(collectionManager.organismsNeedingAttention().count)

            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "square.grid.2x2.fill")
                }
                .tag(2)
        }
        .environmentObject(collectionManager)
        .onAppear {
            // Apply time decay when app opens
            collectionManager.applyTimeDecay()
        }
    }
}

#Preview {
    MainTabView()
}
