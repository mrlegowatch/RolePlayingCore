//
//  Class.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. Licensed under the MIT License.
//

import Foundation
import SwiftDice

/// The armor category a character class is trained to use.
public typealias ArmorProficiency = Armor.WeightCategory

/// Traits representing a class.
public struct ClassTraits: Named, Sendable {
    public var name: String
    public var plural: String
    public var hitDice: Dice
    public var startingWealth: AnyRollable
    
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
    public var spellcastingAbility: Ability?
    public var spellcastingType: SpellcastingType?
    /// Spell slots indexed by [classLevel-1][slotLevel-1].
    public var spellSlots: [[Int]]?
    /// The named slot table to apply from the class collection, resolved at load time.
    public var slotTableName: String?
    /// Number of cantrips known at character level 1.
    public var cantripsKnown: Int?
    /// Number of spells known or prepared at character level 1.
    public var spellsKnown: Int?

    /// The default background suggested for this class when starting a new character; nil means no suggestion.
    public var defaultBackground: String?

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
                startingWealth: AnyRollable,
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
                spellcastingAbility: Ability? = nil,
                spellcastingType: SpellcastingType? = nil,
                spellSlots: [[Int]]? = nil,
                slotTableName: String? = nil,
                cantripsKnown: Int? = nil,
                spellsKnown: Int? = nil,
                defaultBackground: String? = nil,
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
        self.spellcastingAbility = spellcastingAbility
        self.spellcastingType = spellcastingType
        self.spellSlots = spellSlots
        self.slotTableName = slotTableName
        self.cantripsKnown = cantripsKnown
        self.spellsKnown = spellsKnown
        self.defaultBackground = defaultBackground
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
        case spellcastingAbility = "spellcasting ability"
        case spellcastingType = "spellcasting type"
        case spellSlots = "spell slots"
        case slotTableName = "slot table"
        case cantripsKnown = "cantrips known"
        case spellsKnown = "spells known"
        case defaultBackground = "default background"
        case experiencePoints = "experience points"
    }
    
    public init(from decoder: Decoder, configuration: GameData) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        let name = try container.decode(String.self, forKey: .name)
        let plural = try container.decode(String.self, forKey: .plural)
        let hitDiceRollable = try container.decode(AnyRollable.self, forKey: .hitDice)
        guard let hitDice = hitDiceRollable.rollable as? Dice else {
            let context = DecodingError.Context(
                codingPath: container.codingPath + [CodingKeys.hitDice],
                debugDescription: "Hit dice must be a simple die expression (e.g. \"d10\"), got \"\(hitDiceRollable)\""
            )
            throw DecodingError.dataCorrupted(context)
        }
        let startingWealth = try container.decode(AnyRollable.self, forKey: .startingWealth)
        
        let descriptiveTraits = try container.decodeIfPresent([String:String].self, forKey: .descriptiveTraits)
        let primaryAbility = try container.decodeIfPresent([Ability].self, forKey: .primaryAbility)
        let alternatePrimaryAbility = try container.decodeIfPresent([Ability].self, forKey: .alternatePrimaryAbility)
        let savingThrows = try container.decodeIfPresent([Ability].self, forKey: .savingThrows)
        let startingSkillCount = try container.decodeIfPresent(Int.self, forKey: .startingSkillCount)
        
        // Decode skill proficiency names and resolve them using configuration
        let skillNames = try container.decodeIfPresent([String].self, forKey: .skillProficiencies) ?? []
        let resolvedSkills = try skillNames.skills(from: configuration.skills)
        
        let weaponProficiencyStrings = try container.decodeIfPresent([String].self, forKey: .weaponProficiencies) ?? []
        let weaponProficiencies = weaponProficiencyStrings.map { WeaponProficiency(parsing: $0) }

        let toolProficiencies = try container.decodeIfPresent([String].self, forKey: .toolProficiencies)

        let armorStrings = try container.decodeIfPresent([String].self, forKey: .armorTraining) ?? []
        var armorTraining: [ArmorProficiency] = []
        for string in armorStrings {
            if string == "all" {
                armorTraining = ArmorProficiency.allCases
                break
            } else if let prof = ArmorProficiency(rawValue: string) {
                armorTraining.append(prof)
            }
        }

        let startingEquipment = try container.decodeIfPresent(EquipmentOptions.self, forKey: .startingEquipment, configuration: configuration) ?? []

        let unarmoredDefense = try container.decodeIfPresent(UnarmoredDefense.self, forKey: .unarmoredDefense)

        let subclassTitle = try container.decodeIfPresent(String.self, forKey: .subclassTitle) ?? "Subclass"
        let subclassChoiceLevel = try container.decodeIfPresent(Int.self, forKey: .subclassChoiceLevel) ?? 3
        let subclasses = try container.decodeIfPresent([SubclassTraits].self, forKey: .subclasses, configuration: configuration) ?? []

        let spellcastingAbility = try container.decodeIfPresent(Ability.self, forKey: .spellcastingAbility)
        let spellcastingType = try container.decodeIfPresent(SpellcastingType.self, forKey: .spellcastingType)
        let spellSlots = try container.decodeIfPresent([[Int]].self, forKey: .spellSlots)
        let slotTableName = try container.decodeIfPresent(String.self, forKey: .slotTableName)
        let cantripsKnown = try container.decodeIfPresent(Int.self, forKey: .cantripsKnown)
        let spellsKnown = try container.decodeIfPresent(Int.self, forKey: .spellsKnown)
        let defaultBackground = try container.decodeIfPresent(String.self, forKey: .defaultBackground)

        let experiencePoints = try container.decodeIfPresent([Int].self, forKey: .experiencePoints)

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
        self.spellcastingAbility = spellcastingAbility
        self.spellcastingType = spellcastingType
        self.spellSlots = spellSlots
        self.slotTableName = slotTableName
        self.cantripsKnown = cantripsKnown
        self.spellsKnown = spellsKnown
        self.defaultBackground = defaultBackground

        self.experiencePoints = experiencePoints
    }

    public func encode(to encoder: Encoder, configuration: GameData) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(plural, forKey: .plural)
        try container.encode(AnyRollable(hitDice), forKey: .hitDice)
        try container.encode(startingWealth, forKey: .startingWealth)
        
        try container.encode(descriptiveTraits, forKey: .descriptiveTraits)
        try container.encode(primaryAbility, forKey: .primaryAbility)
        try container.encodeIfPresent(alternatePrimaryAbility, forKey: .alternatePrimaryAbility)
        try container.encode(savingThrows, forKey: .savingThrows)
        try container.encode(startingSkillCount, forKey: .startingSkillCount)
        try container.encode(skillProficiencies.skillNames, forKey: .skillProficiencies)
        try container.encode(weaponProficiencies.map(\.description), forKey: .weaponProficiencies)
        try container.encode(toolProficiencies, forKey: .toolProficiencies)
        try container.encode(armorTraining.map(\.rawValue), forKey: .armorTraining)
        try container.encode(startingEquipment, forKey: .startingEquipment, configuration: configuration)
        try container.encodeIfPresent(unarmoredDefense, forKey: .unarmoredDefense)
        if !subclasses.isEmpty {
            try container.encode(subclassTitle, forKey: .subclassTitle)
            try container.encode(subclassChoiceLevel, forKey: .subclassChoiceLevel)
            try container.encode(subclasses, forKey: .subclasses, configuration: configuration)
        }
        try container.encodeIfPresent(spellcastingAbility, forKey: .spellcastingAbility)
        try container.encodeIfPresent(spellcastingType, forKey: .spellcastingType)
        try container.encodeIfPresent(spellSlots, forKey: .spellSlots)
        try container.encodeIfPresent(cantripsKnown, forKey: .cantripsKnown)
        try container.encodeIfPresent(spellsKnown, forKey: .spellsKnown)
        try container.encodeIfPresent(defaultBackground, forKey: .defaultBackground)

        try container.encodeIfPresent(experiencePoints, forKey: .experiencePoints)
    }
}

extension ClassTraits {

    /// Returns a random array of skill proficiencies, of a count matching startingSkillCount.
    public func randomSkillProficiencies() -> [Skill] {
        return skillProficiencies.randomSkills(count: startingSkillCount)
    }

    /// Returns the skills in the class skill pool that are not already in `excluded`.
    ///
    /// Use this in a character builder to show which class skills a player can still
    /// choose, after background-granted skills have already been applied.
    public func availableSkillChoices(excluding excluded: [Skill]) -> [Skill] {
        let excludedNames = Set(excluded.map { $0.name })
        return skillProficiencies.filter { !excludedNames.contains($0.name) }
    }
}
