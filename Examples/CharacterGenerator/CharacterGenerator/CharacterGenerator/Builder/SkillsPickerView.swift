//
//  SkillsPickerView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct SkillsPickerView: View {
    @EnvironmentObject var appState: AppState
    let builderState: CharacterBuilderState

    private var requiredCount: Int {
        builderState.selectedClass?.startingSkillCount ?? 2
    }

    private var availableSkills: [Skill] {
        builderState.availableClassSkills.sorted { $0.name < $1.name }
    }

    private var backgroundSkills: [Skill] {
        (builderState.selectedBackground?.skillProficiencies ?? []).sorted { $0.name < $1.name }
    }

    var body: some View {
        List {
            Section {
                ForEach(availableSkills, id: \.name) { skill in
                    skillRow(skill)
                }
            } header: {
                Text("Choose \(requiredCount) · \(builderState.chosenSkills.count) selected")
            }

            if !backgroundSkills.isEmpty {
                Section("Granted by Background") {
                    ForEach(backgroundSkills, id: \.name) { skill in
                        HStack {
                            SkillLabel(skill: skill)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundStyle(.secondary)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Skills")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func skillRow(_ skill: Skill) -> some View {
        let isSelected = builderState.chosenSkills.contains(skill)
        let isDisabled = !isSelected && builderState.chosenSkills.count >= requiredCount
        Button {
            if isSelected {
                builderState.chosenSkills.removeAll { $0 == skill }
            } else {
                builderState.chosenSkills.append(skill)
            }
        } label: {
            HStack {
                SkillLabel(skill: skill)
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
}

private struct SkillLabel: View {
    let skill: Skill

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(skill.name)
                .font(.body)
            Text(skill.ability.abbreviated)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 1)
    }
}

#Preview {
    NavigationStack {
        SkillsPickerView(builderState: CharacterBuilderState())
            .environmentObject(AppState())
    }
}
