//
//  ProficienciesView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 8/11/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct ProficienciesView: View {
    let player: Player

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Proficiencies", systemImage: "shield")
                .font(.headline)
            if !player.allWeaponProficiencies.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 3) {
                    Text("Weapons")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    FlowLayout(spacing: 6) {
                        ForEach(Array(player.allWeaponProficiencies.enumerated()), id: \.offset) { _, prof in
                            Text(prof.description)
                                .font(.caption)
                                .chipStyle()
                        }
                    }
                }
            }
            if !player.allArmorTraining.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 3) {
                    Text("Armor")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    FlowLayout(spacing: 6) {
                        ForEach(Array(player.allArmorTraining.enumerated()), id: \.offset) { _, armor in
                            Text(armor.rawValue.capitalized)
                                .font(.caption)
                                .chipStyle()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Proficiencies View") {
    if let player = try? CharacterGenerator(GameData("Configuration")).makeCharacter() {
        ProficienciesView(player: player)
            .padding()
    } else {
        Text("No player generated")
    }
}
