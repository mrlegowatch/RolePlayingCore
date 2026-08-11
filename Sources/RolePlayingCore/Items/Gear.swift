//
//  Gear.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
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
        let values = try decoder.container(keyedBy: CodingKeys.self)

        name = try values.decode(String.self, forKey: .name)
        plural = try values.decodeIfPresent(String.self, forKey: .plural) ?? (name + "s")
        cost = (try? values.decode(Money.self, forKey: .cost, configuration: configuration.currencies)) ?? Money()
        weight = (try? values.decode(Weight.self, forKey: .weight)) ?? Weight(value: 0, unit: .pounds)
        category = try values.decodeIfPresent(Category.self, forKey: .category) ?? .general
        description = try values.decodeIfPresent(String.self, forKey: .description)
        contents = try values.decodeIfPresent([String].self, forKey: .contents)
    }

    public func encode(to encoder: Encoder, configuration: GameData) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(name, forKey: .name)
        if plural != name + "s" {
            try values.encode(plural, forKey: .plural)
        }
        try values.encode(cost, forKey: .cost, configuration: configuration.currencies)
        try values.encode(weight.value, forKey: .weight)
        try values.encode(category, forKey: .category)
        try values.encodeIfPresent(description, forKey: .description)
        try values.encodeIfPresent(contents, forKey: .contents)
    }
}
