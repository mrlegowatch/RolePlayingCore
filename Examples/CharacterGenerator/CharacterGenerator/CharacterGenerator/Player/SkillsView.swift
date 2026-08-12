//
//  SkillsView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct SkillsView: View {
    let player: Player

    private var sortedSkills: [Skill] {
        player.skillProficiencies.sorted { $0.name < $1.name }
    }

    private func bonus(for skill: Skill) -> Int {
        (player.modifiers[skill.ability] ?? 0) + player.proficiencyBonus
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                Label("Skills", systemImage: "checkmark.seal")
                    .font(.headline)
                Spacer()
                statPill(
                    title: player.proficiencyBonus >= 0 ? "+\(player.proficiencyBonus)" : "\(player.proficiencyBonus)",
                    subtitle: "Prof Bonus"
                )
                statPill(title: "\(player.passivePerception)", subtitle: "Passive Perc")
            }
            if !sortedSkills.isEmpty {
                Divider()
                FlowLayout(spacing: 6) {
                    ForEach(sortedSkills, id: \.name) { skill in
                        SkillChip(skill: skill, bonus: bonus(for: skill))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statPill(title: String, subtitle: String) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.subheadline.bold())
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SkillChip: View {
    let skill: Skill
    let bonus: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(bonus >= 0 ? "+\(bonus)" : "\(bonus)")
                .font(.caption.bold())
                .foregroundStyle(.tint)
            Text(skill.name)
                .font(.caption)
        }
        .chipStyle()
    }
}

#Preview("Skills View") {
    if let player = try? CharacterGenerator(GameData("Configuration")).makeCharacter() {
        SkillsView(player: player)
            .padding()
    } else {
        Text("No player generated")
    }
}
