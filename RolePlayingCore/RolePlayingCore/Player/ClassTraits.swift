//
//  Class.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

public extension Trait {
        
    public static let primaryAbility = "primary ability"
    
    public static let savingThrows = "saving throws"
    
    public static let startingWealth = "starting wealth"
    
    public static let experiencePoints = "experience points"
    
}

// TODO: Support TraitCoder protocol
public struct ClassTraits {
    
    public var name: String

    public var plural: String

    public var descriptiveTraits = [String: Any]()
    
    // Hit points
    
    public var hitDice: Dice
    
    // Abilities
    
    public var primaryAbility: [Ability]
    
    // Proficiencies
    
    public var savingThrows: [Ability]
    
    public var experiencePoints: [Int]?
    
    // TODO: weapons, armor, skills, etc.
    
    public var startingWealth: Dice
    
    public init?(from traits: Any?) {
        guard let traits = traits as? [String: Any] else { return nil }

        // Required traits
        guard let name = traits[Trait.name] as? String else { Trait.logMissing(Trait.name); return nil }
        guard let plural = traits[Trait.plural] as? String else { Trait.logMissing(Trait.plural); return nil }
        guard let hitDiceString = traits[Trait.hitDice] as? String, let hitDice = dice(from: hitDiceString) else { Trait.logMissing(Trait.hitDice); return nil }
        
        guard let primaryAbilityArray = traits[Trait.primaryAbility] as? [String] else { Trait.logMissing(Trait.primaryAbility); return nil }
        let primaryAbility = primaryAbilityArray.map({ Ability($0) })
        
        guard let savingThrowsArray = traits[Trait.savingThrows] as? [String] else { Trait.logMissing(Trait.savingThrows); return nil }
        let savingThrows = savingThrowsArray.map({ Ability($0) })
        
        guard let startingWealthString = traits[Trait.startingWealth] as? String, let startingWealth = dice(from: startingWealthString) else { Trait.logMissing(Trait.startingWealth); return nil }
        
        // Optional traits:
        
        // Note: experiencePoints may defined be for all classes, and
        // will be set after all classes have been created.
        let experiencePoints = traits[Trait.experiencePoints] as? [Int]
        
        // TODO: weapons, armor, skills, etc.
        
        // All is well, set the values:
        self.name = name
        self.plural = plural
        self.hitDice = hitDice
        
        self.primaryAbility = primaryAbility
        self.savingThrows = savingThrows
        
        self.experiencePoints = experiencePoints
        self.startingWealth = startingWealth
    }
}
