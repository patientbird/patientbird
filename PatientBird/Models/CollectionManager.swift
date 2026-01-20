import Foundation
import SwiftUI

// MARK: - Collection Manager

@MainActor
class CollectionManager: ObservableObject {
    static let shared = CollectionManager()

    @Published var collection: [CapturedOrganism] = []
    @Published var discoveredSpecies: Set<UUID> = []
    @Published var playerXP: Int = 0
    @Published var playerLevel: Int = 1

    private let saveKey = "wildlife_collection"
    private let discoveredKey = "discovered_species"
    private let xpKey = "player_xp"

    var playerLevelProgress: Double {
        let xpForCurrentLevel = playerLevel * 500
        return Double(playerXP % xpForCurrentLevel) / Double(xpForCurrentLevel)
    }

    var totalCaptured: Int { collection.count }

    var uniqueSpeciesCount: Int { discoveredSpecies.count }

    var animalCount: Int { collection.filter { $0.species.kingdom == .animal }.count }
    var plantCount: Int { collection.filter { $0.species.kingdom == .plant }.count }
    var fungiCount: Int { collection.filter { $0.species.kingdom == .fungi }.count }

    init() {
        loadCollection()
        // Add some starter creatures for demo purposes if empty
        if collection.isEmpty {
            addStarterCollection()
        }
    }

    // MARK: - Capture

    func capture(species: Species, location: String? = nil) -> CapturedOrganism {
        let organism = CapturedOrganism(
            species: species,
            captureLocation: location
        )

        collection.append(organism)
        discoveredSpecies.insert(species.id)

        // Award XP
        addPlayerXP(species.rarity.captureXP)

        saveCollection()
        return organism
    }

    // MARK: - Interactions

    func feed(organism: CapturedOrganism) {
        guard let index = collection.firstIndex(where: { $0.id == organism.id }) else { return }
        collection[index].feed()
        saveCollection()
    }

    func play(with organism: CapturedOrganism) {
        guard let index = collection.firstIndex(where: { $0.id == organism.id }) else { return }
        collection[index].play()
        saveCollection()
    }

    func train(organism: CapturedOrganism) {
        guard let index = collection.firstIndex(where: { $0.id == organism.id }) else { return }
        collection[index].train()
        saveCollection()
    }

    func pet(organism: CapturedOrganism) {
        guard let index = collection.firstIndex(where: { $0.id == organism.id }) else { return }
        collection[index].pet()
        saveCollection()
    }

    func rename(organism: CapturedOrganism, to name: String) {
        guard let index = collection.firstIndex(where: { $0.id == organism.id }) else { return }
        collection[index].nickname = name.isEmpty ? nil : name
        saveCollection()
    }

    func release(organism: CapturedOrganism) {
        collection.removeAll { $0.id == organism.id }
        saveCollection()
    }

    // MARK: - Filtering

    func organisms(in habitat: Habitat) -> [CapturedOrganism] {
        collection.filter { $0.species.habitat == habitat }
    }

    func organisms(of kingdom: OrganismKingdom) -> [CapturedOrganism] {
        collection.filter { $0.species.kingdom == kingdom }
    }

    func organismsNeedingAttention() -> [CapturedOrganism] {
        collection.filter { $0.needsAttention }
    }

    // MARK: - Player XP

    private func addPlayerXP(_ amount: Int) {
        playerXP += amount
        let xpPerLevel = 500
        while playerXP >= playerLevel * xpPerLevel {
            playerXP -= playerLevel * xpPerLevel
            playerLevel += 1
        }
    }

    // MARK: - Time Decay

    func applyTimeDecay() {
        for index in collection.indices {
            collection[index].applyTimeDecay()
        }
        saveCollection()
    }

    // MARK: - Persistence

    private func saveCollection() {
        if let encoded = try? JSONEncoder().encode(collection) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
        if let encodedDiscovered = try? JSONEncoder().encode(Array(discoveredSpecies)) {
            UserDefaults.standard.set(encodedDiscovered, forKey: discoveredKey)
        }
        UserDefaults.standard.set(playerXP, forKey: xpKey)
        UserDefaults.standard.set(playerLevel, forKey: "player_level")
    }

    private func loadCollection() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([CapturedOrganism].self, from: data) {
            collection = decoded
        }
        if let data = UserDefaults.standard.data(forKey: discoveredKey),
           let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            discoveredSpecies = Set(decoded)
        }
        playerXP = UserDefaults.standard.integer(forKey: xpKey)
        playerLevel = max(1, UserDefaults.standard.integer(forKey: "player_level"))
    }

    // MARK: - Demo Data

    private func addStarterCollection() {
        // Add a few starter organisms so the virtual world isn't empty
        let starterSpecies = [
            SpeciesDatabase.animals.first { $0.rarity == .common }!,
            SpeciesDatabase.plants.first { $0.rarity == .common }!,
            SpeciesDatabase.fungi.first { $0.rarity == .common }!
        ]

        for species in starterSpecies {
            let organism = CapturedOrganism(
                species: species,
                captureLocation: "Starter Park"
            )
            collection.append(organism)
            discoveredSpecies.insert(species.id)
        }
        saveCollection()
    }
}
