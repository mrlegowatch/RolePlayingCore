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

    @State private var drawerDetent: PresentationDetent = Self.collapsedDetent

    private static let collapsedDetent: PresentationDetent = .fraction(0.12)
    private static let expandedDetent: PresentationDetent = .fraction(0.45)

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
        .sheet(isPresented: Binding(
            get: { builderState.selectedSpecies != nil },
            set: { _ in }
        )) {
            descriptionDrawer
                .presentationDetents([Self.collapsedDetent, Self.expandedDetent], selection: $drawerDetent)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
                .presentationDragIndicator(.visible)
        }
    }

    private var descriptionDrawer: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(builderState.selectedSpecies?.name ?? "")
                    .font(.title3.bold())
                Spacer()
                if builderState.selectedSpecies?.description != nil {
                    Button {
                        drawerDetent = drawerDetent == Self.expandedDetent
                            ? Self.collapsedDetent
                            : Self.expandedDetent
                    } label: {
                        Image(systemName: drawerDetent == Self.expandedDetent
                              ? "chevron.down.circle.fill"
                              : "chevron.up.circle.fill")
                            .foregroundStyle(.tint)
                            .font(.title3)
                    }
                }
            }
            if drawerDetent == Self.expandedDetent,
               let desc = builderState.selectedSpecies?.description {
                Text(desc)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private func speciesRow(_ species: SpeciesTraits) -> some View {
        let isSelected = builderState.selectedSpecies?.name == species.name
        Button {
            builderState.selectedSpecies = species
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
