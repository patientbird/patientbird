import Foundation

// MARK: - Sample Species Database

struct SpeciesDatabase {
    static let all: [Species] = animals + plants + fungi

    // MARK: - Animals

    static let animals: [Species] = [
        // Common
        Species(
            commonName: "American Robin",
            scientificName: "Turdus migratorius",
            kingdom: .animal,
            rarity: .common,
            habitat: .garden,
            description: "A familiar songbird with an orange-red breast.",
            funFact: "Robins can eat up to 14 feet of earthworms in a day!",
            emoji: "🐦"
        ),
        Species(
            commonName: "Eastern Gray Squirrel",
            scientificName: "Sciurus carolinensis",
            kingdom: .animal,
            rarity: .common,
            habitat: .forest,
            description: "An agile rodent known for gathering and storing nuts.",
            funFact: "Squirrels plant thousands of trees each year by forgetting where they buried their acorns.",
            emoji: "🐿️"
        ),
        Species(
            commonName: "Monarch Butterfly",
            scientificName: "Danaus plexippus",
            kingdom: .animal,
            rarity: .common,
            habitat: .meadow,
            description: "An iconic orange and black butterfly famous for migration.",
            funFact: "Monarchs migrate up to 3,000 miles from Canada to Mexico!",
            emoji: "🦋"
        ),
        Species(
            commonName: "House Sparrow",
            scientificName: "Passer domesticus",
            kingdom: .animal,
            rarity: .common,
            habitat: .urban,
            description: "A small, adaptable bird found worldwide near human habitation.",
            funFact: "House sparrows take dust baths to keep their feathers clean.",
            emoji: "🐦"
        ),
        Species(
            commonName: "Honeybee",
            scientificName: "Apis mellifera",
            kingdom: .animal,
            rarity: .common,
            habitat: .garden,
            description: "A social insect crucial for pollination.",
            funFact: "A single bee visits 50-1000 flowers in one collection trip!",
            emoji: "🐝"
        ),

        // Uncommon
        Species(
            commonName: "Red Fox",
            scientificName: "Vulpes vulpes",
            kingdom: .animal,
            rarity: .uncommon,
            habitat: .forest,
            description: "A clever canid with distinctive red fur and bushy tail.",
            funFact: "Foxes use the Earth's magnetic field to hunt prey under snow.",
            emoji: "🦊",
            growthRate: 1.2
        ),
        Species(
            commonName: "Great Blue Heron",
            scientificName: "Ardea herodias",
            kingdom: .animal,
            rarity: .uncommon,
            habitat: .wetland,
            description: "A tall wading bird with blue-gray plumage.",
            funFact: "Herons have special feathers that crumble into powder to clean fish slime off their other feathers.",
            emoji: "🦢",
            growthRate: 1.2
        ),
        Species(
            commonName: "Painted Turtle",
            scientificName: "Chrysemys picta",
            kingdom: .animal,
            rarity: .uncommon,
            habitat: .wetland,
            description: "A colorful freshwater turtle with red and yellow markings.",
            funFact: "Painted turtles can survive winter frozen under ice by absorbing oxygen through their skin!",
            emoji: "🐢",
            growthRate: 0.8
        ),
        Species(
            commonName: "Praying Mantis",
            scientificName: "Mantis religiosa",
            kingdom: .animal,
            rarity: .uncommon,
            habitat: .garden,
            description: "A predatory insect known for its prayer-like stance.",
            funFact: "Mantises are the only insects that can turn their heads 180 degrees.",
            emoji: "🦗",
            growthRate: 1.1
        ),

        // Rare
        Species(
            commonName: "Barred Owl",
            scientificName: "Strix varia",
            kingdom: .animal,
            rarity: .rare,
            habitat: .forest,
            description: "A large owl with distinctive barred plumage and dark eyes.",
            funFact: "Their call sounds like 'Who cooks for you? Who cooks for you-all?'",
            emoji: "🦉",
            growthRate: 1.3
        ),
        Species(
            commonName: "River Otter",
            scientificName: "Lontra canadensis",
            kingdom: .animal,
            rarity: .rare,
            habitat: .wetland,
            description: "A playful, semi-aquatic mammal with webbed feet.",
            funFact: "Otters hold hands while sleeping so they don't drift apart!",
            emoji: "🦦",
            growthRate: 1.4
        ),
        Species(
            commonName: "Pileated Woodpecker",
            scientificName: "Dryocopus pileatus",
            kingdom: .animal,
            rarity: .rare,
            habitat: .forest,
            description: "A crow-sized woodpecker with a flaming red crest.",
            funFact: "They inspired the cartoon character Woody Woodpecker!",
            emoji: "🪶",
            growthRate: 1.3
        ),

        // Epic
        Species(
            commonName: "Black Bear",
            scientificName: "Ursus americanus",
            kingdom: .animal,
            rarity: .epic,
            habitat: .mountain,
            description: "North America's most common bear species.",
            funFact: "Black bears can run up to 35 mph and climb trees with ease!",
            emoji: "🐻",
            growthRate: 1.5
        ),
        Species(
            commonName: "Bald Eagle",
            scientificName: "Haliaeetus leucocephalus",
            kingdom: .animal,
            rarity: .epic,
            habitat: .mountain,
            description: "The majestic national bird of the United States.",
            funFact: "Eagle nests can weigh up to 2 tons and be used for decades!",
            emoji: "🦅",
            growthRate: 1.5
        ),

        // Legendary
        Species(
            commonName: "Gray Wolf",
            scientificName: "Canis lupus",
            kingdom: .animal,
            rarity: .legendary,
            habitat: .mountain,
            description: "An apex predator and the ancestor of domestic dogs.",
            funFact: "Wolf howls can be heard from 10 miles away!",
            emoji: "🐺",
            growthRate: 2.0
        ),
        Species(
            commonName: "Mountain Lion",
            scientificName: "Puma concolor",
            kingdom: .animal,
            rarity: .legendary,
            habitat: .mountain,
            description: "A powerful, solitary big cat also known as cougar or puma.",
            funFact: "Mountain lions can leap 40 feet horizontally and 15 feet vertically!",
            emoji: "🦁",
            growthRate: 2.0
        ),
    ]

