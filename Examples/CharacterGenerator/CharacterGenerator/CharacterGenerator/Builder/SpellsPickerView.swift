//
//  SpellsPickerView.swift
//  CharacterGenerator
//
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct SpellsPickerView: View {
    @EnvironmentObject var appState: AppState
    let builderState: CharacterBuilderState

    private var neededCantrips: Int { builderState.selectedClass?.cantripsKnown ?? 0 }
    private var neededSpells: Int { builderState.selectedClass?.spellsKnown ?? 0 }

    private var availableCantrips: [Spell] {
        appState.configuration.spells.spells(ofLevel: 0)
    }

    private var availableSpells: [Spell] {
        appState.configuration.spells.spells(ofLevel: 1)
    }

    private var leveledSpellSectionTitle: String {
        switch builderState.selectedClass?.spellcastingType {
        case .prepared: return "Prepared Spells"
        case .pactMagic: return "Pact Spells"
        default: return "Known Spells"
        }
    }

    var body: some View {
        List {
            if neededCantrips > 0 {
                Section {
                    ForEach(availableCantrips, id: \.name) { spell in
                        spellRow(
                            spell,
                            chosen: builderState.chosenCantrips,
                            needed: neededCantrips,
                            toggle: { toggleCantrip(spell) }
                        )
                    }
                } header: {
                    Text("Cantrips — Choose \(neededCantrips) · \(builderState.chosenCantrips.count) selected")
                }
            }

            if neededSpells > 0 {
                Section {
                    ForEach(availableSpells, id: \.name) { spell in
                        spellRow(
                            spell,
                            chosen: builderState.chosenSpells,
                            needed: neededSpells,
                            toggle: { toggleSpell(spell) }
                        )
                    }
                } header: {
                    Text("\(leveledSpellSectionTitle) — Choose \(neededSpells) · \(builderState.chosenSpells.count) selected")
                }
            }
        }
        .navigationTitle("Choose Spells")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func spellRow(_ spell: Spell, chosen: [Spell], needed: Int, toggle: @escaping () -> Void) -> some View {
        let isSelected = chosen.contains(spell)
        let isDisabled = !isSelected && chosen.count >= needed
        Button(action: toggle) {
            HStack {
                SpellRowView(spell: spell)
                    .foregroundStyle(isDisabled ? .tertiary : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                        .fontWeight(.semibold)
                }
            }
        }
        .foregroundStyle(isDisabled ? .secondary : .primary)
        .disabled(isDisabled)
    }

    private func toggleCantrip(_ spell: Spell) {
        if builderState.chosenCantrips.contains(spell) {
            builderState.chosenCantrips.removeAll { $0 == spell }
        } else {
            builderState.chosenCantrips.append(spell)
        }
    }

    private func toggleSpell(_ spell: Spell) {
        if builderState.chosenSpells.contains(spell) {
            builderState.chosenSpells.removeAll { $0 == spell }
        } else {
            builderState.chosenSpells.append(spell)
        }
    }
}

private struct SpellRowView: View {
    let spell: Spell

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(spell.name)
                .font(.headline)
            HStack(spacing: 10) {
                if !spell.school.isEmpty {
                    Text(spell.school.capitalized)
                }
                if !spell.components.isEmpty {
                    Text(spell.components.joined(separator: "/"))
                }
                if !spell.castingTime.isEmpty {
                    Text(spell.castingTime)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        SpellsPickerView(builderState: CharacterBuilderState())
            .environmentObject(AppState())
    }
}
