//
//  ExperiencePoints.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/24/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import Foundation
import RolePlayingCore

class ExperiencePoints {
    
    let player: Player
    
    init(_ player: Player) {
        self.player = player
    }
    
    // Wrapped properties

    var experiencePoints: Int { player.experiencePoints }
    var level: Int { player.level }
    
    var canLevelUp: Bool { player.canLevelUp }
    
    var minExperiencePoints: Int { player.classTraits.minExperiencePoints(at: level) }
    var maxExperiencePoints: Int { player.classTraits.minExperiencePoints(at: level + 1) }
    
    var currentProgress: Double {
        let range = maxExperiencePoints - minExperiencePoints
        let progress = Double(experiencePoints - minExperiencePoints) / Double(range)
        return min(1.0, progress) // clip to 1.0
    }
}
