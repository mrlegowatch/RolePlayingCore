//
//  BackgroundPickerView.swift
//  CharacterGenerator
//
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct BackgroundPickerView: View {
    @EnvironmentObject var appState: AppState
    let builderState: CharacterBuilderState

    private static let popularityOrder: [String] = [
        "Soldier", "Criminal", "Noble", "Sage", "Acolyte", "Charlatan",
        "Entertainer", "Hermit", "Guard", "Farmer", "Guide", "Artisan",
        "Merchant", "Sailor", "Scribe", "Wayfarer"
    ]

    private var sortedBackgrounds: [BackgroundTraits] {
        appState.configuration.backgrounds.all.sorted { a, b in
            let order = Self.popularityOrder
            let ai = order.firstIndex(of: a.name) ?? order.count
            let bi = order.firstIndex(of: b.name) ?? order.count
            return ai == bi ? a.name < b.name : ai < bi
        }
    }

    var body: some View {
        List {
            ForEach(sortedBackgrounds, id: \.name) { background in
                backgroundRow(background)
            }
        }
        .navigationTitle("Choose Background")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func backgroundRow(_ background: BackgroundTraits) -> some View {
        let isSelected = builderState.selectedBackground?.name == background.name
        Button {
            builderState.selectedBackground = background
        } label: {
            HStack {
                BackgroundRowView(background: background)
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

private struct BackgroundRowView: View {
    let background: BackgroundTraits

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(background.name)
                .font(.headline)
            HStack(spacing: 12) {
                Label(background.abilityScores.map(\.abbreviated).joined(separator: ", "), systemImage: "chart.bar")
                Label(background.feat.name, systemImage: "star")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            Text(background.skillProficiencies.map(\.name).joined(separator: ", "))
                .font(.caption)
                .foregroundStyle(.secondary)
            if !background.toolProficiency.isEmpty {
                Text(background.toolProficiency)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        BackgroundPickerView(builderState: CharacterBuilderState())
            .environmentObject(AppState())
    }
}
