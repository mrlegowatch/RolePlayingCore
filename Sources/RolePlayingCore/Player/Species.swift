//
//  Species.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

/// A collection of species traits, including subspecies.
public class Species: CodableWithConfiguration {
    
    /// Accesses all of the species and subspecies that have been loaded.
    public var species = [SpeciesTraits]()
    
    public var creatureTypes = [CreatureType]()
    
    public var defaultCreatureType: CreatureType {
        creatureTypes.first(where: { $0.isDefault != nil && $0.isDefault! }) ?? CreatureType("Humanoid")
    }
    
    /// Creates a Species instance.
    public init() { }
    
    /// Returns all of the leaf species (species that contain no subspecies).
    public var leafSpecies: [SpeciesTraits] {
        return species.filter { $0.subspecies.isEmpty }
    }
    
    /// Returns the species matching the specified name, or nil if not present.
    public func find(_ speciesName: String) -> SpeciesTraits? {
        return species.first(where: { $0.name == speciesName })
    }

    public var count: Int { species.count }
    
    public subscript(index: Int) -> SpeciesTraits? {
        guard index >= 0 && index < species.count else { return nil }
        return species[index]
    }
    
    public func randomElementByIndex<G: RandomIndexGenerator>(using generator: inout G) -> SpeciesTraits {
        return species.randomElementByIndex(using: &generator)!
    }
    
    enum CodingKeys: String, CodingKey {
        case species
        case creatureTypes = "creature types"
    }
    
    /// Overridden to stitch together subspecies embedded in species.
    public required init(from decoder: Decoder, configuration: Configuration) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let creatureTypes = try root.decodeIfPresent([CreatureType].self, forKey: .creatureTypes)
        self.creatureTypes = creatureTypes ?? []
        
        var leaf = try root.nestedUnkeyedContainer(forKey: .species)
        
        var species = [SpeciesTraits]()
        while (!leaf.isAtEnd) {
            let speciesTraits = try leaf.decode(SpeciesTraits.self, configuration: configuration)
            species.append(speciesTraits)
            
            /// If there are subspecies, append those
            for subspeciesTraits in speciesTraits.subspecies {
                species.append(subspeciesTraits)
            }
        }
        
        self.species = species
    }
    
    public func encode(to encoder: any Encoder, configuration: Configuration) throws {
        var root = encoder.container(keyedBy: CodingKeys.self)
        if !creatureTypes.isEmpty {
            try root.encode(creatureTypes, forKey: .creatureTypes)
        }
        
        var leaf = root.nestedUnkeyedContainer(forKey: .species)
        let rootSpecies = self.species.filter { $0.parentName == nil }
        for speciesTraits in rootSpecies {
            try leaf.encode(speciesTraits, configuration: configuration)
        }
    }
}
