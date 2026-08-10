//
//  SpeciesPickerView.swift
//  CharacterGenerator
//
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct SpeciesPickerView: View {
    @EnvironmentObject var appState: AppState
    let builderState: CharacterBuilderState

    @State private var isDrawerExpanded = false

    private static let popularityOrder: [String] = [
        "Human", "Elf", "Dwarf", "Halfling", "Dragonborn",
        "Tiefling", "Gnome", "Goliath", "Orc", "Aasimar"
    ]

    private var rootSpecies: [SpeciesTraits] {
        appState.configuration.species.all
            .filter { $0.parentName == nil }
            .sorted { a, b in
                let order = Self.popularityOrder
                let ai = order.firstIndex(of: a.name) ?? order.count
                let bi = order.firstIndex(of: b.name) ?? order.count
                return ai == bi ? a.name < b.name : ai < bi
            }
    }

    var body: some View {
        List {
            ForEach(rootSpecies, id: \.name) { parent in
                Section {
                    ForEach(parent.subspecies.isEmpty ? [parent] : parent.subspecies, id: \.name) { species in
                        speciesRow(species)
                    }
                } header: {
                    if !parent.subspecies.isEmpty {
                        Text(parent.name)
                    }
                }
            }
        }
        .navigationTitle("Choose Species")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if builderState.selectedSpecies != nil {
                descriptionDrawer
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35), value: builderState.selectedSpecies?.name)
    }

    private var descriptionDrawer: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 4)

            HStack {
                Text(builderState.selectedSpecies?.name ?? "")
                    .font(.title3.bold())
                Spacer()
                if builderState.selectedSpecies?.description != nil {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isDrawerExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isDrawerExpanded
                              ? "chevron.down.circle.fill"
                              : "chevron.up.circle.fill")
                            .foregroundStyle(.tint)
                            .font(.title3)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            if isDrawerExpanded, let desc = builderState.selectedSpecies?.description {
                Text(desc)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .overlay(alignment: .top) { Divider() }
    }

    @ViewBuilder
    private func speciesRow(_ species: SpeciesTraits) -> some View {
        let isSelected = builderState.selectedSpecies?.name == species.name
        Button {
            withAnimation(.spring(response: 0.35)) {
                if !isSelected { isDrawerExpanded = false }
                builderState.selectedSpecies = species
            }
        } label: {
            HStack {
                SpeciesRowView(species: species)
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

private struct SpeciesRowView: View {
    let species: SpeciesTraits

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(species.name)
                .font(.headline)
            HStack(spacing: 16) {
                Label("\(species.speed) ft", systemImage: "figure.walk")
                if let darkvision = species.darkVision {
                    Label("\(darkvision) ft", systemImage: "eye")
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
        SpeciesPickerView(builderState: CharacterBuilderState())
            .environmentObject(AppState())
    }
}
