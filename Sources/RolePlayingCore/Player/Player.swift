//
//  Player.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/11/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation
import Observation
import SwiftDice

/// The base class for a player character, including its background, species, class, abilities, skills, hit points, and so on.
@Observable
public class Player: CodableWithConfiguration {
    /// The player's name.
    public var name: String
    
    public var backgroundTraits: BackgroundTraits
    public var speciesTraits: SpeciesTraits
    public var classTraits: ClassTraits
    public var subclassTraits: SubclassTraits?

    public var backgroundName: String { backgroundTraits.name }
    public var speciesName: String { speciesTraits.name }
    public var className: String { classTraits.name }
    public var subclassName: String { subclassTraits?.name ?? "" }

    public var feats: [FeatTraits]

    public private(set) var skillProficiencies: [Skill]

    /// Descriptive traits, such as ideals, bonds, flaws, a background story, etc.
    public var descriptiveTraits: [String: String]

    /// An "unaligned" alignment is represented as nil.
    public var alignment: CharacterAlignment?

    /// Cosmetic and personal appearance (hair, eyes, skin, gender, etc.).
    public var appearance: PlayerAppearance

    /// Intrinsic height, in feet. May be temporarily altered by spells (e.g. Enlarge/Reduce).
    public var baseHeight: Height

    /// Effective height, accounting for any active spell effects.
    public var height: Height { baseHeight }

    /// Ability scores
    
    public var baseAbilities: AbilityScores
    public var backgroundAbilities: [Ability]
    public var backgroundAbilityIncrease: AbilityScores {
        var scores = AbilityScores()
        for ability in backgroundAbilities {
            let current = scores[ability] ?? 0
            scores[ability] = current + 1
        }
        return scores
    }
    
    public var featAbilityIncrease: AbilityScores {
        var combined: [Ability: Int] = [:]
        for feat in feats {
            for (ability, amount) in feat.abilityScoreIncreases {
                combined[ability, default: 0] += amount
            }
        }
        return AbilityScores(combined)
    }

    // TODO: limit adding backgroundAbilityIncrease to max score of 20
    public var abilities: AbilityScores { baseAbilities + backgroundAbilityIncrease + featAbilityIncrease }
    public var modifiers: AbilityScores { abilities.modifiers }
        
    /// Hit points, hit dice, experience points, and level
    
    public var maximumHitPoints: Int
    public var currentHitPoints: Int
    public var experiencePoints: Int
    public var level: Int

    /// Hit dice spent on short rests since the last long rest.
    public var usedHitDice: Int

    public var speed: Int { speciesTraits.speed }
    public var size: CreatureSize { CreatureSize(from: height) }

    public var hitDice: Rollable { level * classTraits.hitDice }
    /// Hit dice remaining in the pool (total pool = level; restored on long rest).
    public var availableHitDice: Int { level - usedHitDice }

    public var proficiencyBonus: Int { 2 + (level - 1) / 4 }
    public var passivePerception: Int { 10 + modifiers[.wisdom] }
    
    /// Initiative
    
    public var initiativeModifier: Int { modifiers[.dexterity] }
    public var initiativeScore: Int { 10 + initiativeModifier }

    // Equipment and money

    public var inventory: Inventory

    // Spellcasting

    /// Prepared spells, expended spell slots, and related state.
    public var spellbook: Spellbook

    private enum CodingKeys: String, CodingKey {
        case name
        case backgroundName = "background"
        case speciesName = "species"
        case className = "class"
        case subclassName = "subclass"
        case feats
        case descriptiveTraits = "descriptive traits"
        case alignment
        case appearance
        case height
        case baseAbilities = "ability scores"
        case backgroundAbilities = "background ability scores"
        case skillProficiencies = "skill proficiencies"
        case maximumHitPoints = "maximum hit points"
        case currentHitPoints = "current hit points"
        case usedHitDice = "used hit dice"
        case experiencePoints = "experience points"
        case level
        case inventory
        case spellbook
    }

    public required init(from decoder: Decoder, configuration: GameData) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        let name = try values.decode(String.self, forKey: .name)
        let backgroundName = try values.decode(String.self, forKey: .backgroundName)
        let speciesName = try values.decode(String.self, forKey: .speciesName)
        let className = try values.decode(String.self, forKey: .className)
        let descriptiveTraits = try values.decodeIfPresent([String:String].self, forKey: .descriptiveTraits)
        let alignment = try values.decodeIfPresent(CharacterAlignment.self, forKey: .alignment)
        let appearance = try values.decode(PlayerAppearance.self, forKey: .appearance)
        let baseHeight = try values.decode(Height.self, forKey: .height)
        let baseAbilities = try values.decode(AbilityScores.self, forKey: .baseAbilities)
        let backgroundAbilities = try values.decode([String].self, forKey: .backgroundAbilities)
        
