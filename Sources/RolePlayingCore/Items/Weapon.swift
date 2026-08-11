//
//  Weapon.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Foundation

/// A weapon that can be used to make attack rolls.
public struct Weapon: Item {
    public var name: String
    public var plural: String
    public var cost: Money
    public var weight: Weight

    public var category: WeaponCategory
    public var damage: DamageRoll
    
    /// Damage when used two-handed (versatile weapons only).
    public var versatileDamage: DamageRoll?
    
    /// Normal range in feet; `nil` for melee-only weapons.
    public var normalRange: Int?
    
    /// Long range in feet; attacks beyond normal range are made with disadvantage.
    public var longRange: Int?
    public var properties: Set<WeaponProperty>

    public init(
        name: String,
        plural: String? = nil,
        cost: Money,
        weight: Weight,
        category: WeaponCategory,
        damage: DamageRoll,
        versatileDamage: DamageRoll? = nil,
        normalRange: Int? = nil,
        longRange: Int? = nil,
        properties: Set<WeaponProperty> = []
    ) {
        self.name = name
        self.plural = plural ?? name + "s"
        self.cost = cost
        self.weight = weight
        self.category = category
        self.damage = damage
        self.versatileDamage = versatileDamage
        self.normalRange = normalRange
        self.longRange = longRange
        self.properties = properties
    }
}

extension Weapon: CodableWithConfiguration {

    private enum CodingKeys: String, CodingKey {
        case name
        case plural
        case cost
        case weight
        case category
        case damage
        case versatileDamage = "versatile damage"
        case range
        case properties
    }

    public init(from decoder: Decoder, configuration: GameData) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        name = try values.decode(String.self, forKey: .name)
        plural = try values.decodeIfPresent(String.self, forKey: .plural) ?? (name + "s")
        cost = (try? values.decode(Money.self, forKey: .cost, configuration: configuration.currencies)) ?? .zero
        weight = (try? values.decode(Weight.self, forKey: .weight)) ?? Weight(value: 0, unit: .pounds)
        category = try values.decode(WeaponCategory.self, forKey: .category)
        damage = try values.decode(DamageRoll.self, forKey: .damage)
        versatileDamage = try values.decodeIfPresent(DamageRoll.self, forKey: .versatileDamage)

        // Parse range as "normal/long" string, e.g. "20/60" or "150/600"
        if let rangeString = try values.decodeIfPresent(String.self, forKey: .range) {
            let parts = rangeString.split(separator: "/")
            if parts.count == 2, let normal = Int(parts[0]), let long = Int(parts[1]) {
                normalRange = normal
                longRange = long
            } else {
                normalRange = nil
                longRange = nil
            }
        } else {
            normalRange = nil
            longRange = nil
        }

        properties = try values.decodeIfPresent(Set<WeaponProperty>.self, forKey: .properties) ?? []
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
        try values.encode(damage, forKey: .damage)
        try values.encodeIfPresent(versatileDamage, forKey: .versatileDamage)
        if let normal = normalRange, let long = longRange {
            try values.encode("\(normal)/\(long)", forKey: .range)
        }
        if !properties.isEmpty {
            try values.encode(properties, forKey: .properties)
        }
    }
}
