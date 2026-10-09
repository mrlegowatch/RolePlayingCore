//
//  Gear.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. Licensed under the MIT License.
//

import Foundation

/// General adventuring equipment, ammunition, arcane foci, and packs.
public struct Gear: Item {
    public var name: String
    public var plural: String
    public var cost: Money
    public var weight: Weight
    
    /// The functional category of a piece of adventuring gear.
    public enum Category: String, Sendable, Hashable, CaseIterable, Codable {
        case general
        case ammunition
        case arcaneFocus = "arcane focus"
        case druidicFocus = "druidic focus"
        case holySymbol = "holy symbol"
        /// A pack that expands to a list of contained items when selected as starting equipment.
        case pack
        case clothing
    }
    public var category: Category
    
    public var description: String?
    
    /// Item names contained in this pack, expanded when a player selects it as starting equipment.
    /// Format matches equipment entry strings: quantity + name (e.g., "10 Torches") or bare name.
    public var contents: [String]?

    public init(
        name: String,
        plural: String? = nil,
        cost: Money,
        weight: Weight,
        category: Category = .general,
        description: String? = nil,
        contents: [String]? = nil
    ) {
        self.name = name
        self.plural = plural ?? name + "s"
        self.cost = cost
        self.weight = weight
        self.category = category
        self.description = description
        self.contents = contents
    }
}

extension Gear: CodableWithConfiguration {

    private enum CodingKeys: String, CodingKey {
        case name
        case plural
        case cost
        case weight
        case category
        case description
        case contents
    }

    public init(from decoder: Decoder, configuration: GameData) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        plural = try container.decodeIfPresent(String.self, forKey: .plural) ?? (name + "s")
        cost = (try? container.decode(Money.self, forKey: .cost, configuration: configuration.currencies)) ?? Money()
        weight = (try? container.decode(Weight.self, forKey: .weight)) ?? Weight(value: 0, unit: .pounds)
        category = try container.decodeIfPresent(Category.self, forKey: .category) ?? .general
        description = try container.decodeIfPresent(String.self, forKey: .description)
        contents = try container.decodeIfPresent([String].self, forKey: .contents)
    }

    public func encode(to encoder: Encoder, configuration: GameData) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        if plural != name + "s" {
            try container.encode(plural, forKey: .plural)
        }
        try container.encode(cost, forKey: .cost, configuration: configuration.currencies)
        try container.encode(weight.value, forKey: .weight)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(contents, forKey: .contents)
    }
}
