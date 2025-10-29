//
//  SpeciesNamesTests.swift
//  RolePlayingCoreTests
//
//  Created by Brian Arnold on 7/8/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
@testable import RolePlayingCore

@Suite("Species Names")
struct SpeciesNamesTests {
    
    @Test("Loading and generating species names")
    func speciesNames() async throws {
        let bundle = testBundle
        let data = try bundle.loadJSON("TestSpeciesNames")
        let decoder = JSONDecoder()
        let speciesNames = try decoder.decode(SpeciesNames.self, from: data)
        
        #expect(speciesNames.names.count == 8, "Number of species name families")
        
        // TODO: find a way to test just the minimum functionality.
        // In the meantime, use the test species.
        let jsonData = try bundle.loadJSON("TestSpecies")
        let species = try decoder.decode(Species.self, from: jsonData)
        let moreJsonData = try bundle.loadJSON("TestMoreSpecies")
        let moreSpecies = try decoder.decode(Species.self, from: moreJsonData)
        
        let allSpecies = Species()
        allSpecies.species = species.species + moreSpecies.species
        
        // TODO: random names are hard; for now, get code coverage.
        let human = try #require(allSpecies.find("Human"))
        _ = speciesNames.randomName(speciesTraits: human, gender: .female)
        
        let elf = try #require(allSpecies.find("Elf"))
        _ = speciesNames.randomName(speciesTraits: elf, gender: .male)
        
        let mountainDwarf = try #require(allSpecies.find("Mountain Dwarf"))
        _ = speciesNames.randomName(speciesTraits: mountainDwarf, gender: nil)
        
        let stout = try #require(allSpecies.find("Stout"))
        _ = speciesNames.randomName(speciesTraits: stout, gender: nil)
        
        let dragonborn = try #require(allSpecies.find("Dragonborn"))
        _ = speciesNames.randomName(speciesTraits: dragonborn, gender: nil)
        
        let tiefling = try #require(allSpecies.find("Tiefling"))
        _ = speciesNames.randomName(speciesTraits: tiefling, gender: nil)
        
        let encoder = JSONEncoder()
        _ = try encoder.encode(speciesNames)
    }
}
