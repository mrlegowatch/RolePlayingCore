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
    
    /// All of the species and subspecies traits as a flattened dictionary, indexed by species name.
    private var allSpecies: [String: SpeciesTraits] = [:]
    
    /// Accesses all of the species and subspecies that have been loaded.
    public var all: [SpeciesTraits] { Array(allSpecies.values) }
    
    /// Creates a Species instance.
    public init(_ species: [SpeciesTraits] = []) {
        add(species)
    }
    
    public func add(_ species: [SpeciesTraits]) {
        let mappedSpecies = Dictionary(species.map { ($0.name, $0) }, uniquingKeysWith: { _, last in last })
        allSpecies.merge(mappedSpecies, uniquingKeysWith: { _, last in last })
    }
    
    public func add(_ species: Species) {
        add(species.all)
    }
    
    /// Returns all of the leaf species (species that contain no subspecies).
    public var leafSpecies: [SpeciesTraits] {
        return all.filter { $0.subspecies.isEmpty }
    }
    
    /// Returns the species matching the specified name, or nil if not present.
    public subscript(speciesName: String) -> SpeciesTraits? {
        return allSpecies[speciesName]
    }

    public var count: Int { allSpecies.count }
    
    public subscript(index: Int) -> SpeciesTraits? {
        guard index >= 0 && index < count else { return nil }
        return all[index]
    }
    
    public func randomElementByIndex<G: RandomIndexGenerator>(using generator: inout G) -> SpeciesTraits {
        return all.randomElementByIndex(using: &generator)!
    }
    
    // MARK: CodableWithConfiguration support
    
    enum CodingKeys: String, CodingKey {
        case species
    }
    
    /// Overridden to stitch together subspecies embedded in species.
    public required init(from decoder: Decoder, configuration: Configuration) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        
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
        
        add(species)
    }
    
    public func encode(to encoder: any Encoder, configuration: Configuration) throws {
        var root = encoder.container(keyedBy: CodingKeys.self)
        
        var leaf = root.nestedUnkeyedContainer(forKey: .species)
        let rootSpecies = all.filter { $0.parentName == nil }
        for speciesTraits in rootSpecies {
            try leaf.encode(speciesTraits, configuration: configuration)
        }
    }
}
