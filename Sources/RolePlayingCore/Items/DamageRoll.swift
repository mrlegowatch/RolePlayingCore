//
//  DamageRoll.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. Licensed under the MIT License.
//

import SwiftDice

/// A weapon's damage expression: a number of dice plus a damage type.
///
/// JSON format: `"<dice> <type>"`, e.g., `"1d8 slashing"` or `"2d6 fire"`.
/// The dice portion uses SwiftDice notation; the type portion is any `DamageType` string.
public struct DamageRoll: Sendable, Equatable, Hashable {
    public var dice: AnyRollable
    public var type: DamageType

    public init(dice: AnyRollable, type: DamageType) {
        self.dice = dice
        self.type = type
    }
}

extension DamageRoll {

    /// Parses `"1d8 slashing"` — last space-delimited word is the damage type,
    /// everything before it is a SwiftDice dice expression.
    public init?(parsing string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard let lastSpace = trimmed.lastIndex(of: " ") else { return nil }
        let diceString = String(trimmed[..<lastSpace])
        let typeString = String(trimmed[trimmed.index(after: lastSpace)...])
        guard let rollable = try? AnyRollable(parsing: diceString) else { return nil }
        self.dice = rollable
        self.type = DamageType(typeString)
    }
}

extension DamageRoll: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let parsed = DamageRoll(parsing: string) else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Could not parse DamageRoll from \"\(string)\". Expected \"<dice> <type>\", e.g. \"1d8 slashing\"."
            )
            throw DecodingError.dataCorrupted(context)
        }
        self = parsed
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(dice) \(type)")
    }
}

extension DamageRoll: CustomStringConvertible {
    public var description: String { "\(dice) \(type)" }
}
