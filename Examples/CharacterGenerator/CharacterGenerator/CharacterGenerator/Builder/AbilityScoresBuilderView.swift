//
//  AbilityScoresBuilderView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct AbilityScoresBuilderView: View {
    @EnvironmentObject var appState: AppState
    let builderState: CharacterBuilderState

    // Maps each ability name to an index into builderState.rolledScores (-1 = unassigned).
    @State private var assignments: [String: Int] = [:]
    // Ability card currently focused (waiting for a chip tap to assign a score).
    @State private var selectedAbility: Ability?
    // Score chip currently pre-selected (waiting for a card tap to assign).
    @State private var pendingScoreIndex: Int?

    private var abilities: [Ability] { Ability.defaults }

    private var assignedIndices: Set<Int> {
        Set(assignments.values.filter { $0 >= 0 })
    }

    private var hintText: String? {
        if let ability = selectedAbility {
            return "Tap a score to assign it to \(ability.name)"
        } else if let index = pendingScoreIndex {
            return "Tap an ability to assign \(builderState.rolledScores[index])"
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                scorePoolSection
                if let hint = hintText {
                    Text(hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                abilityGridSection
                actionRow
            }
            .padding()
        }
        .navigationTitle("Ability Scores")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if !builderState.hasAutoRolled {
                builderState.rollAbilityScores()
                builderState.hasAutoRolled = true
                assignments = [:]
            } else {
                restoreAssignments()
            }
        }
    }

    // MARK: - Layout sections

    private var scorePoolSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Rolled Scores")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Re-roll") {
                    withAnimation {
                        builderState.rollAbilityScores()
                        assignments = [:]
                        selectedAbility = nil
                        pendingScoreIndex = nil
                    }
                }
                .buttonStyle(.borderless)
            }
            HStack(spacing: 8) {
                ForEach(builderState.rolledScores.indices, id: \.self) { i in
                    ScoreChip(
                        score: builderState.rolledScores[i],
                        isAssigned: assignedIndices.contains(i),
                        isPending: pendingScoreIndex == i,
                        action: { handleChipTap(index: i) }
                    )
                }
                Spacer()
            }
        }
    }

    private var abilityGridSection: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            ForEach(abilities, id: \.name) { ability in
                let scoreIndex = assignments[ability.name] ?? -1
                let score: Int? = scoreIndex >= 0 ? builderState.rolledScores[scoreIndex] : nil
                let priority = builderState.selectedClass?.abilityPriority(ability) ?? .none
                Button { handleCardTap(ability: ability) } label: {
                    AbilityCard(
                        ability: ability,
                        score: score,
                        priority: priority,
                        isSelected: selectedAbility == ability
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var actionRow: some View {
        HStack {
            if let selectedClass = builderState.selectedClass {
                Button("Suggested for \(selectedClass.name)") {
                    withAnimation { applySuggestedAssignment() }
                }
                .buttonStyle(.bordered)
            }
            Spacer()
            Button("Clear") {
                withAnimation {
                    assignments = [:]
                    selectedAbility = nil
                    pendingScoreIndex = nil
                    applyAssignments()
                }
            }
            .buttonStyle(.bordered)
            .disabled(assignedIndices.isEmpty)
        }
    }

    // MARK: - Tap handlers

    private func handleChipTap(index: Int) {
        withAnimation {
            if let ability = selectedAbility {
                // Ability card focused — assign this score to it.
                assignScore(index: index, to: ability)
                selectedAbility = nil
                pendingScoreIndex = nil
            } else if pendingScoreIndex == index {
                // Same chip tapped again — deselect.
                pendingScoreIndex = nil
            } else {
                // No card focused — pre-select this chip.
                pendingScoreIndex = index
            }
        }
    }

    private func handleCardTap(ability: Ability) {
        withAnimation {
            if let pendingIndex = pendingScoreIndex {
                // Chip pending — assign it to this ability.
                assignScore(index: pendingIndex, to: ability)
                pendingScoreIndex = nil
                selectedAbility = nil
            } else if selectedAbility == ability {
                // Same card tapped again — deselect.
                selectedAbility = nil
            } else {
                // No chip pending — focus this card.
                selectedAbility = ability
            }
        }
    }

    private func assignScore(index: Int, to ability: Ability) {
        // Unassign any other ability already using this score slot.
        for key in assignments.keys where assignments[key] == index && key != ability.name {
            assignments[key] = -1
        }
        assignments[ability.name] = index
        applyAssignments()
    }

    // MARK: - Suggested assignment

    private func applySuggestedAssignment() {
        let sortedIndices = builderState.rolledScores.indices
            .sorted { builderState.rolledScores[$0] > builderState.rolledScores[$1] }
        let prioritized = builderState.selectedClass?.abilitiesByPriority ?? abilities
        for (ability, scoreIndex) in zip(prioritized, sortedIndices) {
            assignments[ability.name] = scoreIndex
        }
        selectedAbility = nil
        pendingScoreIndex = nil
        applyAssignments()
    }

    // MARK: - Assignment state

    private func applyAssignments() {
        for ability in abilities {
            let index = assignments[ability.name] ?? -1
            if index >= 0, index < builderState.rolledScores.count {
                builderState.assignedAbilities[ability] = builderState.rolledScores[index]
            } else {
                builderState.assignedAbilities[ability] = 0
            }
        }
    }

    private func restoreAssignments() {
        guard !builderState.rolledScores.isEmpty, assignments.isEmpty else { return }
        var remaining = Array(builderState.rolledScores.enumerated())
        for ability in abilities {
            let value = builderState.assignedAbilities[ability]!
            guard value > 0, let matchIdx = remaining.firstIndex(where: { $0.element == value }) else { continue }
            assignments[ability.name] = remaining[matchIdx].offset
            remaining.remove(at: matchIdx)
        }
    }
}

// MARK: - ScoreChip

private struct ScoreChip: View {
    let score: Int
    let isAssigned: Bool
    let isPending: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(score)")
                .font(.headline.monospacedDigit())
                .frame(width: 44, height: 44)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isAssigned
                              ? Color.secondary.opacity(0.15)
                              : Color.accentColor.opacity(isPending ? 0.25 : 0.15))
                }
                .overlay {
                    if isPending {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.accentColor, lineWidth: 2)
                    }
                }
                .foregroundStyle(isAssigned ? .secondary : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AbilityScoresBuilderView(builderState: CharacterBuilderState())
            .environmentObject(AppState())
    }
}
