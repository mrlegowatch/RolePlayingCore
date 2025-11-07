//
//  BackgroundTraits.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/26/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

/// Traits associated with a player character's background.
public struct BackgroundTraits {
    public var name: String
    public var abilityScores: [String]
    public var feat: String
    public var skillProficiencies: [String]
    public var toolProficiency: String
    public var equipment: [[String]]
}

extension BackgroundTraits: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case abilityScores = "ability scores"
        case feat
        case skillProficiencies = "skill proficiencies"
        case toolProficiency = "tool proficiency"
        case equipment = "equipment"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.abilityScores = try values.decode([String].self, forKey: .abilityScores)
        self.feat = try values.decode(String.self, forKey: .feat)
        self.skillProficiencies = try values.decode([String].self, forKey: .skillProficiencies)
        self.toolProficiency = try values.decode(String.self, forKey: .toolProficiency)
        self.equipment = try values.decode([[String]].self, forKey: .equipment)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(abilityScores, forKey: .abilityScores)
        try container.encode(feat, forKey: .feat)
        try container.encode(skillProficiencies, forKey: .skillProficiencies)
        try container.encode(toolProficiency, forKey: .toolProficiency)
        try container.encode(equipment, forKey: .equipment)
    }
}
