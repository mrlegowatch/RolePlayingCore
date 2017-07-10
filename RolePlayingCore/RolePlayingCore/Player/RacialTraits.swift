//
//  RacialTraits.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

public struct RacialTraits {
    
    public var name: String
    public var plural: String
    public var aliases: [String]
    public var descriptiveTraits: [String: String]
    public var abilityScoreIncrease: AbilityScores
    public var minimumAge: Int!
    public var lifespan: Int!
    public var alignment: Alignment?
    public var baseHeight: Height!
    public var heightModifier: Dice
    public var baseWeight: Weight!
    public var weightModifier: Dice
    public var darkVision: Int!
    public var speed: Int!
    public var hitPointBonus: Int
    
    public var parentName: String?
    public var subraces: [RacialTraits] = []
    
    public enum Size {
        case small
        case medium
        case large
    }
    
    public var size: Size {
        let size: Size
        
        let heightInFeet = baseHeight.converted(to: .feet)
        switch heightInFeet.value {
        case 0..<4:
            size = .small
        case 4..<7:
            size = .medium
        default:
            size = .large
        }
        
        return size
    }
    
    public init(name: String,
                plural: String,
                aliases: [String] = [],
                descriptiveTraits: [String: String] = [:],
                abilityScoreIncrease: AbilityScores = AbilityScores(),
                minimumAge: Int,
                lifespan: Int,
                alignment: Alignment? = nil,
                baseHeight: Height,
                heightModifier: Dice = DiceModifier(0),
                baseWeight: Weight,
                weightModifier: Dice = DiceModifier(0),
                darkVision: Int,
                speed: Int,
                hitPointBonus: Int = 0) {
        self.name = name
        self.plural = plural
        self.aliases = aliases
        self.descriptiveTraits = descriptiveTraits
        self.abilityScoreIncrease = abilityScoreIncrease
        self.minimumAge = minimumAge
        self.lifespan = lifespan
        self.alignment = alignment
        self.baseHeight = baseHeight
        self.heightModifier = heightModifier
        self.baseWeight = baseWeight
        self.weightModifier = weightModifier
        self.darkVision = darkVision
        self.speed = speed
        self.hitPointBonus = hitPointBonus
    }
}

