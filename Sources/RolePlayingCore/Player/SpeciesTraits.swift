//
//  SpeciesTraits.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

/// Traits representing a species.
public struct SpeciesTraits {
    
    public var name: String
    public var plural: String
    public var aliases: [String]
    public var creatureType: CreatureType
    public var descriptiveTraits: [String: String]
    public var lifespan: Int!
    
    public var baseSizes: [String]
    
    public var darkVision: Int!
    public var speed: Int!
    
    public var parentName: String?
    public var subspecies: [SpeciesTraits] = []
    
    public init(name: String,
                plural: String,
                aliases: [String] = [],
                creatureType: CreatureType,
                descriptiveTraits: [String: String] = [:],
                lifespan: Int,
                baseSizes: [String] = ["4-7"],
                darkVision: Int,
                speed: Int) {
        self.name = name
        self.plural = plural
        self.aliases = aliases
        self.creatureType = creatureType
        self.descriptiveTraits = descriptiveTraits
        self.lifespan = lifespan
        self.baseSizes = baseSizes
        self.darkVision = darkVision
        self.speed = speed
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
        case subspecies
    }
    
    public init(from decoder: Decoder, configuration: Configuration) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try decoding properties
        let name = try values.decode(String.self, forKey: .name)
        let plural = try values.decode(String.self, forKey: .plural)
        let aliases = try values.decodeIfPresent([String].self, forKey: .aliases)
        let creatureType = try values.decodeIfPresent(String.self, forKey: .creatureType)
        let descriptiveTraits = try values.decodeIfPresent([String:String].self, forKey: .descriptiveTraits)
        let lifespan = try values.decodeIfPresent(Int.self, forKey: .lifespan)
        let baseSizes = try values.decodeIfPresent([String].self, forKey: .baseSizes)
        let darkVision = try values.decodeIfPresent(Int.self, forKey: .darkVision)
        let speed = try values.decodeIfPresent(Int.self, forKey: .speed)
        
        // Safely set properties
        self.name = name
        self.plural = plural
        self.aliases = aliases ?? []
        self.creatureType = creatureType != nil ? CreatureType(creatureType!) : configuration.species.defaultCreatureType
        self.descriptiveTraits = descriptiveTraits ?? [:]
        self.lifespan = lifespan
        self.baseSizes = baseSizes ?? ["4-7"]
        self.darkVision = darkVision
        self.speed = speed
        
        // Decode subspecies
        if var subspecies = try? values.nestedUnkeyedContainer(forKey: .subspecies) {
            while (!subspecies.isAtEnd) {
                var subspeciesTraits = try subspecies.decode(SpeciesTraits.self, configuration: configuration)
                subspeciesTraits.blendTraits(from: self)
                self.subspecies.append(subspeciesTraits)
            }
        }
    }
    
    /// Inherit parent traits, for each trait that is not already set.
    public mutating func blendTraits(from parent: SpeciesTraits) {
        // Name, plural, aliases and descriptive traits are unique to each set of species traits.
        // The rest may be inherited from the parent.
        self.parentName = parent.name
        self.creatureType = parent.creatureType
        
        if self.baseSizes.isEmpty {
            self.baseSizes = parent.baseSizes
        }
        
        if self.lifespan == nil {
            self.lifespan = parent.lifespan
        }
        
        if self.darkVision == nil {
            self.darkVision = parent.darkVision
        }
        if self.speed == nil {
            self.speed = parent.speed
        }
    }
    
    public func encode(to encoder: Encoder, configuration: Configuration) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        try values.encode(name, forKey: .name)
        try values.encode(plural, forKey: .plural)
        try values.encode(aliases, forKey: .aliases)
        try values.encode(creatureType.name, forKey: .creatureType)
        try values.encode(descriptiveTraits, forKey: .descriptiveTraits)
        try values.encode(lifespan, forKey: .lifespan)
        try values.encode(baseSizes, forKey: .baseSizes)
        try values.encode(darkVision, forKey: .darkVision)
        try values.encode(speed, forKey: .speed)
        
        var subspeciesContainer = values.nestedUnkeyedContainer(forKey: .subspecies)
        for subspeciesTraits in subspecies {
            try subspeciesTraits.encode(to: &subspeciesContainer, parent: self)
        }
    }
    
    public func encode(to container: inout UnkeyedEncodingContainer, parent: SpeciesTraits) throws {
        // Name, plural, aliases and descriptive traits are unique to each set of species traits.
        // The rest may be inherited from the parent.
        var values = container.nestedContainer(keyedBy: CodingKeys.self)
        
        try values.encode(name, forKey: .name)
        try values.encode(plural, forKey: .plural)
        try values.encode(creatureType.name, forKey: .creatureType)
        if self.aliases.count > 0 {
            try values.encode(aliases, forKey: .aliases)
        }
        if self.descriptiveTraits.count > 0 {
            try values.encode(descriptiveTraits, forKey: .descriptiveTraits)
        }
        if self.lifespan != parent.lifespan {
            try values.encode(self.lifespan, forKey: .lifespan)
        }
        if self.baseSizes != parent.baseSizes {
            try values.encode(self.baseSizes, forKey: .baseSizes)
        }
        if self.darkVision != parent.darkVision {
            try values.encode(self.darkVision, forKey: .darkVision)
        }
        if self.speed != parent.speed {
            try values.encode(self.speed, forKey: .speed)
        }
    }
}
