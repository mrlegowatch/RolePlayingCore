//
//  Species.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

public class Species: Codable {
    
    /// Accesses all of the species and subspecies that have been loaded.
    public var species = [SpeciesTraits]()
    
    /// Creates a Species instance.
    public init() { }
    
    /// Returns all of the leaf species (species that contain no subspecies).
    public var leafSpecies: [SpeciesTraits] {
        return species.filter { (speciesTraits) -> Bool in
            speciesTraits.subspecies.count == 0
        }
    }
    
    /// Returns the species matching the specified name, or nil if not present.
    public func find(_ speciesName: String?) -> SpeciesTraits? {
        guard speciesName != nil else { return nil }
        
        return species.first(where: { $0.name == speciesName })
    }

    public var count: Int { return species.count }
    
    public subscript(index: Int) -> SpeciesTraits? {
        get {
            return species[index]
        }
    }
    
    public func randomElementByIndex<G: RandomIndexGenerator>(using generator: inout G) -> SpeciesTraits {
        return species.randomElementByIndex(using: &generator)!
    }
    
    enum CodingKeys: String, CodingKey {
        case species
    }
    
    /// Overridden to stitch together subspecies embedded in species.
    public required init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        var leaf = try root.nestedUnkeyedContainer(forKey: .species)
        
        var species = [SpeciesTraits]()
        while (!leaf.isAtEnd) {
            let speciesTraits = try leaf.decode(SpeciesTraits.self)
            species.append(speciesTraits)
            
            /// If there are subspecies, append those
            for subspeciesTraits in speciesTraits.subspecies {
                species.append(subspeciesTraits)
            }
        }
        
        self.species = species
    }
    
}