extension RacialTraits: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case plural
        case aliases
        case descriptiveTraits = "descriptive traits"
        case abilityScoreIncrease = "ability scores"
        case minimumAge = "minimum age"
        case lifespan
        case alignment
        case baseHeight = "base height"
        case heightModifier = "height modifier"
        case baseWeight = "base weight"
        case weightModifier = "weight modifier"
        case darkVision = "darkvision"
        case speed
        case hitPointBonus = "hit point bonus"
        case subraces
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        let name = try values.decode(String.self, forKey: .name)
        let plural = try values.decode(String.self, forKey: .plural)
        let aliases = try values.decodeIfPresent([String].self, forKey: .aliases)
        let descriptiveTraits = try values.decodeIfPresent([String:String].self, forKey: .descriptiveTraits)
        let abilityScoreIncrease = try values.decodeIfPresent(AbilityScores.self, forKey: .abilityScoreIncrease)
        let minimumAge = try values.decodeIfPresent(Int.self, forKey: .minimumAge)
        let lifespan = try values.decodeIfPresent(Int.self, forKey: .lifespan)
        let alignment = try values.decodeIfPresent(Alignment.self, forKey: .alignment)
        let baseHeight = try values.decodeIfPresent(Height.self, forKey: .baseHeight)
        let heightModifier = try values.decodeIfPresent(Dice.self, forKey: .heightModifier)
        let baseWeight = try values.decodeIfPresent(Weight.self, forKey: .baseWeight)
        let weightModifier = try values.decodeIfPresent(Dice.self, forKey: .weightModifier)
        let darkVision = try values.decodeIfPresent(Int.self, forKey: .darkVision)
        let speed = try values.decodeIfPresent(Int.self, forKey: .speed)
        let hitPointBonus = try values.decodeIfPresent(Int.self, forKey: .hitPointBonus)
        
        // Safely set properties
        self.name = name
        self.plural = plural
        self.aliases = aliases ?? []
        self.descriptiveTraits = descriptiveTraits ?? [:]
        self.abilityScoreIncrease = abilityScoreIncrease ?? AbilityScores()
        self.minimumAge = minimumAge
        self.lifespan = lifespan
        self.alignment = alignment
        self.baseHeight = baseHeight
        self.heightModifier = heightModifier ?? DiceModifier(0)
        self.baseWeight = baseWeight
        self.weightModifier = weightModifier ?? DiceModifier(0)
        self.darkVision = darkVision
        self.speed = speed
        self.hitPointBonus = hitPointBonus ?? 0
        
        // Decode subraces
        if var subraces = try? values.nestedUnkeyedContainer(forKey: .subraces) {
            while (!subraces.isAtEnd) {
                var subracialTraits = try subraces.decode(RacialTraits.self)
                subracialTraits.blendTraits(from: self)
                self.subraces.append(subracialTraits)
            }
        }
        
    }
    
    /// Inherit parent traits, for each trait that is not already set.
    public mutating func blendTraits(from parent: RacialTraits) {
        // Name, plural, aliases and descriptive traits are unique to each set of racial traits.
        // The rest may be inherited from the parent.
        self.parentName = parent.name
        
        // Combine ability scores together
        self.abilityScoreIncrease += parent.abilityScoreIncrease
        
        if self.minimumAge == nil {
            self.minimumAge = parent.minimumAge
        }
        if self.lifespan == nil {
            self.lifespan = parent.lifespan
        }
        if self.alignment == nil {
            self.alignment = parent.alignment
        }
        if self.baseHeight == nil {
            self.baseHeight = parent.baseHeight
        }
        if self.heightModifier.sides == 0 {
            self.heightModifier = parent.heightModifier
        }
        if self.baseWeight == nil {
            self.baseWeight = parent.baseWeight
        }
        if self.weightModifier.sides == 0 {
            self.weightModifier = parent.weightModifier
        }
        if self.darkVision == nil {
            self.darkVision = parent.darkVision
        }
        if self.speed == nil {
            self.speed = parent.speed
        }
        if self.hitPointBonus == 0 {
            self.hitPointBonus = parent.hitPointBonus
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        try values.encode(name, forKey: .name)
        try values.encode(plural, forKey: .plural)
        try values.encode(aliases, forKey: .aliases)
        try values.encode(descriptiveTraits, forKey: .descriptiveTraits)
        try values.encode(abilityScoreIncrease, forKey: .abilityScoreIncrease)
        try values.encode(minimumAge, forKey: .minimumAge)
        try values.encode(lifespan, forKey: .lifespan)
        
        // Encode alignment using its enum string values, since RacialTraits is a type.
        if alignment != nil {
            try values.encode("\(alignment!)", forKey: .alignment)
        }
        
        try values.encode("\(baseHeight!)", forKey: .baseHeight)
        try values.encode("\(heightModifier)", forKey: .heightModifier)
        try values.encode("\(baseWeight!)", forKey: .baseWeight)
        try values.encode("\(weightModifier)", forKey: .weightModifier)
        try values.encode(darkVision, forKey: .darkVision)
        try values.encode(speed, forKey: .speed)
        try values.encode(hitPointBonus, forKey: .hitPointBonus)
        
        var subraceContainer = values.nestedUnkeyedContainer(forKey: .subraces)
        for subrace in subraces {
            try subrace.encode(to: &subraceContainer, parent: self)
        }
    }
    
    public func encode(to container: inout UnkeyedEncodingContainer, parent: RacialTraits) throws {
        // Name, plural, aliases and descriptive traits are unique to each set of racial traits.
        // The rest may be inherited from the parent.
        var values = container.nestedContainer(keyedBy: CodingKeys.self)
        
        try values.encode(name, forKey: .name)
        try values.encode(plural, forKey: .plural)
        if self.aliases.count > 0 {
            try values.encode(aliases, forKey: .aliases)
        }
        if self.descriptiveTraits.count > 0 {
            try values.encode(descriptiveTraits, forKey: .descriptiveTraits)
        }
        
        // Un-combine ability scores
        if self.abilityScoreIncrease != parent.abilityScoreIncrease {
            let delta = self.abilityScoreIncrease - parent.abilityScoreIncrease
            try values.encode(delta, forKey: .abilityScoreIncrease)
        }
        
        if self.minimumAge != parent.minimumAge {
            try values.encode(self.minimumAge, forKey: .minimumAge)
        }
        if self.lifespan != parent.lifespan {
            try values.encode(self.lifespan, forKey: .lifespan)
        }
        if self.alignment != nil && self.alignment != parent.alignment {
            try values.encode("\(alignment!)", forKey: .alignment)
        }
        if self.baseHeight != parent.baseHeight {
            try values.encode("\(self.baseHeight!)", forKey: .baseHeight)
        }
        if self.heightModifier.sides != parent.heightModifier.sides {
            try values.encode("\(self.heightModifier)", forKey: .heightModifier)
        }
        if self.baseWeight != parent.baseWeight {
            try values.encode("\(self.baseWeight!)", forKey: .baseWeight)
        }
        if self.weightModifier.sides != parent.weightModifier.sides {
            try values.encode("\(self.weightModifier)", forKey: .weightModifier)
        }
        if self.darkVision != parent.darkVision {
            try values.encode(self.darkVision, forKey: .darkVision)
        }
        if self.speed != parent.speed {
            try values.encode(self.speed, forKey: .speed)
        }
        if self.hitPointBonus != parent.hitPointBonus {
            try values.encode(self.hitPointBonus, forKey: .hitPointBonus)
        }
    }
    
}
