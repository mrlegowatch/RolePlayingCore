//
//  CharacterBuilderView.swift
//  CharacterGenerator
//
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

// Steps beyond the root (Species). Each value is pushed onto the NavigationStack path.
private enum BuilderStep: Hashable {
    case `class`, background, abilityScores, skills, spells, nameAndFinish
}

struct CharacterBuilderView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        // Guard against the brief window during dismissal when builderState
        // is set to nil before the animation completes.
        if let builderState = appState.builderState {
            BuilderStepContainer(builderState: builderState)
                .frame(minWidth: 400, minHeight: 600)
        }
    }
}

private struct BuilderStepContainer: View {
    @EnvironmentObject var appState: AppState
    @Bindable var builderState: CharacterBuilderState
    @State private var path: [BuilderStep] = []

    private var isSpellcaster: Bool {
        builderState.selectedClass?.spellcastingAbility != nil
    }

    private var totalSteps: Int { isSpellcaster ? 7 : 6 }

    private var canAdvance: Bool {
        switch path.count {
        case 0: return builderState.selectedSpecies != nil
        case 1: return builderState.selectedClass != nil
        case 2: return builderState.selectedBackground != nil
        case 3:
            guard !builderState.rolledScores.isEmpty else { return false }
            return Ability.defaults.allSatisfy { (builderState.assignedAbilities[$0] ?? 0) > 0 }
        case 4:
            return builderState.chosenSkills.count == (builderState.selectedClass?.startingSkillCount ?? 0)
        case 5:
            if isSpellcaster {
                let needsCantrips = builderState.selectedClass?.cantripsKnown ?? 0
                let needsSpells = builderState.selectedClass?.spellsKnown ?? 0
                return builderState.chosenCantrips.count == needsCantrips
                    && builderState.chosenSpells.count == needsSpells
            }
            return builderState.isComplete
        case 6: return builderState.isComplete
        default: return false
        }
    }

    private var isLastStep: Bool { path.last == .nameAndFinish }

    private var nextStep: BuilderStep? {
        switch path.count {
        case 0: return .class
        case 1: return .background
        case 2: return .abilityScores
        case 3: return .skills
        case 4: return isSpellcaster ? .spells : .nameAndFinish
        case 5 where isSpellcaster: return .nameAndFinish
        default: return nil
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            SpeciesPickerView(builderState: builderState)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: BuilderStep.self) { step in
                    stepView(for: step)
                        .navigationTitle("")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                        .toolbar { builderToolbar }
                }
                .toolbar { builderToolbar }
                .onChange(of: builderState.selectedClass?.name) { _, newName in
                    guard let newName else { return }
                    builderState.chosenCantrips = []
                    builderState.chosenSpells = []
                    let bgName = Self.defaultBackgroundName(for: newName)
                    builderState.selectedBackground = appState.configuration.backgrounds[bgName]
                    // Pop back if class changed from spellcaster to non-spellcaster.
                    let newTotal = appState.configuration.classes[newName]?.spellcastingAbility != nil ? 7 : 6
                    let maxDepth = newTotal - 1
                    while path.count > maxDepth { path.removeLast() }
                }
                .onChange(of: builderState.selectedBackground?.name) { _, _ in
                    builderState.chosenSkills = []
                }
        }
    }

    @ToolbarContentBuilder
    private var builderToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) { leadingButton }
        ToolbarItem(placement: .principal) { progressView }
        ToolbarItem(placement: .topBarTrailing) { trailingButton }
    }

    @ViewBuilder
    private func stepView(for step: BuilderStep) -> some View {
        switch step {
        case .class:        ClassPickerView(builderState: builderState)
        case .background:   BackgroundPickerView(builderState: builderState)
        case .abilityScores: AbilityScoresBuilderView(builderState: builderState)
        case .skills:       SkillsPickerView(builderState: builderState)
        case .spells:       SpellsPickerView(builderState: builderState)
        case .nameAndFinish: NameAndFinishView(builderState: builderState)
        }
    }

    @ViewBuilder
    private var leadingButton: some View {
        if path.isEmpty {
            Button("Cancel") {
                appState.cancelBuildingCharacter()
            }
        } else {
            Button {
                path.removeLast()
            } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
            }
        }
    }

    private var progressView: some View {
        VStack(spacing: 3) {
            Text("\(path.count + 1) / \(totalSteps)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            ProgressView(value: Double(path.count + 1), total: Double(totalSteps))
                .progressViewStyle(.linear)
                .frame(width: 110)
                .tint(.accentColor)
        }
    }

    @ViewBuilder
    private var trailingButton: some View {
        if isLastStep {
            Button("Create") {
                appState.finalizeBuiltCharacter()
            }
            .disabled(!canAdvance)
            .fontWeight(.semibold)
        } else if let next = nextStep {
            Button {
                path.append(next)
            } label: {
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
            }
            .disabled(!canAdvance)
        }
    }

    private static func defaultBackgroundName(for className: String) -> String {
        let mapping: [String: String] = [
            "Fighter": "Soldier",
            "Wizard": "Sage",
            "Rogue": "Criminal",
            "Paladin": "Guard",
            "Barbarian": "Farmer",
            "Ranger": "Guide",
            "Cleric": "Acolyte",
            "Bard": "Entertainer",
            "Druid": "Hermit",
            "Monk": "Hermit",
            "Sorcerer": "Sage",
            "Warlock": "Charlatan"
        ]
        return mapping[className] ?? "Soldier"
    }
}

#Preview {
    CharacterBuilderView()
        .environmentObject(AppState())
}