        // Decode skill proficiency names and resolve them using configuration
        let skillNames = try values.decode([String].self, forKey: .skillProficiencies)
        var resolvedSkills: [Skill] = []
        for skillName in skillNames {
            guard let skill = configuration.skills[skillName] else {
                throw missingTypeError("skill", skillName)
            }
            resolvedSkills.append(skill)
        }

        // Decode feat names and resolve them using configuration; fall back to background feat if absent
        let featNames = try values.decodeIfPresent([String].self, forKey: .feats)
        var resolvedFeats: [FeatTraits] = []
        if let featNames {
            for featName in featNames {
                guard let feat = configuration.feats[featName] else {
                    throw missingTypeError("feat", featName)
                }
                resolvedFeats.append(feat)
            }
        }
        
        let maximumHitPoints = try values.decode(Int.self, forKey: .maximumHitPoints)
        let currentHitPoints = try values.decodeIfPresent(Int.self, forKey: .currentHitPoints)
        let usedHitDice = try values.decodeIfPresent(Int.self, forKey: .usedHitDice) ?? 0
        let experiencePoints = try values.decodeIfPresent(Int.self, forKey: .experiencePoints)
        let level = try values.decodeIfPresent(Int.self, forKey: .level)
        let inventory = try values.decode(Inventory.self, forKey: .inventory, configuration: configuration)
        let spellbook = try values.decodeIfPresent(Spellbook.self, forKey: .spellbook, configuration: configuration) ?? Spellbook()

        // Resolve backgroundTraits from configuration
        guard let backgroundTraits = configuration.backgrounds[backgroundName] else {
            throw missingTypeError("background", backgroundName)
        }
        
        // Resolve speciesTraits from configuration
        guard let speciesTraits = configuration.species[speciesName] else {
            throw missingTypeError("species", speciesName)
        }
        
        // Resolve classTraits from configuration
        guard let classTraits = configuration.classes[className] else {
            throw missingTypeError("class", className)
        }

        let subclassTraits: SubclassTraits?
        if let subclassName = try values.decodeIfPresent(String.self, forKey: .subclassName) {
            subclassTraits = classTraits.subclasses.first(where: { $0.name == subclassName })
        } else {
            subclassTraits = nil
        }

