import SwiftUI

struct SanctuaryView: View {
    @ObservedObject var collectionManager = CollectionManager.shared

    @State private var selectedHabitat: Habitat = .forest
    @State private var selectedOrganism: CapturedOrganism?
    @State private var showHabitatPicker = false

    var organismsInHabitat: [CapturedOrganism] {
        collectionManager.organisms(in: selectedHabitat)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Habitat background
                habitatBackground

                VStack(spacing: 0) {
                    // Habitat selector
                    habitatSelector
                        .padding()

                    // Main sanctuary area
                    if organismsInHabitat.isEmpty {
                        emptyHabitat
                    } else {
                        sanctuaryArea
                    }

                    // Bottom info bar
                    habitatInfoBar
                        .padding()
                }
            }
            .navigationTitle("Sanctuary")
            .sheet(item: $selectedOrganism) { organism in
                OrganismDetailView(organism: organism)
            }
        }
    }

    // MARK: - Habitat Background

    private var habitatBackground: some View {
        ZStack {
            selectedHabitat.backgroundColor
                .ignoresSafeArea()

            // Decorative elements based on habitat
            VStack {
                Spacer()
                HStack {
                    ForEach(0..<5, id: \.self) { _ in
                        Text(habitatDecoration)
                            .font(.system(size: 30))
                            .opacity(0.3)
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }

    private var habitatDecoration: String {
        switch selectedHabitat {
        case .forest: return "🌲"
        case .meadow: return "🌸"
        case .wetland: return "🌿"
        case .mountain: return "⛰️"
        case .desert: return "🌵"
        case .ocean: return "🌊"
        case .urban: return "🏢"
        case .garden: return "🌷"
        }
    }

    // MARK: - Habitat Selector

    private var habitatSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Habitat.allCases, id: \.self) { habitat in
                    let count = collectionManager.organisms(in: habitat).count
                    HabitatTab(
                        habitat: habitat,
                        count: count,
                        isSelected: selectedHabitat == habitat
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedHabitat = habitat
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty Habitat

    private var emptyHabitat: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: selectedHabitat.icon)
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))

            Text("No creatures in this habitat")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))

            Text("Capture some \(selectedHabitat.rawValue.lowercased()) wildlife!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))

            Spacer()
        }
    }

    // MARK: - Sanctuary Area

    private var sanctuaryArea: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(organismsInHabitat.enumerated()), id: \.element.id) { index, organism in
                    OrganismSprite(organism: organism)
                        .position(
                            x: spritePosition(for: index, in: geometry.size).x,
                            y: spritePosition(for: index, in: geometry.size).y
                        )
                        .onTapGesture {
                            selectedOrganism = organism
                        }
                }
            }
        }
    }

    private func spritePosition(for index: Int, in size: CGSize) -> CGPoint {
        // Distribute organisms across the habitat area
        let columns = 3
        let row = index / columns
        let col = index % columns

        let xSpacing = size.width / CGFloat(columns + 1)
        let ySpacing: CGFloat = 120

        let xOffset = CGFloat.random(in: -20...20)
        let yOffset = CGFloat.random(in: -10...10)

        return CGPoint(
            x: xSpacing * CGFloat(col + 1) + xOffset,
            y: 80 + CGFloat(row) * ySpacing + yOffset
        )
    }

    // MARK: - Habitat Info Bar

    private var habitatInfoBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedHabitat.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(organismsInHabitat.count) creatures living here")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            // Needs attention badge
            let needsAttention = organismsInHabitat.filter { $0.needsAttention }.count
            if needsAttention > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("\(needsAttention)")
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.red.opacity(0.8))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
        )
    }
}

// MARK: - Habitat Tab

struct HabitatTab: View {
    let habitat: Habitat
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: habitat.icon)
                    .font(.system(size: 20))

                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .frame(width: 60, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.3))
            )
            .foregroundColor(isSelected ? habitat.backgroundColor : .white)
        }
    }
}

// MARK: - Organism Sprite

struct OrganismSprite: View {
    let organism: CapturedOrganism

    @State private var isAnimating = false
    @State private var bounceOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 4) {
            // Mood indicator
            if organism.needsAttention {
                Text("❗")
                    .font(.caption)
                    .offset(y: isAnimating ? -5 : 0)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }

            // Organism emoji with animation
            Text(organism.species.emoji)
                .font(.system(size: 50))
                .offset(y: bounceOffset)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 4)

            // Name tag
            Text(organism.displayName)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.5))
                )

            // Level badge
            Text("Lv.\(organism.level)")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.8))
        }
        .onAppear {
            isAnimating = true
            startIdleAnimation()
        }
    }

    private func startIdleAnimation() {
        // Random idle bouncing
        let delay = Double.random(in: 0...2)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(
                .easeInOut(duration: 0.3)
                .repeatForever(autoreverses: true)
            ) {
                bounceOffset = -8
            }
        }
    }
}

#Preview {
    SanctuaryView()
}
