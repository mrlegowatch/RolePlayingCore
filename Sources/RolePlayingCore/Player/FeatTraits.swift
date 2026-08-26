//
//  FeatTraits.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/22/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// Traits describing a feat — a special ability a character acquires at character creation
/// or at certain levels.
public struct FeatTraits: Sendable, Equatable {
    public var name: String
    public var description: String
    public var category: Category

    /// The category of a feat, governing when and whether it can be taken.
    public enum Category: String, Codable, CaseIterable, Sendable {
        /// Background feats; no prerequisites; level 1 only
        case origin
        /// Most feats; may have prerequisites
        case general
        case fightingStyle = "fighting style"
        /// Level 20 only
        case epicBoon = "epic boon"
    }

    /// Fixed ability score increases granted by this feat (e.g., `[.strength: 2]`).
    public var abilityScoreIncreases: [Ability: Int]

    /// Weapon proficiencies granted by this feat.
    public var weaponProficiencies: [WeaponProficiency]

    /// Armor weight categories the feat grants training in.
    public var armorTraining: [ArmorProficiency]

    public init(
        name: String,
        description: String = "",
        category: Category = .general,
        abilityScoreIncreases: [Ability: Int] = [:],
        weaponProficiencies: [WeaponProficiency] = [],
        armorTraining: [ArmorProficiency] = []
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.abilityScoreIncreases = abilityScoreIncreases
        self.weaponProficiencies = weaponProficiencies
        self.armorTraining = armorTraining
    }
}

extension FeatTraits: Codable {
    private enum CodingKeys: String, CodingKey {
        case name, description, category
        case abilityScoreIncreases = "ability score increases"
        case weaponProficiencies = "weapon proficiencies"
        case armorTraining = "armor training"
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let name = try values.decode(String.self, forKey: .name)
        let description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        let category = try values.decodeIfPresent(Category.self, forKey: .category) ?? .general

        let rawIncreases = try values.decodeIfPresent([String: Int].self, forKey: .abilityScoreIncreases) ?? [:]
        let abilityScoreIncreases = Dictionary(uniqueKeysWithValues: rawIncreases.map { (Ability($0.key), $0.value) })

        let weaponProficiencies = try values.decodeIfPresent([WeaponProficiency].self, forKey: .weaponProficiencies) ?? []
        let armorTraining = try values.decodeIfPresent([ArmorProficiency].self, forKey: .armorTraining) ?? []

        self.init(name: name, description: description, category: category,
                  abilityScoreIncreases: abilityScoreIncreases,
                  weaponProficiencies: weaponProficiencies,
                  armorTraining: armorTraining)
    }

    public func encode(to encoder: any Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(name, forKey: .name)
        if !description.isEmpty {
            try values.encode(description, forKey: .description)
        }
        if category != .general {
            try values.encode(category, forKey: .category)
        }
        if !abilityScoreIncreases.isEmpty {
            let raw = Dictionary(uniqueKeysWithValues: abilityScoreIncreases.map { ($0.key.name, $0.value) })
            try values.encode(raw, forKey: .abilityScoreIncreases)
        }
        if !weaponProficiencies.isEmpty {
            try values.encode(weaponProficiencies, forKey: .weaponProficiencies)
        }
        if !armorTraining.isEmpty {
            try values.encode(armorTraining, forKey: .armorTraining)
        }
    }
}
