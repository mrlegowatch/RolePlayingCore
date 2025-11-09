//
//  Player.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/11/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

public extension AbilityScores {
    
    /// Sets the ability scores to random values using '4d6-L'.
    mutating func roll() {
        let dice = DroppingDice(.d6, times: 4, drop: .lowest)
        for ability in abilities {
            scores[ability] = dice.roll().result
        }
    }
}

public extension Dice {
    
    /// Returns a dice with a number of rolls corresponding to level.
    func hitDice(level: Int) -> Dice {
        return SimpleDice(Die(rawValue: self.sides)!, times: level)
    }
}

/// The base class for a player character, including its background, species, class, abilities, skills, hit points, and so on.
public class Player: CodableWithConfiguration {
    
    /// The player's name.
    public var name: String
    
    public var backgroundTraits: BackgroundTraits!
    public var speciesTraits: SpeciesTraits!
    public var classTraits: ClassTraits!

    public var backgroundName: String { backgroundTraits?.name ?? "" }
    public var speciesName: String { speciesTraits?.name ?? "" }
    public var className: String { classTraits?.name ?? "" }

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
    public var alignment: Alignment?

    public var height: Height

    // TODO: birthdate and age
    
    // TODO: hair, eyes, skin

    /// Ability scores
    
    public var baseAbilities: AbilityScores
    public var backgroundAbilities: [Ability]
    public var backgroundAbilityIncrease: AbilityScores {
        var scores = AbilityScores()
        for ability in backgroundAbilities {
            scores[ability]! += 1
        }
        return scores
    }
    
    // TODO: limit adding backgroundAbilityIncrease to max score of 20
    public var abilities: AbilityScores { baseAbilities + backgroundAbilityIncrease }
    public var modifiers: AbilityScores { abilities.modifiers }
        
    /// Hit points, hit dice, experience points, and level
    
    public var maximumHitPoints: Int
    public var currentHitPoints: Int
    public var experiencePoints: Int
    public var level: Int
    
    public var speed: Int { speciesTraits.speed }
    public var size: CreatureSize { CreatureSize(from: height) }
    
    public var hitDice: Dice { classTraits.hitDice.hitDice(level: level) }
    
    public var proficiencyBonus: Int { 2 + (level - 1) / 4 }
    public var passivePerception: Int { 10 + modifiers[.wisdom] }
    
    /// Initiative
    
    public var initiativeModifier: Int { modifiers[.dexterity] }
    public var initiativeScore: Int { 10 + initiativeModifier }

    // Equipment and money
    
    public var money: Money
    public var armorClass: Int = 0 // TODO: compute armor class
    // TODO: equipment, weapons, armor, skills, etc.
    
    private enum CodingKeys: String, CodingKey {
        case name
        case backgroundName = "background"
        case speciesName = "species"
        case className = "class"
        case descriptiveTraits = "descriptive traits"
        case gender
        case alignment
        case height
        case baseAbilities = "ability scores"
        case backgroundAbilities = "background ability scores"
        case skillProficiencies = "skill proficiencies"
        case maximumHitPoints = "maximum hit points"
        case currentHitPoints = "current hit points"
        case experiencePoints = "experience points"
        case level
        case money
    }
    
    public required init(from decoder: Decoder, configuration: Configuration) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        let name = try values.decode(String.self, forKey: .name)
        let backgroundName = try values.decode(String.self, forKey: .backgroundName)
        let speciesName = try values.decode(String.self, forKey: .speciesName)
        let className = try values.decode(String.self, forKey: .className)
        let descriptiveTraits = try values.decodeIfPresent([String:String].self, forKey: .descriptiveTraits)
        let gender = try values.decodeIfPresent(Gender.self, forKey: .gender)
        let alignment = try values.decodeIfPresent(Alignment.self, forKey: .alignment)
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
        
        let maximumHitPoints = try values.decode(Int.self, forKey: .maximumHitPoints)
        let currentHitPoints = try values.decodeIfPresent(Int.self, forKey: .currentHitPoints)
        let experiencePoints = try values.decodeIfPresent(Int.self, forKey: .experiencePoints)
        let level = try values.decodeIfPresent(Int.self, forKey: .level)
        let money = try values.decode(Money.self, forKey: .money, configuration: configuration.currencies)
        
