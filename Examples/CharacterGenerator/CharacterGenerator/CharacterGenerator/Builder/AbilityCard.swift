//
//  AbilityCard.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct AbilityCard: View {
    let ability: Ability
    let score: Int?
    let priority: AbilityPriority
    var isSelected: Bool = false

    private var modifierText: String? {
        guard let modifier = score?.scoreModifier else { return nil }
        return modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: priority icon + ability name
            HStack(spacing: 4) {
                switch priority {
                case .primary:
                    Image(systemName: "star.fill")
                        .foregroundStyle(.tint)
                case .alternate:
                    Image(systemName: "star")
                        .foregroundStyle(.secondary)
                case .none:
                    // Reserve icon space so all cards align regardless of priority.
                    Image(systemName: "star.fill")
                        .hidden()
                }
                Text(ability.name)
                    .foregroundStyle(.secondary)
                // Mirrors the left icon so the label is the true center of the HStack.
                Image(systemName: "star.fill").hidden()
            }
            .font(.caption2)
            .frame(maxWidth: .infinity, alignment: .center)

            // Score
            Text(score.map { "\($0)" } ?? "—")
                .font(.title.bold().monospacedDigit())
                .frame(maxWidth: .infinity, alignment: .center)
                .contentTransition(.numericText())

            // Modifier — invisible placeholder preserves height when unassigned.
            Text(modifierText ?? " ")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .opacity(modifierText != nil ? 1 : 0)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.background.secondary)
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.12))
            }
        }
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor, lineWidth: 2)
            }
        }
    }
}

#Preview("AbilityCard") {
    let abilities = Ability.defaults
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        AbilityCard(ability: abilities[0], score: 16, priority: .primary, isSelected: true)
        AbilityCard(ability: abilities[1], score: 14, priority: .alternate)
        AbilityCard(ability: abilities[2], score: 13, priority: .none)
        AbilityCard(ability: abilities[3], score: nil, priority: .none)
        AbilityCard(ability: abilities[4], score: 10, priority: .primary)
        AbilityCard(ability: abilities[5], score: 8, priority: .none)
    }
    .padding()
}
