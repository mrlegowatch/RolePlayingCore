//
//  PlayerDetailView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct PlayerDetailView: View {
    let player: Player
    private var characterSheet: CharacterSheet
    
    init(player: Player) {
        self.player = player
        self.characterSheet = CharacterSheet(player)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<characterSheet.numberOfSections, id: \.self) { section in
                    HStack(spacing: 6) {
                        ForEach(0..<characterSheet.numberOfItems(in: section), id: \.self) { item in
                            let indexPath = IndexPath(item: item, section: section)
                            traitView(for: indexPath)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private func traitView(for indexPath: IndexPath) -> some View {
        let cellIdentifier = characterSheet.cellIdentifiers[indexPath.section][indexPath.item]
        let keys = characterSheet.keys[indexPath.section][indexPath.item]
        let label = characterSheet.labelKeys[indexPath.section][indexPath.item]
        
        switch cellIdentifier {
        case "labeledText":
            let value = characterSheet[keyPath: keys] as! String
            LabeledTextView(label: label, value: value)
        case "labeledNumber":
            let value = characterSheet[keyPath: keys] as! String
            LabeledNumberView(label: label, value: value)
        case "experiencePoints":
            ExperiencePointsView(experiencePoints: ExperiencePoints(player))
        case "abilities":
            AbilitiesView(abilities: player.abilities)
        default:
            Text("Unknown trait type: \(cellIdentifier)")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Individual Trait Views

struct LabeledTextView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(NSLocalizedString(label, comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LabeledNumberView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(NSLocalizedString(label, comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            NumberView(number: value)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ExperiencePointsView: View {
    let experiencePoints: ExperiencePoints
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Level".uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
                let levelUpString = experiencePoints.canLevelUp ? "*" : ""
                Text("\(experiencePoints.level)\(levelUpString)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Experience Points".uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Text("\(experiencePoints.experiencePoints)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(" / \(experiencePoints.maxExperiencePoints)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                }
            }
            Spacer()
            Text("\(experiencePoints.level)")
                .font(.caption)
                .foregroundStyle(.secondary)
            ProgressView(value: experiencePoints.currentProgress)
            Text("\(experiencePoints.level + 1)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct AbilitiesView: View {
    let abilities: AbilityScores
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("Abilities", comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                AbilityItemView(abilities: abilities, ability: .strength)
                AbilityItemView(abilities: abilities, ability: .dexterity)
                AbilityItemView(abilities: abilities, ability: .constitution)
                AbilityItemView(abilities: abilities, ability: .intelligence)
                AbilityItemView(abilities: abilities, ability: .wisdom)
                AbilityItemView(abilities: abilities, ability: .charisma)
            }
        }
    }
}

/// Displays a number in a larger font
struct NumberView: View {
    let number: String
    
    var body: some View {
        Text(number)
            .font(.title3)
            .fontWeight(.bold)
    }
}

struct AbilityItemView: View {
    let abilities: AbilityScores
    let ability: Ability
    var value: Int { abilities[ability]! }
    var modifier: Int { abilities.modifiers[ability]! }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(ability.name.capitalized)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            let modifierString = modifier > 0 ? " +\(modifier) " : " \(modifier) "
            HStack(spacing: 8) {
                NumberView(number: "\(modifierString)")
                Text("\(value)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview("Character Detail") {
    NavigationStack {
        if let player = try? CharacterGenerator(Configuration("Configuration")).makeCharacter() {
            PlayerDetailView(player: player)
        } else {
            Text("Unable to generate preview")
        }
    }
}
