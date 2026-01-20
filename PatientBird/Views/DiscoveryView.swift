import SwiftUI

struct DiscoveryView: View {
    @ObservedObject var collectionManager = CollectionManager.shared

    @State private var isScanning = false
    @State private var discoveredSpecies: Species?
    @State private var showCaptureResult = false
    @State private var capturedOrganism: CapturedOrganism?
    @State private var scanProgress: Double = 0
    @State private var selectedKingdom: OrganismKingdom?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.green.opacity(0.3), Color.blue.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Stats header
                    statsHeader

                    // Kingdom filter
                    kingdomFilter

                    Spacer()

                    // Scanner area
                    scannerArea

                    Spacer()

                    // Scan button
                    scanButton
                }
                .padding()
            }
            .navigationTitle("Discover")
            .sheet(isPresented: $showCaptureResult) {
                if let organism = capturedOrganism {
                    CaptureResultView(organism: organism)
                }
            }
        }
    }

    // MARK: - Stats Header

    private var statsHeader: some View {
        HStack(spacing: 16) {
            StatBadge(
                icon: "star.fill",
                value: "\(collectionManager.playerLevel)",
                label: "Level",
                color: .yellow
            )

            StatBadge(
                icon: "leaf.fill",
                value: "\(collectionManager.uniqueSpeciesCount)",
                label: "Species",
                color: .green
            )

            StatBadge(
                icon: "heart.fill",
                value: "\(collectionManager.totalCaptured)",
                label: "Collection",
                color: .pink
            )
        }
    }

    // MARK: - Kingdom Filter

    private var kingdomFilter: some View {
        HStack(spacing: 12) {
            ForEach(OrganismKingdom.allCases, id: \.self) { kingdom in
                Button {
                    withAnimation {
                        if selectedKingdom == kingdom {
                            selectedKingdom = nil
                        } else {
                            selectedKingdom = kingdom
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: kingdom.icon)
                        Text(kingdom.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(selectedKingdom == kingdom ? kingdom.color : Color.white.opacity(0.8))
                    )
                    .foregroundColor(selectedKingdom == kingdom ? .white : .primary)
                }
            }
        }
    }

    // MARK: - Scanner Area

    private var scannerArea: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 4)
                .frame(width: 280, height: 280)

            // Progress ring
            Circle()
                .trim(from: 0, to: scanProgress)
                .stroke(
                    LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: scanProgress)

            // Inner content
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 240, height: 240)
                    .shadow(color: .black.opacity(0.1), radius: 10)

                if isScanning {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.green)
                        Text("Scanning...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                } else if let species = discoveredSpecies {
                    VStack(spacing: 8) {
                        Text(species.emoji)
                            .font(.system(size: 60))

                        Text(species.commonName)
                            .font(.headline)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 4) {
                            Image(systemName: species.kingdom.icon)
                                .foregroundColor(species.kingdom.color)
                            Text(species.rarity.rawValue)
                                .foregroundColor(species.rarity.color)
                                .fontWeight(.semibold)
                        }
                        .font(.caption)
                    }
                    .padding()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("Tap to scan")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }

            // Scanning animation rings
            if isScanning {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                        .frame(width: 240 + CGFloat(index * 40), height: 240 + CGFloat(index * 40))
                        .scaleEffect(isScanning ? 1.2 : 1.0)
                        .opacity(isScanning ? 0 : 1)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.3),
                            value: isScanning
                        )
                }
            }
        }
    }

    // MARK: - Scan Button

    private var scanButton: some View {
        Button {
            if discoveredSpecies != nil && !isScanning {
                captureOrganism()
            } else if !isScanning {
                startScan()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: discoveredSpecies != nil ? "plus.circle.fill" : "camera.viewfinder")
                Text(discoveredSpecies != nil ? "Capture!" : "Start Scan")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(discoveredSpecies != nil ? Color.orange : Color.green)
            )
            .foregroundColor(.white)
        }
        .disabled(isScanning)
        .opacity(isScanning ? 0.6 : 1)
    }

    // MARK: - Actions

    private func startScan() {
        isScanning = true
        discoveredSpecies = nil
        scanProgress = 0

        // Simulate scanning with progress
        let totalDuration = 2.0
        let steps = 20
        let stepDuration = totalDuration / Double(steps)

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                withAnimation {
                    scanProgress = Double(step) / Double(steps)
                }

                if step == steps {
                    completeScan()
                }
            }
        }
    }

    private func completeScan() {
        // Determine what was found
        if let kingdom = selectedKingdom {
            discoveredSpecies = SpeciesDatabase.randomSpecies(from: kingdom)
        } else {
            discoveredSpecies = SpeciesDatabase.randomSpecies()
        }

        isScanning = false
    }

    private func captureOrganism() {
        guard let species = discoveredSpecies else { return }

        let organism = collectionManager.capture(species: species, location: "Wild Discovery")
        capturedOrganism = organism
        showCaptureResult = true

        // Reset for next scan
        discoveredSpecies = nil
        scanProgress = 0
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(value)
                    .fontWeight(.bold)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
        )
    }
}

// MARK: - Capture Result View

struct CaptureResultView: View {
    let organism: CapturedOrganism
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Celebration
            Text("🎉")
                .font(.system(size: 60))

            Text("Captured!")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Species card
            VStack(spacing: 16) {
                Text(organism.species.emoji)
                    .font(.system(size: 80))

                Text(organism.species.commonName)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(organism.species.scientificName)
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.gray)

                HStack(spacing: 16) {
                    Label(organism.species.kingdom.rawValue, systemImage: organism.species.kingdom.icon)
                        .foregroundColor(organism.species.kingdom.color)

                    Label(organism.species.rarity.rawValue, systemImage: "sparkles")
                        .foregroundColor(organism.species.rarity.color)
                }
                .font(.caption)

                Text("+\(organism.species.rarity.captureXP) XP")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: organism.species.rarity.color.opacity(0.3), radius: 20)
            )
            .padding(.horizontal)

            // Fun fact
            VStack(spacing: 8) {
                Text("Did you know?")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(organism.species.funFact)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .padding()

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green)
                    )
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [organism.species.rarity.color.opacity(0.2), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    DiscoveryView()
}
