//
//  SpeciesTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/16/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Species Tests")
struct SpeciesTests {
    
    let bundle = Bundle.module
    let decoder = JSONDecoder()
    
    @Test("Default initialization creates empty species")
    func defaultInit() async throws {
        let species = Species()
        #expect(species.species.count == 0, "default init")
    }
    
    @Test("Load and parse species from JSON file")
    func species() async throws {
        let jsonData = try bundle.loadJSON("TestSpecies")
        let species = try decoder.decode(Species.self, from: jsonData)
        
        #expect(species.leafSpecies.count == 8, "all species")
        #expect(species.count == 11, "all species")
        #expect(species[0] != nil, "species by index")
        
        // Test finding a species by name
        #expect(species.find("Human") != nil, "Fighter should be non-nil")
        #expect(species.find("Foo") == nil, "Foo should be nil")
        #expect(species.find(nil) == nil, "nil species name should find nil")
    }
    
    @Test("Load uncommon species from JSON file")
    func uncommonSpecies() async throws {
        let jsonData = try bundle.loadJSON("TestMoreSpecies")
        let species = try decoder.decode(Species.self, from: jsonData)
        
        // There should be 5 species plus 2 subspecies
        #expect(species.species.count == 5, "all species")
    }
}
