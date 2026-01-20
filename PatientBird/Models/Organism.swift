import Foundation
import SwiftUI

// MARK: - Organism Types

enum OrganismKingdom: String, Codable, CaseIterable {
    case animal = "Animal"
    case plant = "Plant"
    case fungi = "Fungi"

    var icon: String {
        switch self {
        case .animal: return "pawprint.fill"
        case .plant: return "leaf.fill"
        case .fungi: return "atom"
        }
    }

    var color: Color {
        switch self {
        case .animal: return .orange
        case .plant: return .green
        case .fungi: return .purple
        }
    }
}

enum Rarity: String, Codable, CaseIterable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"

    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }

    var captureXP: Int {
        switch self {
        case .common: return 10
        case .uncommon: return 25
        case .rare: return 50
        case .epic: return 100
        case .legendary: return 250
        }
    }
}

enum Habitat: String, Codable, CaseIterable {
    case forest = "Forest"
    case meadow = "Meadow"
    case wetland = "Wetland"
    case mountain = "Mountain"
    case desert = "Desert"
    case ocean = "Ocean"
    case urban = "Urban"
    case garden = "Garden"

    var icon: String {
        switch self {
        case .forest: return "tree.fill"
        case .meadow: return "leaf.fill"
        case .wetland: return "drop.fill"
        case .mountain: return "mountain.2.fill"
        case .desert: return "sun.max.fill"
        case .ocean: return "water.waves"
        case .urban: return "building.2.fill"
        case .garden: return "camera.macro"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .forest: return Color(red: 0.13, green: 0.37, blue: 0.13)
        case .meadow: return Color(red: 0.56, green: 0.73, blue: 0.35)
        case .wetland: return Color(red: 0.25, green: 0.41, blue: 0.47)
        case .mountain: return Color(red: 0.47, green: 0.47, blue: 0.53)
        case .desert: return Color(red: 0.82, green: 0.71, blue: 0.45)
        case .ocean: return Color(red: 0.15, green: 0.35, blue: 0.60)
        case .urban: return Color(red: 0.45, green: 0.45, blue: 0.45)
        case .garden: return Color(red: 0.60, green: 0.75, blue: 0.50)
        }
    }
}

// MARK: - Species Definition

struct Species: Identifiable, Codable, Hashable {
    let id: UUID
    let commonName: String
    let scientificName: String
    let kingdom: OrganismKingdom
    let rarity: Rarity
    let habitat: Habitat
    let description: String
    let funFact: String
    let emoji: String

    // Training attributes
    let maxEnergy: Int
    let maxHappiness: Int
    let growthRate: Double // How fast it levels up

    init(
        id: UUID = UUID(),
        commonName: String,
        scientificName: String,
        kingdom: OrganismKingdom,
        rarity: Rarity,
        habitat: Habitat,
        description: String,
        funFact: String,
        emoji: String,
        maxEnergy: Int = 100,
        maxHappiness: Int = 100,
        growthRate: Double = 1.0
    ) {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.kingdom = kingdom
        self.rarity = rarity
        self.habitat = habitat
        self.description = description
        self.funFact = funFact
        self.emoji = emoji
        self.maxEnergy = maxEnergy
        self.maxHappiness = maxHappiness
        self.growthRate = growthRate
    }
}

// MARK: - Captured Organism (Instance in your collection)

struct CapturedOrganism: Identifiable, Codable {
    let id: UUID
    let species: Species
    let captureDate: Date
    let captureLocation: String?

    // Dynamic stats
    var nickname: String?
    var level: Int
    var experience: Int
    var energy: Int
    var happiness: Int
    var lastInteraction: Date
    var lastFed: Date
    var trainingSessions: Int

    var displayName: String {
        nickname ?? species.commonName
    }

    var experienceToNextLevel: Int {
        level * 100
    }

    var experienceProgress: Double {
        Double(experience) / Double(experienceToNextLevel)
    }

    var energyPercent: Double {
        Double(energy) / Double(species.maxEnergy)
    }

    var happinessPercent: Double {
        Double(happiness) / Double(species.maxHappiness)
    }

    var needsAttention: Bool {
        let hoursSinceInteraction = Date().timeIntervalSince(lastInteraction) / 3600
        return hoursSinceInteraction > 12 || happiness < 30 || energy < 30
    }

    var mood: Mood {
        let avgStat = (happinessPercent + energyPercent) / 2
        if avgStat > 0.8 { return .ecstatic }
        if avgStat > 0.6 { return .happy }
        if avgStat > 0.4 { return .content }
        if avgStat > 0.2 { return .sad }
        return .distressed
    }

    init(
        id: UUID = UUID(),
        species: Species,
        captureDate: Date = Date(),
        captureLocation: String? = nil,
        nickname: String? = nil,
        level: Int = 1,
        experience: Int = 0,
        energy: Int = 80,
        happiness: Int = 80,
        lastInteraction: Date = Date(),
        lastFed: Date = Date(),
        trainingSessions: Int = 0
    ) {
        self.id = id
        self.species = species
        self.captureDate = captureDate
        self.captureLocation = captureLocation
        self.nickname = nickname
        self.level = level
        self.experience = experience
        self.energy = energy
        self.happiness = happiness
        self.lastInteraction = lastInteraction
        self.lastFed = lastFed
        self.trainingSessions = trainingSessions
    }

    enum Mood: String {
        case ecstatic = "Ecstatic"
        case happy = "Happy"
        case content = "Content"
        case sad = "Sad"
        case distressed = "Distressed"

        var emoji: String {
            switch self {
            case .ecstatic: return "🌟"
            case .happy: return "😊"
            case .content: return "😐"
            case .sad: return "😢"
            case .distressed: return "😰"
            }
        }

        var color: Color {
            switch self {
            case .ecstatic: return .yellow
            case .happy: return .green
            case .content: return .blue
            case .sad: return .orange
            case .distressed: return .red
            }
        }
    }

    // MARK: - Interactions

    mutating func feed() {
        energy = min(species.maxEnergy, energy + 30)
        happiness = min(species.maxHappiness, happiness + 10)
        lastFed = Date()
        lastInteraction = Date()
        addExperience(5)
    }

    mutating func play() {
        guard energy >= 20 else { return }
        energy -= 20
        happiness = min(species.maxHappiness, happiness + 25)
        lastInteraction = Date()
        addExperience(10)
    }

    mutating func train() {
        guard energy >= 30 else { return }
        energy -= 30
        happiness = min(species.maxHappiness, happiness + 5)
        trainingSessions += 1
        lastInteraction = Date()
        addExperience(Int(20.0 * species.growthRate))
    }

    mutating func pet() {
        happiness = min(species.maxHappiness, happiness + 15)
        lastInteraction = Date()
        addExperience(3)
    }

    private mutating func addExperience(_ amount: Int) {
        experience += amount
        while experience >= experienceToNextLevel {
            experience -= experienceToNextLevel
            level += 1
        }
    }

    mutating func applyTimeDecay() {
        let hoursSinceInteraction = Date().timeIntervalSince(lastInteraction) / 3600
        let hoursSinceFed = Date().timeIntervalSince(lastFed) / 3600

        // Decay rates per hour
        let happinessDecay = Int(hoursSinceInteraction * 2)
        let energyDecay = Int(hoursSinceFed * 3)

        happiness = max(0, happiness - happinessDecay)
        energy = max(0, energy - energyDecay)
    }
}
