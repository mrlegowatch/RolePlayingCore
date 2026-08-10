//
//  PlayerListView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct PlayerListView: View {
    @EnvironmentObject var appState: AppState
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        List(selection: $appState.selectedPlayer) {
            ForEach(0..<(appState.players?.count ?? 0), id: \.self) { index in
                if let player = appState.players[index] {
                    PlayerRowView(player: player)
                        .tag(player)
                }
            }
            .onDelete { indexSet in
                appState.deleteCharacter(at: indexSet)
                if let index = indexSet.first, index < appState.players.count, let newPlayer = appState.players[index] {
                    appState.selectedPlayer = newPlayer
                } else {
                    appState.selectedPlayer = nil
                }
            }
        }
        .navigationTitle("Characters")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Quick Character", systemImage: "bolt") {
                        appState.addNewCharacter()
                    }
                    Button("Step by Step", systemImage: "list.bullet") {
                        appState.startBuildingCharacter()
                    }
                } label: {
                    Label("Add Character", systemImage: "plus")
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { appState.builderState != nil },
            set: { if !$0 { appState.cancelBuildingCharacter() } }
        )) {
            CharacterBuilderView()
                .environmentObject(appState)
        }
        .environment(\.editMode, $editMode)
    }
}

struct PlayerRowView: View {
    let player: Player
    
    var body: some View {
        HStack {
            Image(systemName: "tshirt")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                
                Text("Level \(player.level) \(player.speciesName) \(player.className)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        PlayerListView()
            .environmentObject(AppState())
    }
}
