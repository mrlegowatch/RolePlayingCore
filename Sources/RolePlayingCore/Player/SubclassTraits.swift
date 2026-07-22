//
//  SubclassTraits.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/22/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// Traits describing a subclass (archetype, domain, patron, etc.) that a character
/// selects at the level specified by their parent class.
///
/// Features and additional spells are keyed by character level (e.g., 3, 7, 11, 15).
public struct SubclassTraits: Sendable, Equatable {
    public var name: String
    public var descriptiveTraits: [String: String]

    /// Named features granted at each level. Keys are character levels; values list
    /// the feature names granted at that level.
    public var features: [Int: [String]]

    /// Bonus spells granted at specific levels, such as cleric domain spells or warlock
    /// expanded spell lists. Keys are character levels.
    public var additionalSpells: [Int: [String]]?

    public init(
        name: String,
        descriptiveTraits: [String: String] = [:],
        features: [Int: [String]] = [:],
        additionalSpells: [Int: [String]]? = nil
    ) {
        self.name = name
        self.descriptiveTraits = descriptiveTraits
        self.features = features
        self.additionalSpells = additionalSpells
    }
}

extension SubclassTraits: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case descriptiveTraits = "descriptive traits"
        case features
        case additionalSpells = "additional spells"
    }

    /// Decodes features and spells from string-keyed JSON objects (e.g., `"3": [...]`)
    /// and converts the string level keys to Int.
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.descriptiveTraits = try values.decodeIfPresent([String: String].self, forKey: .descriptiveTraits) ?? [:]

        let featureStrings = try values.decodeIfPresent([String: [String]].self, forKey: .features) ?? [:]
        self.features = Dictionary(uniqueKeysWithValues: featureStrings.compactMap { key, value in
            Int(key).map { ($0, value) }
        })

        if let spellStrings = try values.decodeIfPresent([String: [String]].self, forKey: .additionalSpells) {
            self.additionalSpells = Dictionary(uniqueKeysWithValues: spellStrings.compactMap { key, value in
                Int(key).map { ($0, value) }
            })
        } else {
            self.additionalSpells = nil
        }
    }

    /// Encodes features and spells with string level keys for JSON compatibility.
    public func encode(to encoder: any Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(name, forKey: .name)
        if !descriptiveTraits.isEmpty {
            try values.encode(descriptiveTraits, forKey: .descriptiveTraits)
        }
        if !features.isEmpty {
            let featureStrings = Dictionary(uniqueKeysWithValues: features.map { ("\($0.key)", $0.value) })
            try values.encode(featureStrings, forKey: .features)
        }
        if let additionalSpells {
            let spellStrings = Dictionary(uniqueKeysWithValues: additionalSpells.map { ("\($0.key)", $0.value) })
            try values.encode(spellStrings, forKey: .additionalSpells)
        }
    }
}
