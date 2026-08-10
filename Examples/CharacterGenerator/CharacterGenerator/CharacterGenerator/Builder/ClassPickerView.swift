//
//  ClassPickerView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct ClassPickerView: View {
    @EnvironmentObject var appState: AppState
    let builderState: CharacterBuilderState

    private var sortedClasses: [ClassTraits] {
        appState.gameData.classes.allByDisplayOrder
    }

    var body: some View {
        List {
            ForEach(sortedClasses, id: \.name) { classTraits in
                classRow(classTraits)
            }
        }
        .navigationTitle("Choose Class")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func classRow(_ classTraits: ClassTraits) -> some View {
        let isSelected = builderState.selectedClass?.name == classTraits.name
        Button {
            builderState.selectedClass = classTraits
        } label: {
            HStack {
                ClassRowView(classTraits: classTraits)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                        .fontWeight(.semibold)
                }
            }
        }
        .foregroundStyle(.primary)
    }
}

private struct ClassRowView: View {
    let classTraits: ClassTraits

    private var primaryAbilityText: String {
        let primary = classTraits.primaryAbility.map(\.name).joined(separator: " & ")
        if let alternate = classTraits.alternatePrimaryAbility {
            return "\(primary) or \(alternate.map(\.name).joined(separator: " & "))"
        }
        return primary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(classTraits.name)
                .font(.headline)
            HStack(spacing: 12) {
                let hitDieLabel = "\(classTraits.hitDice)"
                Label(hitDieLabel, systemImage: "dice")
                if !classTraits.primaryAbility.isEmpty {
                    Text(primaryAbilityText)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if !classTraits.armorTraining.isEmpty {
                Text(classTraits.armorTraining.map { $0.rawValue.capitalized }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        ClassPickerView(builderState: CharacterBuilderState())
            .environmentObject(AppState())
    }
}
