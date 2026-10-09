//
//  SpeciesTraits.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. Licensed under the MIT License.
//

import Foundation

/// Traits representing a species.
public struct SpeciesTraits: Named, Sendable {
    public var name: String
    public var plural: String
    public var aliases: [String]
    public var creatureType: CreatureType
    public var descriptiveTraits: [String: String]
    public var lifespan: Int

    public var baseSizes: [String]

    /// Darkvision range in feet. Nil means no darkvision.
    public var darkVision: Int?
    public var speed: Int

    public var description: String?
    public var parentName: String?
    public var subspecies: [SpeciesTraits] = []

    public init(name: String,
                plural: String,
                aliases: [String] = [],
                creatureType: CreatureType,
                descriptiveTraits: [String: String] = [:],
                lifespan: Int,
                baseSizes: [String] = ["4-7"],
                darkVision: Int? = nil,
                speed: Int,
                description: String? = nil) {
        self.name = name
        self.plural = plural
        self.aliases = aliases
        self.creatureType = creatureType
        self.descriptiveTraits = descriptiveTraits
        self.lifespan = lifespan
        self.baseSizes = baseSizes
        self.darkVision = darkVision
        self.speed = speed
        self.description = description
    }
}

extension SpeciesTraits: CodableWithConfiguration {

    private enum CodingKeys: String, CodingKey {
        case name
        case plural
        case aliases
        case creatureType = "creature type"
        case descriptiveTraits = "descriptive traits"
        case lifespan
        case baseSizes = "base sizes"
        case darkVision = "darkvision"
        case speed
        case description
        case subspecies
    }

    public init(from decoder: Decoder, configuration: GameData) throws {
        let speciesContainer = try decoder.container(keyedBy: CodingKeys.self)

        let name = try speciesContainer.decode(String.self, forKey: .name)
        let plural = try speciesContainer.decode(String.self, forKey: .plural)
        let aliases = try speciesContainer.decodeIfPresent([String].self, forKey: .aliases)
        let creatureType = try speciesContainer.decodeIfPresent(String.self, forKey: .creatureType)
        let descriptiveTraits = try speciesContainer.decodeIfPresent([String: String].self, forKey: .descriptiveTraits)
        let lifespan = try speciesContainer.decode(Int.self, forKey: .lifespan)
        let baseSizes = try speciesContainer.decodeIfPresent([String].self, forKey: .baseSizes)
        let darkVision = try speciesContainer.decodeIfPresent(Int.self, forKey: .darkVision)
        let speed = try speciesContainer.decode(Int.self, forKey: .speed)

        self.name = name
        self.plural = plural
        self.aliases = aliases ?? []
        if let creatureType {
            self.creatureType = CreatureType(creatureType)
        } else {
            self.creatureType = configuration.creatureTypes.defaultCreatureType
        }
        self.descriptiveTraits = descriptiveTraits ?? [:]
        self.lifespan = lifespan
        self.baseSizes = baseSizes ?? ["4-7"]
        self.darkVision = darkVision
        self.speed = speed
        self.description = try speciesContainer.decodeIfPresent(String.self, forKey: .description)

        // Decode subspecies, merging parent values for any field not specified.
        if var unkeyedContainer = try? speciesContainer.nestedUnkeyedContainer(forKey: .subspecies) {
            while !unkeyedContainer.isAtEnd {
                let subspeciesContainer = try unkeyedContainer.nestedContainer(keyedBy: CodingKeys.self)
                let subName = try subspeciesContainer.decode(String.self, forKey: .name)
                let subPlural = try subspeciesContainer.decode(String.self, forKey: .plural)
                let subAliases = try subspeciesContainer.decodeIfPresent([String].self, forKey: .aliases) ?? []
                let subDescriptiveTraits = try subspeciesContainer.decodeIfPresent([String: String].self, forKey: .descriptiveTraits) ?? [:]
                let subLifespan = try subspeciesContainer.decodeIfPresent(Int.self, forKey: .lifespan) ?? self.lifespan
                let subBaseSizes = try subspeciesContainer.decodeIfPresent([String].self, forKey: .baseSizes) ?? self.baseSizes
                let subDarkVision = try subspeciesContainer.decodeIfPresent(Int.self, forKey: .darkVision) ?? self.darkVision
                let subSpeed = try subspeciesContainer.decodeIfPresent(Int.self, forKey: .speed) ?? self.speed
                let subDescription = try subspeciesContainer.decodeIfPresent(String.self, forKey: .description)
                var subTraits = SpeciesTraits(
                    name: subName,
                    plural: subPlural,
                    aliases: subAliases,
                    creatureType: self.creatureType,
                    descriptiveTraits: subDescriptiveTraits,
                    lifespan: subLifespan,
                    baseSizes: subBaseSizes,
                    darkVision: subDarkVision,
                    speed: subSpeed,
                    description: subDescription
                )
                subTraits.parentName = self.name
                self.subspecies.append(subTraits)
            }
        }
    }

    public func encode(to encoder: Encoder, configuration: GameData) throws {
        var speciesContainer = encoder.container(keyedBy: CodingKeys.self)

        try speciesContainer.encode(name, forKey: .name)
        try speciesContainer.encode(plural, forKey: .plural)
        try speciesContainer.encode(aliases, forKey: .aliases)
        try speciesContainer.encode(creatureType.name, forKey: .creatureType)
        try speciesContainer.encode(descriptiveTraits, forKey: .descriptiveTraits)
        try speciesContainer.encode(lifespan, forKey: .lifespan)
        try speciesContainer.encode(baseSizes, forKey: .baseSizes)
        try speciesContainer.encodeIfPresent(darkVision, forKey: .darkVision)
        try speciesContainer.encode(speed, forKey: .speed)
        try speciesContainer.encodeIfPresent(description, forKey: .description)

        var subspeciesContainer = speciesContainer.nestedUnkeyedContainer(forKey: .subspecies)
        for subspeciesTraits in subspecies {
            try subspeciesTraits.encode(to: &subspeciesContainer, parent: self)
        }
    }

    public func encode(to container: inout UnkeyedEncodingContainer, parent: SpeciesTraits) throws {
        // Name, plural, aliases and descriptive traits are unique to each subspecies.
        // Numeric traits are only written when they differ from the parent.
        var subSpeciesContainer = container.nestedContainer(keyedBy: CodingKeys.self)

        try subSpeciesContainer.encode(name, forKey: .name)
        try subSpeciesContainer.encode(plural, forKey: .plural)
        try subSpeciesContainer.encode(creatureType.name, forKey: .creatureType)
        if !aliases.isEmpty {
            try subSpeciesContainer.encode(aliases, forKey: .aliases)
        }
        if !descriptiveTraits.isEmpty {
            try subSpeciesContainer.encode(descriptiveTraits, forKey: .descriptiveTraits)
        }
        if lifespan != parent.lifespan {
            try subSpeciesContainer.encode(lifespan, forKey: .lifespan)
        }
        if baseSizes != parent.baseSizes {
            try subSpeciesContainer.encode(baseSizes, forKey: .baseSizes)
        }
        if darkVision != parent.darkVision {
            try subSpeciesContainer.encodeIfPresent(darkVision, forKey: .darkVision)
        }
        if speed != parent.speed {
            try subSpeciesContainer.encode(speed, forKey: .speed)
        }
        try subSpeciesContainer.encodeIfPresent(description, forKey: .description)
    }
}
