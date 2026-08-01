//
//  WeaponProficiency.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// What weapons a character class is trained to use.
///
/// JSON parsing convention:
/// - Lowercase single/multi-word token → `.category` (e.g., `"simple"`, `"martial"`)
/// - Token with parenthetical property list → `.restricted` (e.g., `"martial (finesse, light)"`)
/// - Title Case token → `.specific` (e.g., `"Longsword"`, `"Hand Crossbow"`)
public enum WeaponProficiency: Sendable, Hashable {
    /// Proficiency with all weapons in this category.
    case category(WeaponCategory)
    /// Proficiency with weapons in this category that have all of the listed properties.
    case restricted(WeaponCategory, Set<WeaponProperty>)
    /// Proficiency with one specific named weapon.
    case specific(String)
}

extension WeaponProficiency {

    /// Parses a proficiency string using the case-and-parenthetical convention.
    public init(parsing string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespaces)

        if let parenStart = trimmed.firstIndex(of: "("),
           let parenEnd = trimmed.lastIndex(of: ")"),
           parenStart < parenEnd {
            let categoryName = String(trimmed[..<parenStart]).trimmingCharacters(in: .whitespaces)
            let propertiesString = trimmed[trimmed.index(after: parenStart)..<parenEnd]
            let properties = Set(
                propertiesString
                    .split(separator: ",")
                    .map { WeaponProperty(String($0).trimmingCharacters(in: .whitespaces)) }
            )
            self = .restricted(WeaponCategory(categoryName), properties)
        } else if let weaponCategory = trimmed.first, weaponCategory.isLowercase {
            // Lowercase-first → category name (e.g., "simple", "martial")
            self = .category(WeaponCategory(trimmed))
        } else {
            // Title Case → specific weapon (e.g., "Longsword", "Hand Crossbow")
            self = .specific(trimmed)
        }
    }
}

extension WeaponProficiency: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = WeaponProficiency(parsing: string)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .category(let category):
            try container.encode(category.name)
        case .restricted(let category, let properties):
            let propertiesString = properties.map(\.name).sorted().joined(separator: ", ")
            try container.encode("\(category.name) (\(propertiesString))")
        case .specific(let name):
            try container.encode(name)
        }
    }
}

extension WeaponProficiency: CustomStringConvertible {

    public var description: String {
        switch self {
        case .category(let category):
            return category.name
        case .restricted(let category, let properties):
            return "\(category.name) (\(properties.map(\.name).sorted().joined(separator: ", ")))"
        case .specific(let name):
            return name
        }
    }
}
