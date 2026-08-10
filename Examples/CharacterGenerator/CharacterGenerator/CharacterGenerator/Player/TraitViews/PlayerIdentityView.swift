//
//  PlayerIdentityView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 1/3/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct PlayerIdentityView: View {
    let player: Player

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(player.speciesName)
                    .font(.title3.bold())
                Text(player.className)
                    .font(.title3)
                    .foregroundStyle(.tint)
                Spacer()
            }
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Background")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(player.backgroundName)
                        .font(.subheadline)
                }
                if !player.subclassName.isEmpty {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Subclass")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        Text(player.subclassName)
                            .font(.subheadline)
                    }
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
