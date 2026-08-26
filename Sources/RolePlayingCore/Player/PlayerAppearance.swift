//
//  PlayerAppearance.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// Cosmetic and personal appearance for a player character (hair, eyes, skin, gender, etc.).
/// All traits are stored in a string dictionary; typed computed properties wrap the standard keys.
/// Any non-standard trait can be stored and retrieved via the subscript, e.g.:
/// ```swift
/// appearance[AppearanceTraitKey("tattoo")] = "dragon on left arm"
/// ```
public struct PlayerAppearance: Sendable {
    public enum Gender: String, Codable, CaseIterable, Sendable {
        case female = "Female"
        case male = "Male"
    }

    public var traits: [String: String]

    public init(traits: [String: String] = [:]) {
        self.traits = traits
    }

    public init(gender: Gender? = nil) {
        var t: [String: String] = [:]
        if let gender { t[AppearanceTraitKey.gender.rawValue] = gender.rawValue }
        self.init(traits: t)
    }

    public subscript(_ key: AppearanceTraitKey) -> String? {
        get { traits[key.rawValue] }
        set { traits[key.rawValue] = newValue }
    }

    public var hairColor: String? {
        get { self[.hairColor] }
        set { self[.hairColor] = newValue }
    }

    public var eyeColor: String? {
        get { self[.eyeColor] }
        set { self[.eyeColor] = newValue }
    }

    public var skinColor: String? {
        get { self[.skinColor] }
        set { self[.skinColor] = newValue }
    }

    public var age: String? {
        get { self[.age] }
        set { self[.age] = newValue }
    }

    public var birthdate: String? {
        get { self[.birthdate] }
        set { self[.birthdate] = newValue }
    }

    public var gender: Gender? {
        get { self[.gender].flatMap(Gender.init(rawValue:)) }
        set { self[.gender] = newValue?.rawValue }
    }
}

extension PlayerAppearance: Equatable {}
extension PlayerAppearance: Hashable {}

extension PlayerAppearance: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        traits = try container.decode([String: String].self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(traits)
    }
}
