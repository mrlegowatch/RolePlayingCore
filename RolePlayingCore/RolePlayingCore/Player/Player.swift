//
//  Player.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/11/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

public extension Trait {
    
    public static let gender = "gender"
    
    public static let height = "height"
    
    public static let weight = "weight"
    
    public static let money = "money"
    
    public static let level = "level"
    
    // Personality traits
    
    public static let ideals = "ideals"
    
    public static let bonds = "bonds"
    
    public static let flaws = "flaws"
    
    public static let background = "background"
    
}

public extension Ability.Scores {
    
    // Sets the ability scores to random values using 4d6-L
    public mutating func roll() {
        let dice = DroppingDice(.d6, times: 4, drop: .lowest)
        for ability in abilities {
            rawValue[ability] = dice.roll()
        }
    }

}

// TODO: Is this a base class for Character? What about NPC? Monster? Should we have a protocol?
// TODO: Support TraitCoder protocol
public class Player {
    
    public var name: String
    
    public var descriptiveTraits = [String: Any]()
    
    public var description: String? { return descriptiveTraits[Trait.description] as? String }
    
    public var racialTraits: RacialTraits!
    
    public var raceName: String { return racialTraits.name }
    
    public var classTraits: ClassTraits!
    
    public var className: String { return classTraits.name }
    
    public enum Gender: String {
        case female = "female"
        case male = "male"
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
    
    public var baseAbilities: Ability.Scores
    
    public var abilityModifiers: Ability.Scores { return racialTraits.abilityScoreIncrease }
    
    public var abilities: Ability.Scores { return baseAbilities + abilityModifiers }
    
    /// Hit points, hit dice, experience points, and level
    
    public var maximumHitPoints: Int
    
    public var currentHitPoints: Int
    
    public var hitDice: Dice {
        return classTraits.hitDice
    }
    
    public var experiencePoints: Int
    
    public var level: Int
    
    
    // Equipment and money
    
    public var money: Money
    
    public var armorClass: Int = 0 // TODO: compute armor class
    
    public var proficiencyBonus: Int {
        return 2 + level / 4
    }
    
    // TODO: equipment, weapons, armor, skills, etc.
    
    // Creates a player character.
    public init(_ name: String, racialTraits: RacialTraits, classTraits: ClassTraits, gender: Gender? = nil, alignment: Alignment? = nil) {
        self.name = name
        
        self.racialTraits = racialTraits
        self.classTraits = classTraits
        

        self.gender = gender
        self.alignment = alignment
        
        let extraHeight = racialTraits.heightModifier.roll()
        self.height = (racialTraits.baseHeight + Height(value: Double(extraHeight), unit: .inches)).converted(to: .feet)
        
        let extraWeight = extraHeight * racialTraits.weightModifier.roll()
        self.weight = racialTraits.baseWeight + Weight(value: Double(extraWeight), unit: .pounds)
        
        self.baseAbilities = Ability.Scores()
        self.baseAbilities.roll()

        self.maximumHitPoints = Player.rollHitPoints(classTraits: classTraits, racialTraits: racialTraits)
        self.currentHitPoints = self.maximumHitPoints
        
        let startingWealth = classTraits.startingWealth.roll()
        self.money = Money(value: Double(startingWealth), unit: .baseUnit())
        
        self.experiencePoints = 0
        self.level = 1
    }
    
    public required init?(from traits: Any?) {
        guard let traits = traits as? [String: Any] else { return nil }

        // Required traits
        guard let name = traits[Trait.name] as? String else { return nil }
        
        guard let height = Height(from: traits[Trait.height]) else { Trait.logMissing(Trait.height); return nil }
        guard let weight = Weight(from: traits[Trait.weight]) else { Trait.logMissing(Trait.weight); return nil }
        
        guard let baseAbilities = Ability.Scores(from: traits[Trait.abilityScores]) else { Trait.logMissing(Trait.abilityScores); return nil }

        guard let money = Money(from: traits[Trait.money]) else { Trait.logMissing(Trait.money); return nil }
        
        guard let maximumHitPoints = traits[Trait.hitPoints] as? Int else { Trait.logMissing(Trait.hitPoints); return nil }
        
        // Optional traits
        let gender: Gender?
        if let genderString = traits[Trait.gender] as? String {
            gender = Gender(rawValue: genderString)
        } else {
            gender = nil
        }
        
        let alignment: Alignment?
        if let alignmentString = traits[Trait.alignment] as? String {
            alignment = Alignment(from: alignmentString)
        } else {
            alignment = nil
        }
        
        let experiencePoints = traits[Trait.experiencePoints] as? Int ?? 0
        let level = traits[Trait.level] as? Int ?? 1
        
        // All is well, set the properties:
        self.name = name
        self.gender = gender
        self.alignment = alignment
        self.height = height
        self.weight = weight
        self.baseAbilities = baseAbilities
        self.money = money
        self.maximumHitPoints = maximumHitPoints
        self.currentHitPoints = maximumHitPoints
        self.experiencePoints = experiencePoints
        self.level = level
    }
    
    class func rollHitPoints(classTraits: ClassTraits, racialTraits: RacialTraits) -> Int {
        return max(classTraits.hitDice.sides / 2 + 1, classTraits.hitDice.roll()) + racialTraits.hitPointsBonus
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
        
        // TODO: add more level up
    }

}
