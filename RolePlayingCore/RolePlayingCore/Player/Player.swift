//
//  Player.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/11/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

public extension AbilityScores {
    
    // Sets the ability scores to random values using 4d6-L
    public mutating func roll() {
        let dice = DroppingDice(.d6, times: 4, drop: .lowest)
        for ability in abilities {
            scores[ability] = dice.roll().result
        }
    }

}

public extension Dice {
    
    // Return a dice with a number of rolls corresponding to level.
    func hitDice(level: Int) -> Dice {
        return SimpleDice(Die(rawValue: self.sides)!, times: level)
    }
}

// TODO: Is this a base class for Character? What about NPC? Monster? Should we have a protocol?
public class Player: Codable {
    
    public var name: String
    public var descriptiveTraits: [String: String] // ideals, bonds, flaws, background
    
    public private(set) var raceName: String
    public private(set) var className: String
    
    public var racialTraits: RacialTraits! {
        didSet {
            self.raceName = racialTraits.name
        }
    }
    public var classTraits: ClassTraits! {
        didSet {
            self.className = classTraits.name
        }
    }
    
    public enum Gender: String, Codable, CaseIterable {
        case female = "Female"
        case male = "Male"
    }
    
    /// Androgynous or hermaphroditic are represented as nil.
    public var gender: Gender?
    
    /// An "undecided" alignment is represented as nil.
    public var alignment: Alignment?

    public var height: Height
    public var weight: Weight

    // TODO: birthdate and age
    
    // TODO: hair, eyes, skin

    /// Ability scores
    
    public var baseAbilities: AbilityScores
    public var abilities: AbilityScores { return baseAbilities + racialTraits.abilityScoreIncrease }
    
    /// Hit points, hit dice, experience points, and level
    
    public var maximumHitPoints: Int
    public var currentHitPoints: Int
    public var experiencePoints: Int
    public var level: Int
    
    public var hitDice: Dice { return classTraits.hitDice.hitDice(level: level) }
    
    // Equipment and money
    
    public var money: Money
    public var armorClass: Int = 0 // TODO: compute armor class
    public var proficiencyBonus: Int { return 2 + level / 4 }
    
    // TODO: equipment, weapons, armor, skills, etc.
    
    private enum CodingKeys: String, CodingKey {
        case name
        case raceName = "race"
        case className = "class"
        case descriptiveTraits = "descriptive traits"
        case gender
        case alignment
        case height
        case weight
        case baseAbilities = "ability scores"
        case maximumHitPoints = "maximum hit points"
        case currentHitPoints = "current hit points"
        case experiencePoints = "experience points"
        case level
        case money
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        let name = try values.decode(String.self, forKey: .name)
        let raceName = try values.decode(String.self, forKey: .raceName)
        let className = try values.decode(String.self, forKey: .className)
        let descriptiveTraits = try values.decodeIfPresent([String:String].self, forKey: .descriptiveTraits)
        let gender = try values.decodeIfPresent(Gender.self, forKey: .gender)
        let alignment = try values.decodeIfPresent(Alignment.self, forKey: .alignment)
        let height = try values.decode(Height.self, forKey: .height)
        let weight = try values.decode(Weight.self, forKey: .weight)
        let baseAbilities = try values.decode(AbilityScores.self, forKey: .baseAbilities)
        let maximumHitPoints = try values.decode(Int.self, forKey: .maximumHitPoints)
        let currentHitPoints = try values.decodeIfPresent(Int.self, forKey: .currentHitPoints)
        let experiencePoints = try values.decodeIfPresent(Int.self, forKey: .experiencePoints)
        let level = try values.decodeIfPresent(Int.self, forKey: .level)
        let money = try values.decode(Money.self, forKey: .money)
        
        // Safely set properties
        self.name = name
        self.raceName = raceName
        self.className = className
        self.descriptiveTraits = descriptiveTraits ?? [:]
        self.gender = gender
        self.alignment = alignment
        self.height = height
        self.weight = weight
        self.baseAbilities = baseAbilities
        self.maximumHitPoints = maximumHitPoints
        self.currentHitPoints = currentHitPoints ?? maximumHitPoints
        self.experiencePoints = experiencePoints ?? 0
        self.level = level ?? 1
        self.money = money
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        try values.encode(name, forKey: .name)
        try values.encode(raceName, forKey: .raceName)
        try values.encode(className, forKey: .className)
        try values.encodeIfPresent(descriptiveTraits, forKey: .descriptiveTraits)
        try values.encodeIfPresent(gender, forKey: .gender)
        try values.encodeIfPresent(alignment, forKey: .alignment)
        try values.encode("\(height)", forKey: .height)
        try values.encode("\(weight)", forKey: .weight)
        try values.encode(baseAbilities, forKey: .baseAbilities)
        try values.encode(maximumHitPoints, forKey: .maximumHitPoints)
        try values.encodeIfPresent(currentHitPoints, forKey: .currentHitPoints)
        try values.encodeIfPresent(experiencePoints, forKey: .experiencePoints)
        try values.encodeIfPresent(level, forKey: .level)
        try values.encode("\(money)", forKey: .money)
    }
    
    // Creates a player character.
    public init(_ name: String, racialTraits: RacialTraits, classTraits: ClassTraits, gender: Gender? = nil, alignment: Alignment? = nil) {
        self.name = name
        self.descriptiveTraits = [:]
        self.raceName = racialTraits.name
        self.className = classTraits.name
        self.racialTraits = racialTraits
        self.classTraits = classTraits
        self.gender = gender
        self.alignment = alignment
        
        let extraHeight = racialTraits.heightModifier.roll().result
        self.height = (racialTraits.baseHeight + Height(value: Double(extraHeight), unit: .inches)).converted(to: .feet)
        
        let extraWeight = extraHeight * racialTraits.weightModifier.roll().result
        self.weight = racialTraits.baseWeight + Weight(value: Double(extraWeight), unit: .pounds)
        
        self.baseAbilities = AbilityScores()
        self.baseAbilities.roll()

        self.maximumHitPoints = Player.rollHitPoints(classTraits: classTraits, racialTraits: racialTraits)
        self.currentHitPoints = self.maximumHitPoints
        
        let startingWealth = classTraits.startingWealth.roll().result
        self.money = Money(value: Double(startingWealth), unit: .baseUnit())
        
        self.experiencePoints = 0
        self.level = 1
    }
    
    // MARK: Implementation
    
    class func rollHitPoints(classTraits: ClassTraits, racialTraits: RacialTraits) -> Int {
        return max(classTraits.hitDice.sides / 2 + 1, classTraits.hitDice.roll().result) + racialTraits.hitPointBonus
    }
    
    func rollHitPoints() -> Int {
        return Player.rollHitPoints(classTraits: classTraits, racialTraits: racialTraits)
    }

    public var canLevelUp: Bool {
        // TODO: min, max level
        return experiencePoints >= classTraits.experiencePoints![level]
    }

    public func levelUp() {
        guard canLevelUp else { return }
        
        level += 1
        
        maximumHitPoints += rollHitPoints()
        
        // TODO: add more for leveling up
    }

}
