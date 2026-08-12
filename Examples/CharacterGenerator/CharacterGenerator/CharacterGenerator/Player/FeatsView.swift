//
//  FeatsView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 8/11/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct FeatsView: View {
    let player: Player

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Feats", systemImage: "star.circle")
                .font(.headline)
            ForEach(player.feats, id: \.name) { feat in
                Divider()
                FeatRow(feat: feat)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - FeatRow

private struct FeatRow: View {
    let feat: FeatTraits

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(feat.name)
                    .font(.subheadline.bold())
                Spacer()
                categoryBadge
            }
            if !feat.description.isEmpty {
                Text(feat.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !feat.abilityScoreIncreases.isEmpty || !feat.weaponProficiencies.isEmpty || !feat.armorTraining.isEmpty {
                mechanicalGrants
            }
        }
    }

    private var categoryBadge: some View {
        let color = feat.category.badgeColor
        return Text(feat.category.displayName)
            .font(.caption2)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12), in: Capsule())
    }

    private var mechanicalGrants: some View {
        FlowLayout(spacing: 6) {
            ForEach(feat.abilityScoreIncreases.sorted(by: { $0.key.name < $1.key.name }), id: \.key.name) { entry in
                let sign = entry.value >= 0 ? "+" : ""
                Text("\(sign)\(entry.value) \(entry.key.abbreviated)")
                    .font(.caption)
                    .chipStyle()
            }
            ForEach(feat.weaponProficiencies, id: \.self) { prof in
                Text(prof.description)
                    .font(.caption)
                    .chipStyle()
            }
            ForEach(feat.armorTraining, id: \.self) { armor in
                Text(armor.rawValue.capitalized)
                    .font(.caption)
                    .chipStyle()
            }
        }
    }
}

// MARK: - Category display helpers

private extension FeatTraits.Category {
    var displayName: String {
        switch self {
        case .origin: return "Origin"
        case .general: return "General"
        case .fightingStyle: return "Fighting Style"
        case .epicBoon: return "Epic Boon"
        }
    }

    var badgeColor: Color {
        switch self {
        case .origin: return .blue
        case .general: return .green
        case .fightingStyle: return .orange
        case .epicBoon: return .purple
        }
    }
}

#Preview("Feats View") {
    if let player = try? CharacterGenerator(GameData("Configuration")).makeCharacter() {
        FeatsView(player: player)
            .padding()
    } else {
        Text("No player generated")
    }
}
