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
                // Section 0: XP / Level
                sectionCard(0)
                // Identity: Species + Class prominent, Background secondary
                PlayerIdentityView(player: player)
                    .padding()
                    .background(.background.secondary)
                    .cornerRadius(12)
                // Section 2: Abilities
                sectionCard(2)
                // Skills (replaces section 3; already shows Prof Bonus + Passive Perception)
                SkillsView(player: player)
                    .padding()
                    .background(.background.secondary)
                    .cornerRadius(12)
                // Combat: AC · Initiative · Speed (sections 4+5 merged, PB+PP dropped as redundant)
                HStack(spacing: 6) {
                    LabeledNumberView(label: "Armor Class", value: characterSheet.armorClass)
                    LabeledNumberView(label: "Initiative", value: characterSheet.initiative)
                    LabeledNumberView(label: "Speed", value: characterSheet.speed)
                }
                .padding()
                .background(.background.secondary)
                .cornerRadius(12)
                // Section 6: HP
                sectionCard(6)
                // Section 7: Height + Size
                sectionCard(7)
                // Section 8: Money
                sectionCard(8)
                // Equipment (replaces section 9)
                if !player.inventory.isEmpty {
                    InventoryView(player: player)
                        .padding()
                        .background(.background.secondary)
                        .cornerRadius(12)
                }
                // Spells
                if player.spellcastingAbility != nil {
                    SpellsView(player: player)
                        .padding()
                        .background(.background.secondary)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private func sectionCard(_ section: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<characterSheet.numberOfItems(in: section), id: \.self) { item in
                traitView(for: section, item: item)
            }
        }
        .padding()
        .background(.background.secondary)
        .cornerRadius(12)
    }

    @ViewBuilder
    private func traitView(for section: Int, item: Int) -> some View {
        let cellIdentifier = characterSheet.cellIdentifiers[section][item]
        let keys = characterSheet.keys[section][item]
        let label = characterSheet.labelKeys[section][item]
        
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

#Preview("Character Detail") {
    NavigationStack {
        if let player = try? CharacterGenerator(Configuration("Configuration")).makeCharacter() {
            PlayerDetailView(player: player)
        } else {
            Text("Unable to generate preview")
        }
    }
}
