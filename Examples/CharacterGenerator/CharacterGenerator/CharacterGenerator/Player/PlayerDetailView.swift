//
//  PlayerDetailView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct PlayerDetailView: View {
    let player: Player
    private var characterSheet: CharacterSheet
    
    init(player: Player) {
        self.player = player
        self.characterSheet = CharacterSheet(player)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<characterSheet.numberOfSections, id: \.self) { section in
                    HStack(spacing: 6) {
                        ForEach(0..<characterSheet.numberOfItems(in: section), id: \.self) { item in
                            traitView(for: section, item: item)
                        }
                    }
                    .padding()
                    .background(.background.secondary)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(player.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private func traitView(for section: Int, item: Int) -> some View {
        let cellIdentifier = characterSheet.cellIdentifiers[section][item]
        let keys = characterSheet.keys[section][item]
        let label = characterSheet.labelKeys[section][item]
        
        switch cellIdentifier {
        case "labeledText":
            let value = characterSheet[keyPath: keys] as! String
            LabeledTextView(label: label, value: value)
        case "labeledNumber":
            let value = characterSheet[keyPath: keys] as! String
            LabeledNumberView(label: label, value: value)
        case "experiencePoints":
            ExperiencePointsView(experiencePoints: ExperiencePoints(player))
        case "abilities":
            AbilitiesView(abilities: player.abilities)
        default:
            Text("Unknown trait type: \(cellIdentifier)")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Character Detail") {
    NavigationStack {
        if let player = try? CharacterGenerator(Configuration("Configuration")).makeCharacter() {
            PlayerDetailView(player: player)
        } else {
            Text("Unable to generate preview")
        }
    }
}
