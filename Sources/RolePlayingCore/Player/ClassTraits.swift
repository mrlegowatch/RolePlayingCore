//
//  Class.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation
import SwiftDice

/// The armor category a character class is trained to use.
public typealias ArmorProficiency = Armor.WeightCategory

/// Traits representing a class.
public struct ClassTraits: Sendable {
    public var name: String
    public var plural: String
    public var hitDice: Dice
    public var startingWealth: Rollable
    
    public var descriptiveTraits: [String: String]
    public var primaryAbility: [Ability]
    public var alternatePrimaryAbility: [Ability]?
    public var savingThrows: [Ability]
    public var experiencePoints: [Int]?
    public var startingSkillCount: Int
    public var skillProficiencies: [Skill]
    public var weaponProficiencies: [WeaponProficiency]
    public var toolProficiencies: [String]
    public var armorTraining: [ArmorProficiency]
    public var startingEquipment: EquipmentOptions
    public var unarmoredDefense: UnarmoredDefense?
    public var subclassTitle: String
    public var subclassChoiceLevel: Int
    public var subclasses: [SubclassTraits]
        
    /// Accesses the experiencePoints array for the specified 1-based level.
    public func minExperiencePoints(at level: Int) -> Int {
        // Map the level to an index of the array
        let index = max(1, level) - 1
        guard let experiencePoints else { return 0 }
        guard index < experiencePoints.count else { return experiencePoints.last ?? 0 }
        return experiencePoints[index]
    }
    
    /// Accesses the maximum level for this class.
    public var maxLevel: Int {
        guard let experiencePoints else { return 0 }
        return experiencePoints.count
    }
    
    /// Accesses the maximum experience points for the specified 1-based level.
    public func maxExperiencePoints(at level: Int) -> Int {
        guard level > 0 else { return 0 }
        
        // One less than the minimum for the next level
        return minExperiencePoints(at: level + 1) - 1
    }
    
    // TODO: weapons, armor, skills, etc.
    
    public init(name: String,
                plural: String,
                hitDice: Dice,
                startingWealth: Rollable,
                descriptiveTraits: [String: String] = [:],
                primaryAbility: [Ability] = [],
                alternatePrimaryAbility: [Ability]? = nil,
                savingThrows: [Ability] = [],
                startingSkillCount: Int = 2,
                skillProficiencies: [Skill] = [],
                weaponProficiencies: [WeaponProficiency] = [],
                toolProficiencies: [String] = [],
                armorTraining: [ArmorProficiency] = [],
                startingEquipment: EquipmentOptions = [],
                unarmoredDefense: UnarmoredDefense? = nil,
                subclassTitle: String = "Subclass",
                subclassChoiceLevel: Int = 3,
                subclasses: [SubclassTraits] = [],
                experiencePoints: [Int]? = nil) {
        self.name = name
        self.plural = plural
        self.hitDice = hitDice
        self.startingWealth = startingWealth
        
        self.descriptiveTraits = descriptiveTraits
        self.primaryAbility = primaryAbility
        self.alternatePrimaryAbility = alternatePrimaryAbility
        self.savingThrows = savingThrows
        self.startingSkillCount = startingSkillCount
        self.skillProficiencies = skillProficiencies
        self.weaponProficiencies = weaponProficiencies
        self.toolProficiencies = toolProficiencies
        self.armorTraining = armorTraining
        self.startingEquipment = startingEquipment
        self.unarmoredDefense = unarmoredDefense
        self.subclassTitle = subclassTitle
        self.subclassChoiceLevel = subclassChoiceLevel
        self.subclasses = subclasses
        self.experiencePoints = experiencePoints
    }
}

