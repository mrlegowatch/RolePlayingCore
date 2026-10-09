//
//  Spell.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 8/9/26.
//  Copyright © 2026 Brian Arnold. Licensed under the MIT License.
//

/// A spell a character can learn, prepare, or cast.
public struct Spell: Sendable, Equatable, Hashable {
    public var name: String

    /// Spell level, where 0 indicates a cantrip.
    public var level: Int

    /// School of magic (e.g., "evocation", "conjuration").
    public var school: String

    /// Verbal, somatic, and/or material components (e.g., ["V", "S", "M"]).
    public var components: [String]

    /// How long the spell takes to cast (e.g., "1 action", "1 bonus action").
    public var castingTime: String

    public var description: String

    public init(
        name: String,
        level: Int = 0,
        school: String = "",
        components: [String] = [],
        castingTime: String = "",
        description: String = ""
    ) {
        self.name = name
        self.level = level
        self.school = school
        self.components = components
        self.castingTime = castingTime
        self.description = description
    }
}

extension Spell: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case level
        case school
        case components
        case description
        case castingTime = "casting time"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 0
        let school = try container.decodeIfPresent(String.self, forKey: .school) ?? ""
        let components = try container.decodeIfPresent([String].self, forKey: .components) ?? []
        let castingTime = try container.decodeIfPresent(String.self, forKey: .castingTime) ?? ""
        let description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.init(name: name, level: level, school: school,
                  components: components, castingTime: castingTime, description: description)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(level, forKey: .level)
        if !school.isEmpty {
            try container.encode(school, forKey: .school)
        }
        if !components.isEmpty {
            try container.encode(components, forKey: .components)
        }
        if !castingTime.isEmpty {
            try container.encode(castingTime, forKey: .castingTime)
        }
        if !description.isEmpty {
            try container.encode(description, forKey: .description)
        }
    }
}
