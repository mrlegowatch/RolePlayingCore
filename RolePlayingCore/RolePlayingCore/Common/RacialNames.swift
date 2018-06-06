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
    
    let names: [String: FamilyNames]
    
    func resolveRacialNames(_ racialTraits: RacialTraits) -> FamilyNames {
        guard names[racialTraits.name] == nil, let parentName = racialTraits.parentName else { return names[racialTraits.name]! }
        
        return names[parentName]!
    }
    
    func resolveAliasNames(_ familyNames: FamilyNames) -> FamilyNames {
        guard let aliases = familyNames.aliases else { return familyNames }
        
        let randomName = aliases.randomElement()!
        return names[randomName]!
    }
    
    func resolveGender(_ gender: Player.Gender?) -> Player.Gender {
        guard gender == nil else { return gender! }
        return Player.Gender.allCases.randomElement()!
    }
    
    public func randomName(racialTraits: RacialTraits, gender: Player.Gender?) -> String {
        // Determine race or parent race (for subraces)
        var familyNames = resolveRacialNames(racialTraits)
        familyNames = resolveAliasNames(familyNames)
        
        let gender = resolveGender(gender)
        let genderNames = gender == .male ? familyNames.maleNames : familyNames.femaleNames
        let nameGenerator = NameGenerator(genderNames)
        return nameGenerator.makeName()
    }
    
    // TODO: family names, child names, nicknames
}