extension ClassTraits: CodableWithConfiguration {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case plural
        case hitDice = "hit dice"
        case startingWealth = "starting wealth"
        case descriptiveTraits = "descriptive traits"
        case primaryAbility = "primary ability"
        case alternatePrimaryAbility = "alternate primary ability"
        case savingThrows = "saving throws"
        case startingSkillCount = "starting skill count"
        case skillProficiencies = "skill proficiencies"
        case weaponProficiencies = "weapon proficiencies"
        case toolProficiencies = "tool proficiencies"
        case armorTraining = "armor training"
        case startingEquipment = "starting equipment"
        case unarmoredDefense = "unarmored defense"
        case subclassTitle = "subclass title"
        case subclassChoiceLevel = "subclass choice level"
        case subclasses
        case experiencePoints = "experience points"
    }
    
    public init(from decoder: Decoder, configuration: Configuration) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        let name = try values.decode(String.self, forKey: .name)
        let plural = try values.decode(String.self, forKey: .plural)
        let hitDiceRollable = try values.decode(Rollable.self, forKey: .hitDice)
        guard let hitDice = hitDiceRollable as? Dice else {
            let context = DecodingError.Context(
                codingPath: values.codingPath + [CodingKeys.hitDice],
                debugDescription: "Hit dice must be a simple die expression (e.g. \"d10\"), got \"\(hitDiceRollable)\""
            )
            throw DecodingError.dataCorrupted(context)
        }
        let startingWealth = try values.decode(Rollable.self, forKey: .startingWealth)
        
        let descriptiveTraits = try values.decodeIfPresent([String:String].self, forKey: .descriptiveTraits)
        let primaryAbility = try values.decodeIfPresent([Ability].self, forKey: .primaryAbility)
        let alternatePrimaryAbility = try values.decodeIfPresent([Ability].self, forKey: .alternatePrimaryAbility)
        let savingThrows = try values.decodeIfPresent([Ability].self, forKey: .savingThrows)
        let startingSkillCount = try values.decodeIfPresent(Int.self, forKey: .startingSkillCount)
        
        // Decode skill proficiency names and resolve them using configuration
        let skillNames = try values.decodeIfPresent([String].self, forKey: .skillProficiencies) ?? []
        let resolvedSkills = try skillNames.skills(from: configuration.skills)
        
        let weaponProficiencyStrings = try values.decodeIfPresent([String].self, forKey: .weaponProficiencies) ?? []
        let weaponProficiencies = weaponProficiencyStrings.map { WeaponProficiency(parsing: $0) }

        let toolProficiencies = try values.decodeIfPresent([String].self, forKey: .toolProficiencies)

        let armorStrings = try values.decodeIfPresent([String].self, forKey: .armorTraining) ?? []
        var armorTraining: [ArmorProficiency] = []
        for string in armorStrings {
            if string == "all" {
                armorTraining = ArmorProficiency.allCases
                break
            } else if let prof = ArmorProficiency(rawValue: string) {
                armorTraining.append(prof)
            }
        }

        let startingEquipment = try values.decodeIfPresent(EquipmentOptions.self, forKey: .startingEquipment, configuration: configuration) ?? []

        let unarmoredDefense = try values.decodeIfPresent(UnarmoredDefense.self, forKey: .unarmoredDefense)

        let subclassTitle = try values.decodeIfPresent(String.self, forKey: .subclassTitle) ?? "Subclass"
        let subclassChoiceLevel = try values.decodeIfPresent(Int.self, forKey: .subclassChoiceLevel) ?? 3
        let subclasses = try values.decodeIfPresent([SubclassTraits].self, forKey: .subclasses) ?? []

        let experiencePoints = try values.decodeIfPresent([Int].self, forKey: .experiencePoints)
        
        // Safely set properties
        self.name = name
        self.plural = plural
        self.hitDice = hitDice
        self.startingWealth = startingWealth
        
        self.descriptiveTraits = descriptiveTraits ?? [:]
        self.primaryAbility = primaryAbility ?? []
        self.alternatePrimaryAbility = alternatePrimaryAbility
        self.savingThrows = savingThrows ?? []
        self.startingSkillCount = startingSkillCount ?? 2
        self.skillProficiencies = resolvedSkills
        self.weaponProficiencies = weaponProficiencies
        self.toolProficiencies = toolProficiencies ?? []
        self.armorTraining = armorTraining
        self.startingEquipment = startingEquipment
        self.unarmoredDefense = unarmoredDefense
        self.subclassTitle = subclassTitle
        self.subclassChoiceLevel = subclassChoiceLevel
        self.subclasses = subclasses

        self.experiencePoints = experiencePoints
    }
        
    public func encode(to encoder: Encoder, configuration: Configuration) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        try values.encode(name, forKey: .name)
        try values.encode(plural, forKey: .plural)
        try values.encode(hitDice, forKey: .hitDice)
        try values.encode(startingWealth, forKey: .startingWealth)
        
        try values.encode(descriptiveTraits, forKey: .descriptiveTraits)
        try values.encode(primaryAbility, forKey: .primaryAbility)
        try values.encodeIfPresent(alternatePrimaryAbility, forKey: .alternatePrimaryAbility)
        try values.encode(savingThrows, forKey: .savingThrows)
        try values.encode(startingSkillCount, forKey: .startingSkillCount)
        try values.encode(skillProficiencies.skillNames, forKey: .skillProficiencies)
        try values.encode(weaponProficiencies.map(\.description), forKey: .weaponProficiencies)
        try values.encode(toolProficiencies, forKey: .toolProficiencies)
        try values.encode(armorTraining.map(\.rawValue), forKey: .armorTraining)
        try values.encode(startingEquipment, forKey: .startingEquipment, configuration: configuration)
        try values.encodeIfPresent(unarmoredDefense, forKey: .unarmoredDefense)
        if !subclasses.isEmpty {
            try values.encode(subclassTitle, forKey: .subclassTitle)
            try values.encode(subclassChoiceLevel, forKey: .subclassChoiceLevel)
            try values.encode(subclasses, forKey: .subclasses)
        }

        try values.encodeIfPresent(experiencePoints, forKey: .experiencePoints)
    }
}

extension ClassTraits {
    
    /// Returns a random array of skill proficiencies, of a count matching startingSkillCount.
    public func randomSkillProficiencies() -> [Skill] {
        return skillProficiencies.randomSkills(count: startingSkillCount)
    }
}
