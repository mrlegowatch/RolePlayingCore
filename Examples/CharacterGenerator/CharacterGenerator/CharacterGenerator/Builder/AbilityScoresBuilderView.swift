//
//  AbilityScoresBuilderView.swift
//  CharacterGenerator
//
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct AbilityScoresBuilderView: View {
    @EnvironmentObject var appState: AppState
    let builderState: CharacterBuilderState
    // Maps each ability name to an index into builderState.rolledScores (-1 = unassigned)
    @State private var assignments: [String: Int] = [:]

    private var abilities: [Ability] { Ability.defaults }

    private var assignedIndices: Set<Int> {
        Set(assignments.values.filter { $0 >= 0 })
    }

    var body: some View {
        List {
            rolledScoresSection
            if !builderState.rolledScores.isEmpty {
                abilityAssignmentSection
            }
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

    @ViewBuilder
    private var rolledScoresSection: some View {
        Section("Rolled Scores") {
            HStack(spacing: 6) {
                ForEach(builderState.rolledScores.indices, id: \.self) { i in
                    let isUsed = assignedIndices.contains(i)
                    Text("\(builderState.rolledScores[i])")
                        .font(.headline.monospacedDigit())
                        .frame(width: 38, height: 36)
                        .background(isUsed ? Color.secondary.opacity(0.15) : Color.accentColor.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(isUsed ? .secondary : .primary)
                }
                Spacer()
                Button("Re-roll") {
                    builderState.rollAbilityScores()
                    assignments = [:]
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private var abilityAssignmentSection: some View {
        Section("Assign to Abilities") {
            ForEach(abilities, id: \.name) { ability in
                Picker(ability.name, selection: indexBinding(for: ability)) {
                    Text("—").tag(-1)
                    ForEach(builderState.rolledScores.indices, id: \.self) { i in
                        Text("\(builderState.rolledScores[i])").tag(i)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    private func indexBinding(for ability: Ability) -> Binding<Int> {
        Binding(
            get: { assignments[ability.name] ?? -1 },
            set: { newIndex in
                if newIndex >= 0 {
                    // Unassign any other ability already using this score index
                    let conflicts = assignments.keys.filter { assignments[$0] == newIndex && $0 != ability.name }
                    for key in conflicts { assignments[key] = -1 }
                }
                assignments[ability.name] = newIndex
                applyAssignments()
            }
        )
    }

    private func applyAssignments() {
        for ability in abilities {
            let idx = assignments[ability.name] ?? -1
            if idx >= 0, idx < builderState.rolledScores.count {
                builderState.assignedAbilities[ability] = builderState.rolledScores[idx]
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

#Preview {
    NavigationStack {
        AbilityScoresBuilderView(builderState: CharacterBuilderState())
            .environmentObject(AppState())
    }
}
