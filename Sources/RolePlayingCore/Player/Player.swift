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

public extension AbilityScores {
    
    /// Sets the ability scores to random values using '4d6-L'.
    mutating func roll() {
        let dice = (4 * .d6).dropping(.lowest)
        for ability in abilities {
            scores[ability] = dice.roll().result
        }
    }
}

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

    public enum Gender: String, Codable, CaseIterable {
        case female = "Female"
        case male = "Male"
    }
    
    /// Androgynous or hermaphroditic are represented as nil.
    public var gender: Gender?
    
    /// An "unaligned" alignment is represented as nil.
    public var alignment: CharacterAlignment?

    public var height: Height

    // TODO: birthdate and age
    
    // TODO: hair, eyes, skin

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

    public var money: Money
    /// All items carried by this player. Equipped state is tracked per entry.
    public var inventory: [InventoryEntry]

    // Spellcasting

    /// Spells currently prepared or known.
    public var preparedSpells: [Spell]
    /// Slots expended at each level since the last long rest (0-indexed; index 0 = 1st-level slots).
    public var usedSpellSlots: [Int]

    /// The worn armor piece, if any (excludes shields).
    public var equippedArmor: Armor? {
        inventory.first(where: { $0.isEquipped && ($0.item as? Armor)?.category != .shield })?.item as? Armor
    }

    /// The held shield, if any.
    public var equippedShield: Armor? {
        inventory.first(where: { $0.isEquipped && ($0.item as? Armor)?.category == .shield })?.item as? Armor
    }

    /// Computed Armor Class.
    /// Without armor, falls back to the class's unarmored defense feature, or base 10 + DEX.
    /// Override by equipping armor or a shield via `inventory`.
    public var armorClass: Int {
        let dexterityModifier: Int = modifiers[.dexterity]
        let shieldBonus = equippedShield?.baseAC ?? 0

        if let armor = equippedArmor {
            switch armor.dexterityModifierRule {
            case .full: return armor.baseAC + dexterityModifier + shieldBonus
            case .capped(let cap): return armor.baseAC + min(dexterityModifier, cap) + shieldBonus
            case .excluded: return armor.baseAC + shieldBonus
            case .bonus: return armor.baseAC + shieldBonus
            }
        }

        // Unarmored: apply class feature if present, otherwise 10 + DEX
        let unarmoredBase = classTraits.unarmoredDefense.map { defense in
            defense.additionalAbilities.reduce(10 + dexterityModifier) { ac, ability in
                ac + (modifiers[ability] ?? 0)
            }
        } ?? (10 + dexterityModifier)

        return unarmoredBase + shieldBonus
    }
    
    /// All weapon proficiencies — from class and from feats.
    public var allWeaponProficiencies: [WeaponProficiency] {
        classTraits.weaponProficiencies + feats.flatMap(\.weaponProficiencies)
    }

    /// All armor weight categories trained in — from class and from feats.
    public var allArmorTraining: [ArmorProficiency] {
        classTraits.armorTraining + feats.flatMap(\.armorTraining)
    }

    // Spellcasting computed properties

    public var spellcastingAbility: Ability? { classTraits.spellcastingAbility }

    public var spellcastingModifier: Int? {
        guard let ability = spellcastingAbility else { return nil }
        return modifiers[ability]
    }

    public var spellSaveDC: Int? {
        spellcastingModifier.map { 8 + proficiencyBonus + $0 }
    }

    public var spellAttackBonus: Int? {
        spellcastingModifier.map { proficiencyBonus + $0 }
    }

    /// Maximum spells that can be prepared: spellcasting modifier + character level, minimum 1.
    public var maxPreparedSpells: Int? {
        guard classTraits.spellcastingType == .prepared,
              let modifier = spellcastingModifier,
              classTraits.spellSlots != nil else { return nil }
        return max(1, modifier + level)
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case backgroundName = "background"
        case speciesName = "species"
        case className = "class"
        case subclassName = "subclass"
        case feats
        case descriptiveTraits = "descriptive traits"
        case gender
        case alignment
        case height
        case baseAbilities = "ability scores"
        case backgroundAbilities = "background ability scores"
        case skillProficiencies = "skill proficiencies"
        case maximumHitPoints = "maximum hit points"
        case currentHitPoints = "current hit points"
        case usedHitDice = "used hit dice"
        case experiencePoints = "experience points"
        case level
        case money
        case inventory
        case preparedSpells = "prepared spells"
        case usedSpellSlots = "used spell slots"
    }

    public required init(from decoder: Decoder, configuration: GameData) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        let name = try values.decode(String.self, forKey: .name)
        let backgroundName = try values.decode(String.self, forKey: .backgroundName)
        let speciesName = try values.decode(String.self, forKey: .speciesName)
        let className = try values.decode(String.self, forKey: .className)
        let descriptiveTraits = try values.decodeIfPresent([String:String].self, forKey: .descriptiveTraits)
        let gender = try values.decodeIfPresent(Gender.self, forKey: .gender)
        let alignment = try values.decodeIfPresent(CharacterAlignment.self, forKey: .alignment)
        let height = try values.decode(Height.self, forKey: .height)
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
        let money = try values.decode(Money.self, forKey: .money, configuration: configuration.currencies)

        let resolvedInventory = try values.decodeIfPresent([InventoryEntry].self, forKey: .inventory, configuration: configuration.items) ?? []

        // Resolve prepared spell names; silently skip any not found in configuration
        let preparedSpellNames = try values.decodeIfPresent([String].self, forKey: .preparedSpells) ?? []
        let preparedSpells = preparedSpellNames.compactMap { configuration.spells[$0] }
        let usedSpellSlots = try values.decodeIfPresent([Int].self, forKey: .usedSpellSlots) ?? []

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
        self.gender = gender
        self.alignment = alignment
        self.height = height
        self.baseAbilities = baseAbilities
        self.backgroundAbilities = backgroundAbilities.map { Ability($0) }
        self.skillProficiencies = resolvedSkills
        self.feats = resolvedFeats.isEmpty ? [backgroundTraits.feat] : resolvedFeats
        self.maximumHitPoints = maximumHitPoints
        self.currentHitPoints = currentHitPoints ?? maximumHitPoints
        self.usedHitDice = usedHitDice
        self.experiencePoints = experiencePoints ?? 0
        self.level = level ?? 1
        self.money = money
        self.inventory = resolvedInventory
        self.preparedSpells = preparedSpells
        self.usedSpellSlots = usedSpellSlots
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
        try values.encodeIfPresent(gender, forKey: .gender)
        try values.encodeIfPresent(alignment, forKey: .alignment)
        try values.encode("\(height)", forKey: .height)
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
        try values.encode(money, forKey: .money, configuration: configuration.currencies)
        if !inventory.isEmpty {
            try values.encode(inventory, forKey: .inventory, configuration: configuration.items)
        }
        if !preparedSpells.isEmpty {
            try values.encode(preparedSpells.map(\.name), forKey: .preparedSpells)
        }
        if !usedSpellSlots.isEmpty {
            try values.encode(usedSpellSlots, forKey: .usedSpellSlots)
        }
     }
    
    // Creates a player character with explicit ability scores and skill proficiencies.
    public init(_ name: String, backgroundTraits: BackgroundTraits, speciesTraits: SpeciesTraits, classTraits: ClassTraits, baseAbilities: AbilityScores, skillProficiencies: [Skill], gender: Gender? = nil, alignment: CharacterAlignment? = nil) {
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
        let money = Money(value: Double(startingWealth), unit: .baseUnit())

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
        self.gender = gender
        self.alignment = alignment
        self.height = height
        self.baseAbilities = baseAbilities
        self.backgroundAbilities = backgroundAbilities
        self.skillProficiencies = skillProficiencies
        self.feats = [backgroundTraits.feat]
        self.maximumHitPoints = maxHP
        self.currentHitPoints = maxHP
        self.usedHitDice = 0
        self.money = money
        self.inventory = inventoryEntries
        self.preparedSpells = []
        self.usedSpellSlots = []
        self.experiencePoints = 0
        self.level = 1
    }

    // Creates a player character by rolling random ability scores and selecting random skill proficiencies.
    public convenience init(_ name: String, backgroundTraits: BackgroundTraits, speciesTraits: SpeciesTraits, classTraits: ClassTraits, gender: Gender? = nil, alignment: CharacterAlignment? = nil) {
        var baseAbilities = AbilityScores()
        baseAbilities.roll()

        var skillProficiencies = classTraits.randomSkillProficiencies()
        skillProficiencies.append(backgroundTraits.skillProficiencies)

        self.init(name, backgroundTraits: backgroundTraits, speciesTraits: speciesTraits, classTraits: classTraits, baseAbilities: baseAbilities, skillProficiencies: skillProficiencies, gender: gender, alignment: alignment)
    }
    
    // MARK: Implementation
    
    public class func rollHitPoints(classTraits: ClassTraits, speciesTraits: SpeciesTraits) -> Int {
        return max(classTraits.hitDice.sides / 2 + 1, classTraits.hitDice.roll().result)
    }
    
    public func rollHitPoints() -> Int {
        return Player.rollHitPoints(classTraits: classTraits, speciesTraits: speciesTraits)
    }

    public var canLevelUp: Bool {
        return level < classTraits.maxLevel && experiencePoints > classTraits.maxExperiencePoints(at: level)
    }

    /// Describes what changed and what choices are pending after a level-up.
    public struct LevelUpResult: Sendable {
        /// The new character level.
        public let newLevel: Int
        /// Hit points added to both maximum and current HP.
        public let hitPointsGained: Int
        /// The feat category to select at this level, or nil if no feat is awarded.
        public let featCategoryToSelect: FeatTraits.Category?
        /// True when this level triggers subclass selection and choices are available.
        public let requiresSubclassSelection: Bool
    }

    /// Levels up the character if the XP threshold has been reached.
    ///
    /// Returns a `LevelUpResult` describing HP gained and any pending choices
    /// (feat selection, subclass selection) the UI needs to present, or `nil`
    /// if the level-up precondition was not met.
    @discardableResult
    public func levelUp() -> LevelUpResult? {
        guard canLevelUp else { return nil }

        level += 1

        let hpGained = rollHitPoints()
        maximumHitPoints += hpGained
        currentHitPoints += hpGained

        let featCategory: FeatTraits.Category?
        switch level {
        case 20:            featCategory = .epicBoon
        case 4, 8, 12, 16, 19: featCategory = .general
        default:            featCategory = nil
        }

        let requiresSubclassSelection =
            subclassTraits == nil &&
            level == classTraits.subclassChoiceLevel &&
            !classTraits.subclasses.isEmpty

        return LevelUpResult(
            newLevel: level,
            hitPointsGained: hpGained,
            featCategoryToSelect: featCategory,
            requiresSubclassSelection: requiresSubclassSelection
        )
    }

    /// Assigns a subclass to this character.
    ///
    /// Silently ignored if the character's level is below `classTraits.subclassChoiceLevel`
    /// or if the subclass does not belong to the character's class.
    public func selectSubclass(_ subclass: SubclassTraits) {
        guard level >= classTraits.subclassChoiceLevel,
              classTraits.subclasses.contains(subclass) else { return }
        subclassTraits = subclass
    }

    // MARK: Rest

    /// The result of a short rest: how many hit dice were spent and how much HP was restored.
    public struct ShortRestResult: Sendable {
        public let hitDiceSpent: Int
        public let hitPointsGained: Int
    }

    /// Spends up to `hitDiceToSpend` hit dice from the available pool.
    ///
    /// Each die is rolled (using the class hit die) and the Constitution modifier is added;
    /// the per-die contribution is floored at 0. Healed HP is capped at `maximumHitPoints`.
    /// Requesting more dice than `availableHitDice` silently spends only what remains.
    @discardableResult
    public func shortRest(hitDiceToSpend: Int) -> ShortRestResult {
        let toSpend = min(max(0, hitDiceToSpend), availableHitDice)
        guard toSpend > 0 else {
            return ShortRestResult(hitDiceSpent: 0, hitPointsGained: 0)
        }

        let constitutionModifier: Int = modifiers[.constitution]
        var totalHealed = 0
        for _ in 0..<toSpend {
            totalHealed += max(0, classTraits.hitDice.roll().result + constitutionModifier)
        }

        let before = currentHitPoints
        currentHitPoints = min(maximumHitPoints, currentHitPoints + totalHealed)
        usedHitDice += toSpend

        return ShortRestResult(hitDiceSpent: toSpend, hitPointsGained: currentHitPoints - before)
    }

    /// Restores all hit points, all spent hit dice, and all expended spell slots (5e 2024 rules).
    public func longRest() {
        currentHitPoints = maximumHitPoints
        usedHitDice = 0
        usedSpellSlots = []
    }

    // MARK: - Spellcasting

    /// Returns the total spell slots at the given 1-based slot level for the character's current class level.
    public func totalSpellSlots(at slotLevel: Int) -> Int {
        guard slotLevel >= 1,
              let slots = classTraits.spellSlots,
              level >= 1, level <= slots.count else { return 0 }
        let levelSlots = slots[level - 1]
        guard slotLevel <= levelSlots.count else { return 0 }
        return levelSlots[slotLevel - 1]
    }

    /// Returns the number of remaining unused spell slots at the given 1-based slot level.
    public func availableSpellSlots(at slotLevel: Int) -> Int {
        let total = totalSpellSlots(at: slotLevel)
        guard slotLevel >= 1, slotLevel <= usedSpellSlots.count else { return total }
        return max(0, total - usedSpellSlots[slotLevel - 1])
    }

    /// Adds a spell to the prepared list. Ignored if the spell is already prepared.
    public func prepareSpell(_ spell: Spell) {
        guard !preparedSpells.contains(spell) else { return }
        preparedSpells.append(spell)
    }

    /// Removes a spell from the prepared list. Ignored if the spell is not prepared.
    public func unprepareSpell(_ spell: Spell) {
        preparedSpells.removeAll { $0 == spell }
    }

    /// Expends one spell slot at the given 1-based slot level.
    ///
    /// Returns `true` if a slot was available and expended, `false` if no slots remain at that level.
    @discardableResult
    public func castSpell(usingSlotLevel slotLevel: Int) -> Bool {
        guard availableSpellSlots(at: slotLevel) > 0 else { return false }
        if slotLevel > usedSpellSlots.count {
            usedSpellSlots += Array(repeating: 0, count: slotLevel - usedSpellSlots.count)
        }
        usedSpellSlots[slotLevel - 1] += 1
        return true
    }

    // MARK: - Inventory

    /// Adds `quantity` of `item` to inventory.
    ///
    /// If an entry for this item already exists (matched by name) its quantity is increased;
    /// otherwise a new entry is appended. Calls with `quantity` ≤ 0 are ignored.
    public func addToInventory(_ item: any Item, quantity: Int = 1) {
        guard quantity > 0 else { return }
        if let index = inventory.firstIndex(where: { $0.item.name == item.name }) {
            inventory[index].quantity += quantity
        } else {
            inventory.append(InventoryEntry(item: item, quantity: quantity))
        }
    }

    /// Removes the inventory entry with the given ID. Ignored if no matching entry exists.
    public func removeFromInventory(id: UUID) {
        inventory.removeAll { $0.id == id }
    }

    /// Equips the inventory entry with the given ID.
    ///
    /// When equipping a non-shield armor, any other equipped non-shield armor is automatically
    /// unequipped first. When equipping a shield, any other equipped shield is unequipped first.
    /// Non-armor items are equipped without exclusivity enforcement.
    /// Ignored if no entry with the given ID exists.
    public func equipItem(id: UUID) {
        guard let index = inventory.firstIndex(where: { $0.id == id }) else { return }
        if let armor = inventory[index].item as? Armor {
            if armor.category == .shield {
                for i in inventory.indices where inventory[i].isEquipped {
                    if (inventory[i].item as? Armor)?.category == .shield {
                        inventory[i].isEquipped = false
                    }
                }
            } else {
                for i in inventory.indices where inventory[i].isEquipped {
                    if let a = inventory[i].item as? Armor, a.category != .shield {
                        inventory[i].isEquipped = false
                    }
                }
            }
        }
        inventory[index].isEquipped = true
    }

    /// Unequips the inventory entry with the given ID. Ignored if no matching entry exists.
    public func unequipItem(id: UUID) {
        guard let index = inventory.firstIndex(where: { $0.id == id }) else { return }
        inventory[index].isEquipped = false
    }

    /// Sets the quantity of the inventory entry with the given ID.
    ///
    /// If `quantity` is 0 or less, the entry is removed from inventory.
    /// Ignored if no entry with the given ID exists.
    public func adjustQuantity(_ quantity: Int, for id: UUID) {
        guard let index = inventory.firstIndex(where: { $0.id == id }) else { return }
        if quantity <= 0 {
            inventory.remove(at: index)
        } else {
            inventory[index].quantity = quantity
        }
    }
}