    // MARK: - Plants

    static let plants: [Species] = [
        // Common
        Species(
            commonName: "Common Dandelion",
            scientificName: "Taraxacum officinale",
            kingdom: .plant,
            rarity: .common,
            habitat: .meadow,
            description: "A hardy flowering plant with yellow blooms and fluffy seed heads.",
            funFact: "Every part of a dandelion is edible and nutritious!",
            emoji: "🌼",
            growthRate: 1.5
        ),
        Species(
            commonName: "White Clover",
            scientificName: "Trifolium repens",
            kingdom: .plant,
            rarity: .common,
            habitat: .meadow,
            description: "A low-growing plant with three-part leaves and white flowers.",
            funFact: "Four-leaf clovers occur in about 1 in 5,000 plants!",
            emoji: "🍀",
            growthRate: 1.3
        ),
        Species(
            commonName: "English Ivy",
            scientificName: "Hedera helix",
            kingdom: .plant,
            rarity: .common,
            habitat: .forest,
            description: "An evergreen climbing vine with distinctive lobed leaves.",
            funFact: "Ivy can live for over 400 years!",
            emoji: "🌿",
            growthRate: 1.2
        ),

        // Uncommon
        Species(
            commonName: "Wild Violet",
            scientificName: "Viola sororia",
            kingdom: .plant,
            rarity: .uncommon,
            habitat: .forest,
            description: "A delicate spring wildflower with purple blooms.",
            funFact: "Violets have been used in perfumes since ancient Greek times.",
            emoji: "💜",
            growthRate: 1.1
        ),
        Species(
            commonName: "Black-Eyed Susan",
            scientificName: "Rudbeckia hirta",
            kingdom: .plant,
            rarity: .uncommon,
            habitat: .meadow,
            description: "A cheerful wildflower with golden petals and dark centers.",
            funFact: "Native Americans used this plant for medicinal purposes.",
            emoji: "🌻",
            growthRate: 1.2
        ),
        Species(
            commonName: "Cattail",
            scientificName: "Typha latifolia",
            kingdom: .plant,
            rarity: .uncommon,
            habitat: .wetland,
            description: "A tall wetland plant with distinctive brown seed heads.",
            funFact: "Every part of a cattail can be eaten at some point in the year!",
            emoji: "🌾",
            growthRate: 1.0
        ),

        // Rare
        Species(
            commonName: "Lady's Slipper Orchid",
            scientificName: "Cypripedium acaule",
            kingdom: .plant,
            rarity: .rare,
            habitat: .forest,
            description: "A stunning wild orchid with a pouch-shaped pink flower.",
            funFact: "It takes 10-15 years for a lady's slipper to produce its first bloom!",
            emoji: "🌸",
            growthRate: 0.5
        ),
        Species(
            commonName: "Trillium",
            scientificName: "Trillium grandiflorum",
            kingdom: .plant,
            rarity: .rare,
            habitat: .forest,
            description: "A spring wildflower with three white petals and three leaves.",
            funFact: "Ants help spread trillium seeds by carrying them to their nests!",
            emoji: "🤍",
            growthRate: 0.6
        ),

        // Epic
        Species(
            commonName: "Ghost Pipe",
            scientificName: "Monotropa uniflora",
            kingdom: .plant,
            rarity: .epic,
            habitat: .forest,
            description: "A ghostly white plant that doesn't photosynthesize.",
            funFact: "Ghost pipes steal nutrients from fungi connected to tree roots!",
            emoji: "👻",
            growthRate: 0.4
        ),
        Species(
            commonName: "Venus Flytrap",
            scientificName: "Dionaea muscipula",
            kingdom: .plant,
            rarity: .epic,
            habitat: .wetland,
            description: "A carnivorous plant with snap-trap leaves.",
            funFact: "A flytrap counts touches - it only closes after 2 triggers within 20 seconds!",
            emoji: "🪴",
            growthRate: 0.8
        ),

        // Legendary
        Species(
            commonName: "Corpse Flower",
            scientificName: "Amorphophallus titanum",
            kingdom: .plant,
            rarity: .legendary,
            habitat: .forest,
            description: "The world's largest unbranched flower structure.",
            funFact: "It blooms only once every 7-10 years and smells like rotting flesh!",
            emoji: "🌺",
            growthRate: 0.3
        ),
    ]

