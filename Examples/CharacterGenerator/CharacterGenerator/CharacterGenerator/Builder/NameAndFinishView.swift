//
//  NameAndFinishView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct NameAndFinishView: View {
    @EnvironmentObject var appState: AppState
    @Bindable var builderState: CharacterBuilderState
    @State private var ethics: Ethics? = nil
    @State private var morals: Morals? = nil

    private var allSkills: String {
        let chosen = builderState.chosenSkills.map(\.name)
        let background = builderState.selectedBackground?.skillProficiencies.map(\.name) ?? []
        return (chosen + background).sorted().joined(separator: ", ")
    }

    var body: some View {
        List {
            Section("Name") {
                HStack {
                    TextField("Character name", text: $builderState.name)
                    Divider()
                    Button("Suggest") {
                        guard let species = builderState.selectedSpecies else { return }
                        builderState.name = appState.characterGenerator.randomName(
                            speciesTraits: species, gender: builderState.gender)
                    }
                    .buttonStyle(.borderless)
                    .disabled(builderState.selectedSpecies == nil)
                }
            }

            Section("Optional") {
                Picker("Gender", selection: $builderState.gender) {
                    Text("Any").tag(Player.Gender?.none)
                    ForEach(Player.Gender.allCases, id: \.self) { g in
                        Text(g.rawValue).tag(Player.Gender?.some(g))
                    }
                }
                Picker("Ethics", selection: $ethics) {
                    Text("Any").tag(Ethics?.none)
                    ForEach(Ethics.allCases, id: \.self) { e in
                        Text(e.rawValue).tag(Ethics?.some(e))
                    }
                }
                Picker("Morals", selection: $morals) {
                    Text("Any").tag(Morals?.none)
                    ForEach(Morals.allCases, id: \.self) { m in
                        Text(m.rawValue).tag(Morals?.some(m))
                    }
                }
            }

            Section("Summary") {
                LabeledContent("Species", value: builderState.selectedSpecies?.name ?? "")
                LabeledContent("Class", value: builderState.selectedClass?.name ?? "")
                LabeledContent("Background", value: builderState.selectedBackground?.name ?? "")
                if !allSkills.isEmpty {
                    LabeledContent("Skills", value: allSkills)
                }
            }
        }
        .navigationTitle("Name & Finish")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if let alignment = builderState.alignment {
                ethics = alignment.kind.ethics
                morals = alignment.kind.morals
            }
        }
        .onChange(of: ethics) { _, _ in updateAlignment() }
        .onChange(of: morals) { _, _ in updateAlignment() }
    }

    private func updateAlignment() {
        guard let e = ethics, let m = morals else {
            builderState.alignment = nil
            return
        }
        builderState.alignment = CharacterAlignment(e, m)
    }
}

#Preview {
    NavigationStack {
        NameAndFinishView(builderState: CharacterBuilderState())
            .environmentObject(AppState())
    }
}
