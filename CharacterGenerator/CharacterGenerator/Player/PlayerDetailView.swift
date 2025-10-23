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
            LazyVStack(spacing: 20) {
                ForEach(0..<characterSheet.numberOfSections, id: \.self) { section in
                    VStack(spacing: 12) {
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
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

struct AbilityItemView: View {
    let abilities: AbilityScores
    let ability: Ability
    var value: Int { abilities[ability]! }
    var modifier: Int { abilities.modifiers[ability]! }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(ability.abbreviated)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            let modifierString = modifier > 0 ? " (+\(modifier))" : " (\(modifier))"
            Text("\(value)\(modifierString)")
                .font(.title3)
                .fontWeight(.bold)
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
