//
//  DamageType.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// The type of damage dealt by a weapon or effect.
public struct DamageType: Sendable, Hashable, Codable {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        name = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

extension DamageType: CustomStringConvertible {
    public var description: String { name }
}

// MARK: - Default Damage Types

extension DamageType {
    // Physical
    public static let slashing = DamageType("slashing")
    public static let piercing = DamageType("piercing")
    public static let bludgeoning = DamageType("bludgeoning")

    // Elemental
    public static let acid = DamageType("acid")
    public static let cold = DamageType("cold")
    public static let fire = DamageType("fire")
    public static let lightning = DamageType("lightning")
    public static let thunder = DamageType("thunder")

    // Arcane / spiritual
    public static let force = DamageType("force")
    public static let necrotic = DamageType("necrotic")
    public static let psychic = DamageType("psychic")
    public static let radiant = DamageType("radiant")
    public static let poison = DamageType("poison")
}
