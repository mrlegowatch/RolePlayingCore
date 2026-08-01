//
//  WeaponCategory.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// The proficiency category of a weapon (e.g., simple, martial).
public struct WeaponCategory: Sendable, Hashable, Codable {
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

extension WeaponCategory: CustomStringConvertible {
    public var description: String { name }
}

// MARK: - Default Weapon Categories

extension WeaponCategory {
    public static let simple  = WeaponCategory("simple")
    public static let martial = WeaponCategory("martial")
}
