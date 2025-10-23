//
//  CharacterGeneratorApp.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

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
    @Published var configuration: Configuration!
    @Published var characterGenerator: CharacterGenerator!
    @Published var players: Players!
    @Published var selectedPlayer: Player?
    
    init() {
        do {
            configuration = try Configuration("Configuration")
            characterGenerator = try CharacterGenerator(configuration)
            players = configuration.players
        } catch {
            fatalError("Failed to initialize configuration: \(error)")
        }
    }
    
    func addNewCharacter() {
        let player = characterGenerator.makeCharacter()
        players.insert(player, at: 0)
    }
    
    func deleteCharacter(at indexSet: IndexSet) {
        for index in indexSet {
            players.remove(at: index)
        }
    }
}
