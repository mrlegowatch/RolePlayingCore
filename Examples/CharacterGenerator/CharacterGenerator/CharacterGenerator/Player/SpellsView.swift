//
//  SpellsView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

/// Compact spellcasting section shown on the character sheet for spellcasting classes.
struct SpellsView: View {
    let player: Player

    private var cantrips: [Spell] {
        player.preparedSpells.filter { $0.level == 0 }.sorted { $0.name < $1.name }
    }

    private var leveledSpells: [(level: Int, spells: [Spell])] {
        let groups = Dictionary(grouping: player.preparedSpells.filter { $0.level > 0 }, by: \.level)
        return groups.sorted { $0.key < $1.key }.map { (level: $0.key, spells: $0.value.sorted { $0.name < $1.name }) }
    }

    /// Highest slot level the class has at the character's current level.
    private var maxSlotLevel: Int {
        guard let slots = player.classTraits.spellSlots,
              player.level >= 1, player.level <= slots.count else { return 0 }
        return slots[player.level - 1].count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            spellcastingHeader
            if maxSlotLevel > 0 {
                Divider()
                spellSlotsRow
            }
            if !cantrips.isEmpty {
                Divider()
                cantripsList
            }
            if !leveledSpells.isEmpty {
                Divider()
                leveledSpellsList
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Subviews

    private var spellcastingHeader: some View {
        HStack(spacing: 16) {
            Label("Spells", systemImage: "sparkles")
                .font(.headline)
            Spacer()
            if let ability = player.spellcastingAbility {
                statPill(title: ability.abbreviated, subtitle: "Ability")
            }
            if let dc = player.spellSaveDC {
                statPill(title: "\(dc)", subtitle: "Save DC")
            }
            if let bonus = player.spellAttackBonus {
                statPill(title: bonus >= 0 ? "+\(bonus)" : "\(bonus)", subtitle: "Attack")
            }
            if let max = player.maxPreparedSpells {
                statPill(title: "\(max)", subtitle: "Prepared")
            }
        }
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

    private var spellSlotsRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(player.classTraits.spellcastingType == .pactMagic ? "Pact Magic Slots" : "Spell Slots")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                ForEach(1...maxSlotLevel, id: \.self) { slotLevel in
                    let total = player.totalSpellSlots(at: slotLevel)
                    if total > 0 {
                        VStack(spacing: 2) {
                            Text(ordinal(slotLevel))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 3) {
                                let used = slotLevel <= player.usedSpellSlots.count
                                    ? player.usedSpellSlots[slotLevel - 1] : 0
                                ForEach(0..<total, id: \.self) { i in
                                    Image(systemName: i < used ? "circle.fill" : "circle")
                                        .font(.system(size: 9))
                                        .foregroundStyle(i < used ? Color.secondary : Color.accentColor)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var cantripsList: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Cantrips")
                .font(.caption)
                .foregroundStyle(.secondary)
            spellChips(cantrips, memorized: true)
        }
    }

    private var leveledSpellsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(leveledSpells, id: \.level) { group in
                VStack(alignment: .leading, spacing: 3) {
                    let total = player.totalSpellSlots(at: group.level)
                    let available = player.availableSpellSlots(at: group.level)
                    let slotNote = total > 0 ? " · \(available)/\(total) slots" : ""
                    Text("\(ordinal(group.level)) Level\(slotNote)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    spellChips(group.spells, memorized: true)
                }
            }
        }
    }

    /// Renders spell names as a wrapping flow of compact chips.
    private func spellChips(_ spells: [Spell], memorized: Bool) -> some View {
        FlowLayout(spacing: 6) {
            ForEach(spells, id: \.name) { spell in
                SpellChip(spell: spell, memorized: memorized)
            }
        }
    }

    private func ordinal(_ level: Int) -> String {
        switch level {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "\(level)th"
        }
    }
}

// MARK: - SpellChip

private struct SpellChip: View {
    let spell: Spell
    let memorized: Bool

    var body: some View {
        HStack(spacing: 4) {
            if memorized {
                Image(systemName: "sparkle")
                    .font(.system(size: 9))
                    .foregroundStyle(.tint)
            }
            Text(spell.name)
                .font(.caption)
        }
        .chipStyle()
    }
}

#Preview("Spells View") {
    if let player = try? CharacterGenerator(GameData("Configuration")).makeCharacter() {
        SpellsView(player: player)
            .padding()
    } else {
        Text("No spellcasting class rolled")
    }
}
