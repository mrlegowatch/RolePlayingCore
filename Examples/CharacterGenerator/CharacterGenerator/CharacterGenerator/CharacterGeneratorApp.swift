//
//  CharacterGeneratorApp.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore
import Combine

@main
struct CharacterGeneratorApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                PlayerListView()
                    .environmentObject(appState)
            } detail: {
                if let selectedPlayer = appState.selectedPlayer {
                    PlayerDetailView(player: selectedPlayer)
                } else {
                    Text("Select a player")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// Shared state for the application
@MainActor
class AppState: ObservableObject {
    @Published var gameData: GameData!
    @Published var characterGenerator: CharacterGenerator!
    @Published var players: Players!
    @Published var selectedPlayer: Player?
    @Published var builderState: CharacterBuilderState?

    init() {
        do {
            gameData = try GameData("Configuration")
            characterGenerator = try CharacterGenerator(gameData)
            players = gameData.players
        } catch {
            fatalError("Failed to initialize configuration: \(error)")
        }
    }

    func addNewCharacter() {
        let player = characterGenerator.makeCharacter()
        players.insert(player, at: 0)
        selectedPlayer = player
    }

    func startBuildingCharacter() {
        let state = CharacterBuilderState()
        state.selectedSpecies = gameData.species["Human"]
        state.selectedClass = gameData.classes["Fighter"]
        state.selectedBackground = gameData.backgrounds["Soldier"]
        builderState = state
    }

    func finalizeBuiltCharacter() {
        guard let player = builderState?.finalize(startingCurrencyUnit: gameData.currencies.baseUnit) else { return }
        players.insert(player, at: 0)
        selectedPlayer = player
        builderState = nil
    }

    func cancelBuildingCharacter() {
        builderState = nil
    }

    func deleteCharacter(at indexSet: IndexSet) {
        for index in indexSet {
            players.remove(at: index)
        }
    }
}
