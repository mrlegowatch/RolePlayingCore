//
//  RacialNames.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/8/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

public struct RacialNames: Codable {
    
    struct FamilyNames: Codable {
        let familyType: String
        let maleNames: [String]
        let femaleNames: [String]
        let familyNames: [String]?
        let childNames: [String]?
        let ethnicities: [String]?
        let nicknames: [String]?
        let aliases: [String]?
        
        private enum CodingKeys: String, CodingKey {
            case familyType = "family type"
            case maleNames = "Male"
            case femaleNames = "Female"
            case familyNames = "family"
            case childNames = "child"
            case ethnicities
            case nicknames
            case aliases
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let familyType: String
            let maleNames: [String]
            let femaleNames: [String]
            
            let aliases = try container.decodeIfPresent([String].self, forKey: .aliases)
            if aliases != nil {
                familyType = ""
                maleNames = []
                femaleNames = []
            } else {
                familyType = try container.decode(String.self, forKey: .familyType)
                maleNames = try container.decode([String].self, forKey: .maleNames)
                femaleNames = try container.decode([String].self, forKey: .femaleNames)
            }
            let familyNames = try container.decodeIfPresent([String].self, forKey: .familyNames)
            let childNames = try container.decodeIfPresent([String].self, forKey: .childNames)
            let ethnicities = try container.decodeIfPresent([String].self, forKey: .ethnicities)
            let nicknames = try container.decodeIfPresent([String].self, forKey: .nicknames)
            
            self.familyType = familyType
            self.maleNames = maleNames
            self.femaleNames = femaleNames
            self.familyNames = familyNames
            self.childNames = childNames
            self.ethnicities = ethnicities
            self.nicknames = nicknames
            self.aliases = aliases
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(familyType, forKey: .familyType)
            try container.encode(maleNames, forKey: .maleNames)
            try container.encode(femaleNames, forKey: .femaleNames)
            try container.encodeIfPresent(familyNames, forKey: .familyNames)
            try container.encodeIfPresent(childNames, forKey: .childNames)
            try container.encodeIfPresent(ethnicities, forKey: .ethnicities)
            try container.encodeIfPresent(nicknames, forKey: .nicknames)
            try container.encodeIfPresent(aliases, forKey: .aliases)
        }
    }
    
    internal let names: [String: FamilyNames]
    
    private func resolveRacialNames(_ racialTraits: RacialTraits) -> FamilyNames {
        guard names[racialTraits.name] == nil, let parentName = racialTraits.parentName else { return names[racialTraits.name]! }
        
        return names[parentName]!
    }
    
    private func resolveAliasNames<G: RandomIndexGenerator>(_ familyNames: FamilyNames, using generator: inout G) -> FamilyNames {
        guard let aliases = familyNames.aliases else { return familyNames }
        
        let randomIndex = generator.randomIndex(upperBound: aliases.count)
        let randomName = aliases[randomIndex]
        return names[randomName]!
    }
    
    private func resolveGender<G: RandomIndexGenerator>(_ gender: Player.Gender?, using generator: inout G) -> Player.Gender {
        guard gender == nil else { return gender! }
        let randomIndex = generator.randomIndex(upperBound: Player.Gender.allCases.count)
        return Player.Gender.allCases[randomIndex]
    }
    
    public func randomName<G: RandomIndexGenerator>(racialTraits: RacialTraits, gender: Player.Gender?, using generator: inout G) -> String {
        // Determine race or parent race (for subraces)
        var familyNames = resolveRacialNames(racialTraits)
        familyNames = resolveAliasNames(familyNames, using: &generator)
        
        let gender = resolveGender(gender, using: &generator)
        let genderNames = gender == .male ? familyNames.maleNames : familyNames.femaleNames
        let nameGenerator = NameGenerator(genderNames)
        return nameGenerator.makeName(using: &generator)
    }
    
    public func randomName(racialTraits: RacialTraits, gender: Player.Gender?) -> String {
        var rng = DefaultRandomIndexGenerator()
        return randomName(racialTraits: racialTraits, gender: gender, using: &rng)
    }
    
    // TODO: family names, child names, nicknames
}
