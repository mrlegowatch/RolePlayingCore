//
//  BackgroundTraits.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/26/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import Foundation

/// Traits associated with a player character's background.
public struct BackgroundTraits: Named, Sendable {
    public var name: String
    public var abilityScores: [Ability]
    public var feat: FeatTraits
    public var skillProficiencies: [Skill]
    public var toolProficiency: String
    public var equipment: EquipmentOptions
}

extension BackgroundTraits: CodableWithConfiguration {
    private enum CodingKeys: String, CodingKey {
        case name
        case abilityScores = "ability scores"
        case feat
        case skillProficiencies = "skill proficiencies"
        case toolProficiency = "tool proficiency"
        case equipment = "equipment"
    }
    
    public init(from decoder: Decoder, configuration: GameData) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.abilityScores = try values.decode([Ability].self, forKey: .abilityScores)
        let featName = try values.decode(String.self, forKey: .feat)
        guard let feat = configuration.feats[featName] else {
            throw missingTypeError("feat", featName)
        }
        self.feat = feat

        // Decode skill proficiency names and resolve them using configuration
        let skillNames = try values.decode([String].self, forKey: .skillProficiencies)
        self.skillProficiencies = try skillNames.skills(from: configuration.skills)
        
        self.toolProficiency = try values.decode(String.self, forKey: .toolProficiency)
        self.equipment = try values.decode(EquipmentOptions.self, forKey: .equipment, configuration: configuration)
    }
    
    public func encode(to encoder: Encoder, configuration: GameData) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(abilityScores, forKey: .abilityScores)
        try container.encode(feat.name, forKey: .feat)
        try container.encode(skillProficiencies.skillNames, forKey: .skillProficiencies)
        try container.encode(toolProficiency, forKey: .toolProficiency)
        try container.encode(equipment, forKey: .equipment, configuration: configuration)
    }
}
