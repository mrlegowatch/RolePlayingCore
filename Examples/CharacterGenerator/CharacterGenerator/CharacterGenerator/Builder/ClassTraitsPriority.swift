//
//  ClassTraitsPriority.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 10/20/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import RolePlayingCore

/// Score-assignment priority for an ability within a given class.
enum AbilityPriority: Int, Comparable {
    case none = 0
    case alternate = 1
    case primary = 2

    static func < (lhs: AbilityPriority, rhs: AbilityPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension ClassTraits {

    /// Returns the score-assignment priority for a given ability.
    func abilityPriority(_ ability: Ability) -> AbilityPriority {
        if primaryAbility.contains(ability) { return .primary }
        if alternatePrimaryAbility?.contains(ability) == true { return .alternate }
        return .none
    }

    /// The six standard abilities sorted by assignment priority descending,
    /// with equal-priority abilities keeping their position in `Ability.defaults`.
    ///
    /// Used by the "Use Suggested" assignment in the character builder to map
    /// the highest rolled scores to the most important abilities for the class.
    var abilitiesByPriority: [Ability] {
        Ability.defaults.sorted { abilityPriority($0) > abilityPriority($1) }
    }
}