extension Player: Hashable {
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.name == rhs.name &&
               lhs.backgroundName == rhs.backgroundName &&
               lhs.speciesName == rhs.speciesName &&
               lhs.className == rhs.className &&
               lhs.descriptiveTraits == rhs.descriptiveTraits &&
               lhs.gender == rhs.gender &&
               lhs.alignment == rhs.alignment &&
               lhs.height == rhs.height &&
               lhs.baseAbilities == rhs.baseAbilities &&
               lhs.maximumHitPoints == rhs.maximumHitPoints &&
               lhs.currentHitPoints == rhs.currentHitPoints &&
               lhs.usedHitDice == rhs.usedHitDice &&
               lhs.experiencePoints == rhs.experiencePoints &&
               lhs.level == rhs.level &&
               lhs.money == rhs.money &&
               lhs.inventory.map(\.item.name) == rhs.inventory.map(\.item.name)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(backgroundName)
        hasher.combine(speciesName)
        hasher.combine(className)
        hasher.combine(gender)
        hasher.combine(alignment)
        hasher.combine(height)
        hasher.combine(baseAbilities)
        hasher.combine(maximumHitPoints)
        hasher.combine(currentHitPoints)
        hasher.combine(usedHitDice)
        hasher.combine(experiencePoints)
        hasher.combine(level)
        hasher.combine(money)
        hasher.combine(inventory.map(\.item.name))
    }
}
