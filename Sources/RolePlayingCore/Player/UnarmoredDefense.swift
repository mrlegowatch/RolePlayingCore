//
//  UnarmoredDefense.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// Describes a class feature that modifies the unarmored Armor Class formula.
///
/// Standard formula (all characters): `AC = 10 + DEX modifier`
///
/// With unarmored defense, additional ability modifiers are added:
/// - Barbarian: `AC = 10 + DEX + CON`  → `additionalAbilities: [.constitution]`
/// - Monk:      `AC = 10 + DEX + WIS`  → `additionalAbilities: [.wisdom]`
///
/// JSON format:
/// ```json
/// "unarmored defense": ["Constitution"]
/// ```
public struct UnarmoredDefense: Sendable {
    /// Abilities whose modifiers are added to `10 + DEX` when the character is unarmored.
    public var additionalAbilities: [Ability]

    public init(additionalAbilities: [Ability]) {
        self.additionalAbilities = additionalAbilities
    }
}

extension UnarmoredDefense: Codable {

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var abilities: [Ability] = []
        while !container.isAtEnd {
            let name = try container.decode(String.self)
            abilities.append(Ability(name))
        }
        self.additionalAbilities = abilities
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for ability in additionalAbilities {
            try container.encode(ability.name)
        }
    }
}
