import SwiftUI

struct CollectionView: View {
    @ObservedObject var collectionManager = CollectionManager.shared

    @State private var selectedKingdom: OrganismKingdom?
    @State private var sortOption: SortOption = .recent
    @State private var searchText = ""
    @State private var selectedOrganism: CapturedOrganism?

    enum SortOption: String, CaseIterable {
        case recent = "Recent"
        case level = "Level"
        case rarity = "Rarity"
        case name = "Name"
    }

    var filteredCollection: [CapturedOrganism] {
        var result = collectionManager.collection

        // Filter by kingdom
        if let kingdom = selectedKingdom {
            result = result.filter { $0.species.kingdom == kingdom }
        }

        // Filter by search
        if !searchText.isEmpty {
            result = result.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.species.commonName.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        switch sortOption {
        case .recent:
            result.sort { $0.captureDate > $1.captureDate }
        case .level:
            result.sort { $0.level > $1.level }
        case .rarity:
            let rarityOrder: [Rarity] = [.legendary, .epic, .rare, .uncommon, .common]
            result.sort { rarityOrder.firstIndex(of: $0.species.rarity)! < rarityOrder.firstIndex(of: $1.species.rarity)! }
        case .name:
            result.sort { $0.displayName < $1.displayName }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Kingdom filter tabs
                kingdomTabs
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Sort picker
                HStack {
                    Text("\(filteredCollection.count) creatures")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Spacer()

                    Picker("Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Collection grid
                if filteredCollection.isEmpty {
                    emptyState
                } else {
                    collectionGrid
                }
            }
            .navigationTitle("Collection")
            .searchable(text: $searchText, prompt: "Search collection")
            .sheet(item: $selectedOrganism) { organism in
                OrganismDetailView(organism: organism)
            }
        }
    }

    // MARK: - Kingdom Tabs

    private var kingdomTabs: some View {
        HStack(spacing: 8) {
            // All tab
            FilterTab(
                title: "All",
                icon: "square.grid.2x2.fill",
                count: collectionManager.totalCaptured,
                isSelected: selectedKingdom == nil,
                color: .blue
            ) {
                withAnimation { selectedKingdom = nil }
            }

            ForEach(OrganismKingdom.allCases, id: \.self) { kingdom in
                let count = collectionManager.organisms(of: kingdom).count
                FilterTab(
                    title: kingdom.rawValue,
                    icon: kingdom.icon,
                    count: count,
                    isSelected: selectedKingdom == kingdom,
                    color: kingdom.color
                ) {
                    withAnimation { selectedKingdom = kingdom }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "leaf.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))

            Text("No creatures yet")
                .font(.headline)
                .foregroundColor(.gray)

            Text("Go discover some wildlife!")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))

            Spacer()
        }
    }

    // MARK: - Collection Grid

    private var collectionGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(filteredCollection) { organism in
                    OrganismCard(organism: organism)
                        .onTapGesture {
                            selectedOrganism = organism
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Filter Tab

struct FilterTab: View {
    let title: String
    let icon: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? color : .gray)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Organism Card

struct OrganismCard: View {
    let organism: CapturedOrganism

    var body: some View {
        VStack(spacing: 8) {
            // Header with mood indicator
            HStack {
                Text(organism.mood.emoji)
                    .font(.caption)
                Spacer()
                Text("Lv.\(organism.level)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.2))
                    )
            }

            // Emoji
            Text(organism.species.emoji)
                .font(.system(size: 44))

            // Name
            Text(organism.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)

            // Rarity badge
            Text(organism.species.rarity.rawValue)
                .font(.caption2)
                .foregroundColor(organism.species.rarity.color)

            // Stats bars
            HStack(spacing: 8) {
                MiniStatBar(value: organism.energyPercent, color: .orange, icon: "bolt.fill")
                MiniStatBar(value: organism.happinessPercent, color: .pink, icon: "heart.fill")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: organism.needsAttention ? Color.red.opacity(0.3) : Color.black.opacity(0.08), radius: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(organism.needsAttention ? Color.red.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Mini Stat Bar

struct MiniStatBar: View {
    let value: Double
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .foregroundColor(color)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))

                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * value)
                }
            }
            .frame(height: 4)
        }
    }
}

#Preview {
    CollectionView()
}