        // Resolve backgroundTraits from configuration
        guard let backgroundTraits = configuration.backgrounds[backgroundName] else {
            throw missingTypeError("background", backgroundName)
        }
        
        // Resolve speciesTraits from configuration
        guard let speciesTraits = configuration.species.find(speciesName) else {
            throw missingTypeError("species", speciesName)
        }
        
        // Resolve classTraits from configuration
        guard let classTraits = configuration.classes.find(className) else {
            throw missingTypeError("class", className)
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
        self.maximumHitPoints = maximumHitPoints
        self.currentHitPoints = currentHitPoints ?? maximumHitPoints
        self.experiencePoints = experiencePoints ?? 0
        self.level = level ?? 1
        self.money = money
        self.backgroundTraits = backgroundTraits
        self.speciesTraits = speciesTraits
        self.classTraits = classTraits
    }
    
    public func encode(to encoder: Encoder, configuration: Configuration) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        try values.encode(name, forKey: .name)
        try values.encode(backgroundName, forKey: .backgroundName)
        try values.encode(speciesName, forKey: .speciesName)
        try values.encode(className, forKey: .className)
        try values.encodeIfPresent(descriptiveTraits, forKey: .descriptiveTraits)
        try values.encodeIfPresent(gender, forKey: .gender)
        try values.encodeIfPresent(alignment, forKey: .alignment)
        try values.encode("\(height)", forKey: .height)
        try values.encode(baseAbilities, forKey: .baseAbilities)
        try values.encode(backgroundAbilities.map({ $0.name }), forKey: .backgroundAbilities)
        try values.encode(skillProficiencies.skillNames, forKey: .skillProficiencies)
        try values.encode(maximumHitPoints, forKey: .maximumHitPoints)
        try values.encodeIfPresent(currentHitPoints, forKey: .currentHitPoints)
        try values.encodeIfPresent(experiencePoints, forKey: .experiencePoints)
        try values.encodeIfPresent(level, forKey: .level)
        try values.encode(money, forKey: .money, configuration: configuration.currencies)
    }
    
    // Creates a player character.
    public init(_ name: String, backgroundTraits: BackgroundTraits, speciesTraits: SpeciesTraits, classTraits: ClassTraits, gender: Gender? = nil, alignment: Alignment? = nil) {
        self.name = name
        self.descriptiveTraits = [:]
        self.backgroundTraits = backgroundTraits
        self.speciesTraits = speciesTraits
        self.classTraits = classTraits
        self.gender = gender
        self.alignment = alignment
        
        // TODO: More heavily weight the first base size (primary vs. secondary)
        let baseSize = speciesTraits.baseSizes.randomElement()!
        self.height = Height.randomHeight(from: baseSize)
        
        self.baseAbilities = AbilityScores()
        self.baseAbilities.roll()
        
        // TODO: roll for 2 or 3 background abilities, and if 2, add one random ability score twice
        self.backgroundAbilities = backgroundTraits.abilityScores.map { Ability($0) }
        
        var allSkills = classTraits.randomSkillProficiencies()
        allSkills.append(backgroundTraits.skillProficiencies)
        self.skillProficiencies = allSkills

        self.maximumHitPoints = Player.rollHitPoints(classTraits: classTraits, speciesTraits: speciesTraits)
        self.currentHitPoints = self.maximumHitPoints
        
        let startingWealth = classTraits.startingWealth.roll().result
        self.money = Money(value: Double(startingWealth), unit: .baseUnit())
        
        self.experiencePoints = 0
        self.level = 1
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

    public func levelUp() {
        guard canLevelUp else { return }
        
        level += 1
        
        maximumHitPoints += rollHitPoints()
        
        // TODO: add more details for leveling up
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
               lhs.experiencePoints == rhs.experiencePoints &&
               lhs.level == rhs.level &&
               lhs.money == rhs.money
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
        hasher.combine(experiencePoints)
        hasher.combine(level)
        hasher.combine(money)
    }
}
