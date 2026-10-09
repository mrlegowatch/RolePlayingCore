//
//  StatLine.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. Licensed under the MIT License.
//

import SwiftDice

/// A compact creature stat line as printed in an adventure key.
///
/// ## JSON Example
/// ```json
/// { "armorClass": 2, "hitDice": "1", "hitPoints": [6, 5, 5, 5, 5], "attacks": 2, "damage": ["d4+1", "d4+1"], "text": "AC2, HD1, hp6, 5(x4), #AT2, D2-5/2-5" }
/// ```
public struct StatLine: Codable, Hashable, Sendable {
    public var armorClass: Int?
    /// Hit dice in the source's own notation: "1", "1+1", "1-1", "1/4", "4+3", or "2d8+2".
    public var hitDice: String?
    /// Hit points. One value applies to every creature in the group; several values list individuals.
    public var hitPoints: [Int]
    /// Number of attacks per round.
    public var attacks: Int?
    /// Damage per attack, or per alternative weapon, in dice notation.
    public var damage: [AnyRollable]
    /// Whatever does not fit a number: "poison", "battle axe", "per round until washed with water".
    public var special: String?
    /// The stat line exactly as the source prints it.
    public var text: String?

    public init(armorClass: Int? = nil, hitDice: String? = nil, hitPoints: [Int] = [], attacks: Int? = nil,
                damage: [AnyRollable] = [], special: String? = nil, text: String? = nil) {
        self.armorClass = armorClass
        self.hitDice = hitDice
        self.hitPoints = hitPoints
        self.attacks = attacks
        self.damage = damage
        self.special = special
        self.text = text
    }

    /// Hit points for the creature at `index` in its group: the listed value, or the last listed value
    /// when the list is shorter than the group. Nil when no hit points are given.
    public func hitPoints(forCreatureAt index: Int) -> Int? {
        guard !hitPoints.isEmpty else { return nil }
        return hitPoints[Swift.min(index, hitPoints.count - 1)]
    }

    /// `text` when present; otherwise a line built from the fields, e.g. "AC 5, HD 1+1, hp 6, #AT 1, D d6".
    public var summary: String {
        if let text { return text }
        var parts: [String] = []
        if let armorClass { parts.append("AC \(armorClass)") }
        if let hitDice { parts.append("HD \(hitDice)") }
        if !hitPoints.isEmpty { parts.append("hp \(hitPoints.map(String.init).joined(separator: ", "))") }
        if let attacks { parts.append("#AT \(attacks)") }
        if !damage.isEmpty { parts.append("D \(damage.map(\.description).joined(separator: "/"))") }
        if let special { parts.append(special) }
        return parts.joined(separator: ", ")
    }
}

extension StatLine {
    private enum CodingKeys: String, CodingKey {
        case armorClass, hitDice, hitPoints, attacks, damage, special, text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        armorClass = try container.decodeIfPresent(Int.self, forKey: .armorClass)
        hitDice = try container.decodeIfPresent(String.self, forKey: .hitDice)
        hitPoints = try container.decodeIfPresent([Int].self, forKey: .hitPoints) ?? []
        attacks = try container.decodeIfPresent(Int.self, forKey: .attacks)
        damage = try container.decodeIfPresent([AnyRollable].self, forKey: .damage) ?? []
        special = try container.decodeIfPresent(String.self, forKey: .special)
        text = try container.decodeIfPresent(String.self, forKey: .text)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(armorClass, forKey: .armorClass)
        try container.encodeIfPresent(hitDice, forKey: .hitDice)
        if !hitPoints.isEmpty { try container.encode(hitPoints, forKey: .hitPoints) }
        try container.encodeIfPresent(attacks, forKey: .attacks)
        if !damage.isEmpty { try container.encode(damage, forKey: .damage) }
        try container.encodeIfPresent(special, forKey: .special)
        try container.encodeIfPresent(text, forKey: .text)
    }
}
