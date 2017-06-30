//
//  Class.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

public struct ClassTraits {
    
    public var name: String
    public var plural: String
    public var descriptiveTraits: [String: String]
    public var hitDice: Dice
    public var primaryAbility: [Ability] 
    public var savingThrows: [Ability]
    public var experiencePoints: [Int]?
    public var startingWealth: Dice
    
    // TODO: weapons, armor, skills, etc.
    
}

extension ClassTraits: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case plural
        case descriptiveTraits = "descriptive traits"
        case hitDice = "hit dice"
        case primaryAbility = "primary ability"
        case savingThrows = "saving throws"
        case experiencePoints = "experience points"
        case startingWealth = "starting wealth"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        let name = try values.decode(String.self, forKey: .name)
        let plural = try values.decode(String.self, forKey: .plural)
        let descriptiveTraits = try values.decodeIfPresent([String:String].self, forKey: .descriptiveTraits)
        let hitDice = try values.decode(Dice.self, forKey: .hitDice)
        let primaryAbility = try values.decodeIfPresent([Ability].self, forKey: .primaryAbility)
        let savingThrows = try values.decodeIfPresent([Ability].self, forKey: .savingThrows)
        let experiencePoints = try values.decodeIfPresent([Int].self, forKey: .experiencePoints)
        let startingWealth = try values.decode(Dice.self, forKey: .startingWealth)
        
        // Safely set properties
        self.name = name
        self.plural = plural
        self.descriptiveTraits = descriptiveTraits ?? [:]
        self.hitDice = hitDice
        self.primaryAbility = primaryAbility ?? []
        self.savingThrows = savingThrows ?? []
        self.experiencePoints = experiencePoints
        self.startingWealth = startingWealth
    }
        
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        try values.encode(name, forKey: .name)
        try values.encode(plural, forKey: .plural)
        try values.encodeIfPresent(descriptiveTraits, forKey: .descriptiveTraits)
        try values.encode("\(hitDice)", forKey: .hitDice)
        try values.encodeIfPresent(primaryAbility, forKey: .primaryAbility)
        try values.encodeIfPresent(savingThrows, forKey: .savingThrows)
        try values.encodeIfPresent(experiencePoints, forKey: .experiencePoints)
        try values.encode("\(startingWealth)", forKey: .startingWealth)
    }
}