        // Safely set properties
        self.name = name
        self.descriptiveTraits = descriptiveTraits ?? [:]
        self.alignment = alignment
        self.appearance = appearance
        self.baseHeight = baseHeight
        self.baseAbilities = baseAbilities
        self.backgroundAbilities = backgroundAbilities.map { Ability($0) }
        self.skillProficiencies = resolvedSkills
        self.feats = resolvedFeats.isEmpty ? [backgroundTraits.feat] : resolvedFeats
        self.maximumHitPoints = maximumHitPoints
        self.currentHitPoints = currentHitPoints ?? maximumHitPoints
        self.usedHitDice = usedHitDice
        self.experiencePoints = experiencePoints ?? 0
        self.level = level ?? 1
        self.inventory = inventory
        self.spellbook = spellbook
        self.backgroundTraits = backgroundTraits
        self.speciesTraits = speciesTraits
        self.classTraits = classTraits
        self.subclassTraits = subclassTraits
    }
    
    public func encode(to encoder: Encoder, configuration: GameData) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        try values.encode(name, forKey: .name)
        try values.encode(backgroundName, forKey: .backgroundName)
        try values.encode(speciesName, forKey: .speciesName)
        try values.encode(className, forKey: .className)
        if let subclassTraits {
            try values.encode(subclassTraits.name, forKey: .subclassName)
        }
        try values.encodeIfPresent(descriptiveTraits, forKey: .descriptiveTraits)
        try values.encodeIfPresent(alignment, forKey: .alignment)
        try values.encode(appearance, forKey: .appearance)
        try values.encode(baseHeight.value, forKey: .height)
        try values.encode(baseAbilities, forKey: .baseAbilities)
        try values.encode(backgroundAbilities.map({ $0.name }), forKey: .backgroundAbilities)
        try values.encode(skillProficiencies.skillNames, forKey: .skillProficiencies)
        try values.encode(feats.map(\.name), forKey: .feats)
        try values.encode(maximumHitPoints, forKey: .maximumHitPoints)
        try values.encodeIfPresent(currentHitPoints, forKey: .currentHitPoints)
        if usedHitDice > 0 {
            try values.encode(usedHitDice, forKey: .usedHitDice)
        }
        try values.encodeIfPresent(experiencePoints, forKey: .experiencePoints)
        try values.encodeIfPresent(level, forKey: .level)
        try values.encode(inventory, forKey: .inventory, configuration: configuration)
        if !spellbook.isEmpty {
            try values.encode(spellbook, forKey: .spellbook, configuration: configuration)
        }
     }
    
    // Creates a player character with explicit ability scores and skill proficiencies.
    public init(_ name: String, backgroundTraits: BackgroundTraits, speciesTraits: SpeciesTraits, classTraits: ClassTraits, baseAbilities: AbilityScores, skillProficiencies: [Skill], startingCurrencyUnit: UnitCurrency? = nil, gender: PlayerAppearance.Gender? = nil, alignment: CharacterAlignment? = nil) {
        // @Observable turns stored properties into computed properties backed by _property.
        // The observation getter captures `self`, so read-modify-write operations and reads
        // of self properties require all stored properties to be initialized first (phase 2).
        // Compute all intermediate values from parameters, then assign all stored properties
        // in one block to satisfy Swift's two-phase init rules.

        // TODO: More heavily weight the first base size (primary vs. secondary)
        let baseSize = speciesTraits.baseSizes.randomElement()!
        let height = Height.randomHeight(from: baseSize)

        // TODO: roll for 2 or 3 background abilities, and if 2, add one random ability score twice
        let backgroundAbilities = backgroundTraits.abilityScores

        let maxHP = Player.rollHitPoints(classTraits: classTraits, speciesTraits: speciesTraits)

        let startingWealth = classTraits.startingWealth.roll().result
        let money = startingCurrencyUnit.map { Money(startingWealth, of: $0) } ?? Money()

        // Populate inventory from the first starting equipment option.
        // Money entries within equipment options are not added to inventory.
        // Pack items are added as a single entry — expand contents when the player selects equipment.
        let firstOption = classTraits.startingEquipment.first ?? []
        let bgFirstOption = backgroundTraits.equipment.first ?? []
        var inventoryEntries: [InventoryEntry] = []
        for entry in firstOption + bgFirstOption {
            if case .item(let item, let qty) = entry {
                inventoryEntries.append(InventoryEntry(item: item, quantity: qty))
            }
        }

        self.name = name
        self.descriptiveTraits = [:]
        self.backgroundTraits = backgroundTraits
        self.speciesTraits = speciesTraits
        self.classTraits = classTraits
        self.subclassTraits = nil
        self.alignment = alignment
        self.baseHeight = height
        self.appearance = PlayerAppearance(gender: gender)
        self.baseAbilities = baseAbilities
        self.backgroundAbilities = backgroundAbilities
        self.skillProficiencies = skillProficiencies
        self.feats = [backgroundTraits.feat]
        self.maximumHitPoints = maxHP
        self.currentHitPoints = maxHP
        self.usedHitDice = 0
        self.inventory = Inventory(entries: inventoryEntries, money: money)
        self.spellbook = Spellbook()
        self.experiencePoints = 0
        self.level = 1
    }

    // Creates a player character by rolling random ability scores and selecting random skill proficiencies.
    public convenience init(_ name: String, backgroundTraits: BackgroundTraits, speciesTraits: SpeciesTraits, classTraits: ClassTraits, startingCurrencyUnit: UnitCurrency? = nil, gender: PlayerAppearance.Gender? = nil, alignment: CharacterAlignment? = nil) {
        var baseAbilities = AbilityScores()
        baseAbilities.roll()

        var skillProficiencies = classTraits.randomSkillProficiencies()
        skillProficiencies.append(backgroundTraits.skillProficiencies)

        self.init(name, backgroundTraits: backgroundTraits, speciesTraits: speciesTraits, classTraits: classTraits, baseAbilities: baseAbilities, skillProficiencies: skillProficiencies, startingCurrencyUnit: startingCurrencyUnit, gender: gender, alignment: alignment)
    }
}

extension Player: Hashable {
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.name == rhs.name &&
               lhs.backgroundName == rhs.backgroundName &&
               lhs.speciesName == rhs.speciesName &&
               lhs.className == rhs.className &&
               lhs.descriptiveTraits == rhs.descriptiveTraits &&
               lhs.alignment == rhs.alignment &&
               lhs.appearance == rhs.appearance &&
               lhs.baseHeight == rhs.baseHeight &&
               lhs.baseAbilities == rhs.baseAbilities &&
               lhs.maximumHitPoints == rhs.maximumHitPoints &&
               lhs.currentHitPoints == rhs.currentHitPoints &&
               lhs.usedHitDice == rhs.usedHitDice &&
               lhs.experiencePoints == rhs.experiencePoints &&
               lhs.level == rhs.level &&
               lhs.inventory.money == rhs.inventory.money &&
               lhs.inventory.entries.map(\.item.name) == rhs.inventory.entries.map(\.item.name)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(backgroundName)
        hasher.combine(speciesName)
        hasher.combine(className)
        hasher.combine(alignment)
        hasher.combine(appearance)
        hasher.combine(baseHeight.value)
        hasher.combine(baseAbilities)
        hasher.combine(maximumHitPoints)
        hasher.combine(currentHitPoints)
        hasher.combine(usedHitDice)
        hasher.combine(experiencePoints)
        hasher.combine(level)
        hasher.combine(inventory.money)
        hasher.combine(inventory.entries.map(\.item.name))
    }
}