    // MARK: - Fungi

    static let fungi: [Species] = [
        // Common
        Species(
            commonName: "Turkey Tail",
            scientificName: "Trametes versicolor",
            kingdom: .fungi,
            rarity: .common,
            habitat: .forest,
            description: "A colorful bracket fungus with concentric rings.",
            funFact: "Turkey tail is being studied for cancer-fighting properties!",
            emoji: "🍄"
        ),
        Species(
            commonName: "Common Puffball",
            scientificName: "Lycoperdon perlatum",
            kingdom: .fungi,
            rarity: .common,
            habitat: .forest,
            description: "A round, white fungus that releases spores when touched.",
            funFact: "A single puffball can release trillions of spores!",
            emoji: "🟤"
        ),

        // Uncommon
        Species(
            commonName: "Chanterelle",
            scientificName: "Cantharellus cibarius",
            kingdom: .fungi,
            rarity: .uncommon,
            habitat: .forest,
            description: "A prized golden-orange edible mushroom.",
            funFact: "Chanterelles smell faintly of apricots!",
            emoji: "🍄",
            growthRate: 0.9
        ),
        Species(
            commonName: "Oyster Mushroom",
            scientificName: "Pleurotus ostreatus",
            kingdom: .fungi,
            rarity: .uncommon,
            habitat: .forest,
            description: "A fan-shaped edible mushroom that grows on trees.",
            funFact: "Oyster mushrooms are carnivorous - they trap and digest tiny worms!",
            emoji: "🦪",
            growthRate: 1.1
        ),

        // Rare
        Species(
            commonName: "Lion's Mane",
            scientificName: "Hericium erinaceus",
            kingdom: .fungi,
            rarity: .rare,
            habitat: .forest,
            description: "A shaggy white fungus resembling a lion's mane.",
            funFact: "Lion's mane may help regenerate nerve cells!",
            emoji: "🦁",
            growthRate: 0.8
        ),
        Species(
            commonName: "Fly Agaric",
            scientificName: "Amanita muscaria",
            kingdom: .fungi,
            rarity: .rare,
            habitat: .forest,
            description: "The iconic red mushroom with white spots.",
            funFact: "This is the mushroom that inspired Mario's power-ups!",
            emoji: "🍄",
            growthRate: 0.7
        ),

        // Epic
        Species(
            commonName: "Morel",
            scientificName: "Morchella esculenta",
            kingdom: .fungi,
            rarity: .epic,
            habitat: .forest,
            description: "A highly prized honeycomb-textured edible mushroom.",
            funFact: "Morels can sell for $30-90 per pound and cannot be cultivated!",
            emoji: "🧽",
            growthRate: 0.6
        ),
        Species(
            commonName: "Bioluminescent Panellus",
            scientificName: "Panellus stipticus",
            kingdom: .fungi,
            rarity: .epic,
            habitat: .forest,
            description: "A mushroom that glows green in the dark.",
            funFact: "Over 80 species of fungi can produce their own light!",
            emoji: "✨",
            growthRate: 0.7
        ),

        // Legendary
        Species(
            commonName: "Matsutake",
            scientificName: "Tricholoma matsutake",
            kingdom: .fungi,
            rarity: .legendary,
            habitat: .forest,
            description: "A rare, highly aromatic mushroom prized in Japanese cuisine.",
            funFact: "Matsutake can sell for up to $1,000 per pound in Japan!",
            emoji: "💎",
            growthRate: 0.4
        ),
    ]

    // Get random species by rarity weights
    static func randomSpecies() -> Species {
        let weights: [(Rarity, Double)] = [
            (.common, 0.50),
            (.uncommon, 0.30),
            (.rare, 0.15),
            (.epic, 0.04),
            (.legendary, 0.01)
        ]

        let random = Double.random(in: 0...1)
        var cumulative = 0.0

        for (rarity, weight) in weights {
            cumulative += weight
            if random <= cumulative {
                let speciesOfRarity = all.filter { $0.rarity == rarity }
                return speciesOfRarity.randomElement() ?? all[0]
            }
        }

        return all.randomElement() ?? all[0]
    }

    static func randomSpecies(from kingdom: OrganismKingdom) -> Species {
        let speciesInKingdom = all.filter { $0.kingdom == kingdom }
        return speciesInKingdom.randomElement() ?? all[0]
    }
}
