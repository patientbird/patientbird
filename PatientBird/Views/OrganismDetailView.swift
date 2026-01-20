import SwiftUI

struct OrganismDetailView: View {
    let organism: CapturedOrganism

    @ObservedObject var collectionManager = CollectionManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showRenameAlert = false
    @State private var newNickname = ""
    @State private var showReleaseConfirmation = false
    @State private var actionFeedback: String?
    @State private var isAnimatingEmoji = false

    // Get the current state from collection manager
    private var currentOrganism: CapturedOrganism {
        collectionManager.collection.first { $0.id == organism.id } ?? organism
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with emoji and basic info
                    headerSection

                    // Stats section
                    statsSection

                    // Action buttons
                    actionsSection

                    // Info section
                    infoSection

                    // Danger zone
                    dangerZone
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        currentOrganism.species.kingdom.color.opacity(0.2),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(currentOrganism.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Rename", isPresented: $showRenameAlert) {
                TextField("Nickname", text: $newNickname)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    collectionManager.rename(organism: currentOrganism, to: newNickname)
                }
            } message: {
                Text("Give your \(currentOrganism.species.commonName) a nickname")
            }
            .confirmationDialog(
                "Release \(currentOrganism.displayName)?",
                isPresented: $showReleaseConfirmation,
                titleVisibility: .visible
            ) {
                Button("Release", role: .destructive) {
                    collectionManager.release(organism: currentOrganism)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will return \(currentOrganism.displayName) to the wild. This cannot be undone.")
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Mood and emoji
            ZStack {
                Circle()
                    .fill(currentOrganism.mood.color.opacity(0.2))
                    .frame(width: 160, height: 160)

                Text(currentOrganism.species.emoji)
                    .font(.system(size: 80))
                    .scaleEffect(isAnimatingEmoji ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.3),
                        value: isAnimatingEmoji
                    )

                // Mood emoji
                Text(currentOrganism.mood.emoji)
                    .font(.title)
                    .offset(x: 50, y: -50)
            }

            // Feedback text
            if let feedback = actionFeedback {
                Text(feedback)
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }

            // Name and rename button
            HStack {
                VStack(spacing: 4) {
                    Text(currentOrganism.displayName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(currentOrganism.species.scientificName)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.gray)
                }

                Button {
                    newNickname = currentOrganism.nickname ?? ""
                    showRenameAlert = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue.opacity(0.7))
                }
            }

            // Badges row
            HStack(spacing: 12) {
                Badge(
                    text: currentOrganism.species.kingdom.rawValue,
                    icon: currentOrganism.species.kingdom.icon,
                    color: currentOrganism.species.kingdom.color
                )

                Badge(
                    text: currentOrganism.species.rarity.rawValue,
                    icon: "sparkles",
                    color: currentOrganism.species.rarity.color
                )

                Badge(
                    text: currentOrganism.species.habitat.rawValue,
                    icon: currentOrganism.species.habitat.icon,
                    color: .brown
                )
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(spacing: 16) {
            // Level and XP
            VStack(spacing: 8) {
                HStack {
                    Text("Level \(currentOrganism.level)")
                        .font(.headline)

                    Spacer()

                    Text("\(currentOrganism.experience)/\(currentOrganism.experienceToNextLevel) XP")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                ProgressView(value: currentOrganism.experienceProgress)
                    .tint(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )

            // Energy and Happiness
            HStack(spacing: 12) {
                StatCard(
                    title: "Energy",
                    value: currentOrganism.energy,
                    maxValue: currentOrganism.species.maxEnergy,
                    icon: "bolt.fill",
                    color: .orange
                )

                StatCard(
                    title: "Happiness",
                    value: currentOrganism.happiness,
                    maxValue: currentOrganism.species.maxHappiness,
                    icon: "heart.fill",
                    color: .pink
                )
            }

            // Additional stats
            HStack(spacing: 12) {
                MiniStat(label: "Mood", value: currentOrganism.mood.rawValue, icon: "face.smiling")
                MiniStat(label: "Training", value: "\(currentOrganism.trainingSessions)", icon: "figure.run")
                MiniStat(label: "Days", value: "\(daysSinceCapture)", icon: "calendar")
            }
        }
    }

    private var daysSinceCapture: Int {
        Calendar.current.dateComponents([.day], from: currentOrganism.captureDate, to: Date()).day ?? 0
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Text("Interact")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActionButton(
                    title: "Feed",
                    icon: "leaf.fill",
                    color: .green,
                    subtitle: "+30 Energy"
                ) {
                    performAction {
                        collectionManager.feed(organism: currentOrganism)
                    } feedback: "Yummy! 🍃"
                }

                ActionButton(
                    title: "Play",
                    icon: "gamecontroller.fill",
                    color: .purple,
                    subtitle: "-20 Energy, +25 Happy",
                    disabled: currentOrganism.energy < 20
                ) {
                    performAction {
                        collectionManager.play(with: currentOrganism)
                    } feedback: "So fun! 🎮"
                }

                ActionButton(
                    title: "Train",
                    icon: "figure.run",
                    color: .blue,
                    subtitle: "-30 Energy, +20 XP",
                    disabled: currentOrganism.energy < 30
                ) {
                    performAction {
                        collectionManager.train(organism: currentOrganism)
                    } feedback: "Getting stronger! 💪"
                }

                ActionButton(
                    title: "Pet",
                    icon: "hand.raised.fill",
                    color: .pink,
                    subtitle: "+15 Happy"
                ) {
                    performAction {
                        collectionManager.pet(organism: currentOrganism)
                    } feedback: "Loves it! 💕"
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func performAction(_ action: () -> Void, feedback: String) {
        action()

        withAnimation(.spring(response: 0.3)) {
            isAnimatingEmoji = true
            actionFeedback = feedback
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isAnimatingEmoji = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                actionFeedback = nil
            }
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)

            Text(currentOrganism.species.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Did you know?")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(currentOrganism.species.funFact)
                    .font(.subheadline)
                    .italic()
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Captured")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(currentOrganism.captureDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                }

                Spacer()

                if let location = currentOrganism.captureLocation {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Location")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(location)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        VStack(spacing: 12) {
            Button {
                showReleaseConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "arrow.uturn.backward.circle")
                    Text("Release to the Wild")
                }
                .font(.subheadline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct Badge: View {
    let text: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
    }
}

struct StatCard: View {
    let title: String
    let value: Int
    let maxValue: Int
    let icon: String
    let color: Color

    var progress: Double {
        Double(value) / Double(maxValue)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(value)/\(maxValue)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            ProgressView(value: progress)
                .tint(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

struct MiniStat: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let subtitle: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(disabled ? Color.gray : color)
            )
            .foregroundColor(.white)
        }
        .disabled(disabled)
    }
}

#Preview {
    let sampleOrganism = CapturedOrganism(
        species: SpeciesDatabase.animals[0],
        captureLocation: "Central Park"
    )
    return OrganismDetailView(organism: sampleOrganism)
}
