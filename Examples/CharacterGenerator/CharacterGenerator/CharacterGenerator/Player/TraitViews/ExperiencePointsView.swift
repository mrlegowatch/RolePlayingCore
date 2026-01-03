//
//  ExperiencePointsView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 1/3/26.
//

import SwiftUI
import RolePlayingCore

struct ExperiencePointsView: View {
    let experiencePoints: ExperiencePoints
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Level".uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
                let levelUpString = experiencePoints.canLevelUp ? "*" : ""
                Text("\(experiencePoints.level)\(levelUpString)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Experience Points".uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Text("\(experiencePoints.experiencePoints)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(" / \(experiencePoints.maxExperiencePoints)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                }
            }
            Spacer()
            Text("\(experiencePoints.level)")
                .font(.caption)
                .foregroundStyle(.secondary)
            ProgressView(value: experiencePoints.currentProgress)
            Text("\(experiencePoints.level + 1)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Experience Points") {
    if let player = try? CharacterGenerator(Configuration("Configuration")).makeCharacter() {
        ExperiencePointsView(experiencePoints: ExperiencePoints(player))
            .padding()
    } else {
        Text("Unable to generate preview")
    }
}

