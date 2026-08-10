//
//  CharacterBuilderView.swift
//  CharacterGenerator
//
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct CharacterBuilderView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        // Guard against the brief window during sheet dismissal when builderState
        // is set to nil before the animation completes.
        if let builderState = appState.builderState {
            NavigationStack {
                BuilderStepContainer(builderState: builderState)
            }
            // .large covers iPhone full-screen; minWidth/minHeight sizes the Mac Catalyst dialog.
            .presentationDetents([.large])
            .frame(minWidth: 400, minHeight: 600)
        }
    }
}

private struct BuilderStepContainer: View {
    @EnvironmentObject var appState: AppState
    @Bindable var builderState: CharacterBuilderState

    private var isSpellcaster: Bool {
        builderState.selectedClass?.spellcastingAbility != nil
    }

    private var totalSteps: Int { isSpellcaster ? 7 : 6 }

    private var canAdvance: Bool {
        switch builderState.currentStep {
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

    private var isLastStep: Bool { builderState.currentStep == totalSteps - 1 }

    var body: some View {
        stepContent
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    leadingButton
                }
                ToolbarItem(placement: .principal) {
                    progressView
                }
                ToolbarItem(placement: .topBarTrailing) {
                    trailingButton
                }
            }
            .onChange(of: builderState.selectedClass?.name) { _, newName in
                guard let newName else { return }
                builderState.chosenCantrips = []
                builderState.chosenSpells = []
                let bgName = Self.defaultBackgroundName(for: newName)
                builderState.selectedBackground = appState.configuration.backgrounds[bgName]
                // Clamp step in case totalSteps shrank (spellcaster → non-spellcaster).
                let newTotal = appState.configuration.classes[newName]?.spellcastingAbility != nil ? 7 : 6
                if builderState.currentStep >= newTotal {
                    builderState.currentStep = newTotal - 1
                }
            }
            .onChange(of: builderState.selectedBackground?.name) { _, _ in
                builderState.chosenSkills = []
            }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch builderState.currentStep {
        case 0: SpeciesPickerView(builderState: builderState)
        case 1: ClassPickerView(builderState: builderState)
        case 2: BackgroundPickerView(builderState: builderState)
        case 3: AbilityScoresBuilderView(builderState: builderState)
        case 4: SkillsPickerView(builderState: builderState)
        case 5 where isSpellcaster: SpellsPickerView(builderState: builderState)
        default: NameAndFinishView(builderState: builderState)
        }
    }

    @ViewBuilder
    private var leadingButton: some View {
        if builderState.currentStep == 0 {
            Button("Cancel") {
                appState.cancelBuildingCharacter()
            }
        } else {
            Button {
                builderState.currentStep -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
            }
        }
    }

    private var progressView: some View {
        VStack(spacing: 3) {
            Text("\(builderState.currentStep + 1) / \(totalSteps)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            ProgressView(value: Double(builderState.currentStep + 1), total: Double(totalSteps))
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
        } else {
            Button {
                builderState.currentStep += 1
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
