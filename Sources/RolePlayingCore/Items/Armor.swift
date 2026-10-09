//
//  Armor.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. Licensed under the MIT License.
//

import Foundation

/// A wearable piece of armor or a shield.
public struct Armor: Item {
    public var name: String
    public var plural: String
    public var cost: Money
    public var weight: Weight

    /// The weight category of armor.
    public enum WeightCategory: String, Sendable, Hashable, CaseIterable, Codable {
        case light
        case medium
        case heavy
        case shield
    }
    public var category: WeightCategory
    
    /// Base AC value before applying any Dexterity modifier.
    /// For shields, this is the flat bonus added to existing AC (+2).
    public var baseAC: Int
    public var dexterityModifierRule: DexterityModifierRule
    /// Minimum Strength score required; characters below this reduce speed by 10 ft.
    public var strengthRequirement: Int?
    public var stealthDisadvantage: Bool

    public init(
        name: String,
        plural: String? = nil,
        cost: Money,
        weight: Weight,
        category: WeightCategory,
        baseAC: Int,
        dexterityModifierRule: DexterityModifierRule,
        strengthRequirement: Int? = nil,
        stealthDisadvantage: Bool = false
    ) {
        self.name = name
        self.plural = plural ?? name + "s"
        self.cost = cost
        self.weight = weight
        self.category = category
        self.baseAC = baseAC
        self.dexterityModifierRule = dexterityModifierRule
        self.strengthRequirement = strengthRequirement
        self.stealthDisadvantage = stealthDisadvantage
    }
}

extension Armor: CodableWithConfiguration {

    private enum CodingKeys: String, CodingKey {
        case name
        case plural
        case cost
        case weight
        case category
        case baseAC = "base ac"
        case dexterityModifierRule = "dexterity modifier"
        case strengthRequirement = "strength requirement"
        case stealthDisadvantage = "stealth disadvantage"
    }

    public init(from decoder: Decoder, configuration: GameData) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        plural = try container.decodeIfPresent(String.self, forKey: .plural) ?? (name + "s")
        cost = (try? container.decode(Money.self, forKey: .cost, configuration: configuration.currencies)) ?? Money()
        weight = (try? container.decode(Weight.self, forKey: .weight)) ?? Weight(value: 0, unit: .pounds)
        category = try container.decode(WeightCategory.self, forKey: .category)
        baseAC = try container.decode(Int.self, forKey: .baseAC)
        dexterityModifierRule = try container.decode(DexterityModifierRule.self, forKey: .dexterityModifierRule)
        strengthRequirement = try container.decodeIfPresent(Int.self, forKey: .strengthRequirement)
        stealthDisadvantage = try container.decodeIfPresent(Bool.self, forKey: .stealthDisadvantage) ?? false
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
        try container.encode(baseAC, forKey: .baseAC)
        try container.encode(dexterityModifierRule, forKey: .dexterityModifierRule)
        try container.encodeIfPresent(strengthRequirement, forKey: .strengthRequirement)
        if stealthDisadvantage {
            try container.encode(stealthDisadvantage, forKey: .stealthDisadvantage)
        }
    }
}
