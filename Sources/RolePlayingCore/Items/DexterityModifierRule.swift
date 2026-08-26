//
//  DexterityModifierRule.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// Describes how a wearer's Dexterity modifier applies to Armor Class.
///
/// JSON format: `"full"`, `"excluded"`, `"bonus"`, or `"capped N"` (e.g., `"capped 2"`).
public enum DexterityModifierRule: Sendable, Hashable {
    /// Full Dexterity modifier applies (light armor, unarmored).
    case full
    /// Dexterity modifier applies up to the specified cap (medium armor cap is +2).
    case capped(Int)
    /// No Dexterity modifier (heavy armor).
    case excluded
    /// Adds a flat bonus to existing AC regardless of Dex (shields).
    case bonus
}

extension DexterityModifierRule: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let rule = DexterityModifierRule(parsing: string) {
            self = rule
        } else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unknown dexterity modifier rule: \"\(string)\""
            )
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension DexterityModifierRule {

    /// Parses a terse rule string: `"full"`, `"excluded"`, `"bonus"`, or `"capped N"`.
    public init?(parsing string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        switch trimmed {
        case "full": self = .full
        case "excluded": self = .excluded
        case "bonus": self = .bonus
        default:
            let prefix = "capped "
            if trimmed.hasPrefix(prefix),
               let cap = Int(trimmed.dropFirst(prefix.count)) {
                self = .capped(cap)
            } else {
                return nil
            }
        }
    }
}

extension DexterityModifierRule: CustomStringConvertible {

    public var description: String {
        switch self {
        case .full: return "full"
        case .capped(let cap): return "capped \(cap)"
        case .excluded: return "excluded"
        case .bonus: return "bonus"
        }
    }
}
