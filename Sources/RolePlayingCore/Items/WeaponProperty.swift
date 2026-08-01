//
//  WeaponProperty.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// A mechanical property of a weapon (e.g., finesse, thrown).
public struct WeaponProperty: Sendable, Hashable, Codable {
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

extension WeaponProperty: CustomStringConvertible {
    public var description: String { name }
}

// MARK: - Default Weapon Properties

extension WeaponProperty {
    public static let ammunition = WeaponProperty("ammunition")
    public static let finesse = WeaponProperty("finesse")
    public static let heavy = WeaponProperty("heavy")
    public static let light = WeaponProperty("light")
    public static let loading = WeaponProperty("loading")
    public static let reach = WeaponProperty("reach")
    public static let thrown = WeaponProperty("thrown")
    public static let twoHanded = WeaponProperty("two-handed")
    public static let versatile = WeaponProperty("versatile")
    public static let special = WeaponProperty("special")
}
