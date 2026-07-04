//
//  AbilitiesView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 1/3/26.
//

import SwiftUI
import RolePlayingCore

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
        .background(.background.tertiary)
        .cornerRadius(8)
    }
}

#Preview("Abilities") {
    let abilities = AbilityScores([
        .strength: 16,
        .dexterity: 14,
        .constitution: 13,
        .intelligence: 10,
        .wisdom: 12,
        .charisma: 8
    ])
    
    AbilitiesView(abilities: abilities)
        .padding()
}

