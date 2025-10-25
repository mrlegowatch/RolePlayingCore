//
//  SpeciesNamesTests.swift
//  RolePlayingCoreTests
//
//  Created by Brian Arnold on 7/8/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

@testable import RolePlayingCore

class SpeciesNamesTests: XCTestCase {
    
    func testSpeciesNames() {
        let bundle = Bundle(for: SpeciesNamesTests.self)
        do {
            let data = try bundle.loadJSON("TestSpeciesNames")
            let decoder = JSONDecoder()
            let speciesNames = try decoder.decode(SpeciesNames.self, from: data)
            
            XCTAssertEqual(speciesNames.names.count, 10, "Number of species name families")
            
            // TODO: find a way to test just the minimum functionality.
            // In the meantime, use the test species.
            let bundle = Bundle(for: SpeciesNamesTests.self)
            let jsonData = try bundle.loadJSON("TestSpecies")
            let species = try decoder.decode(Species.self, from: jsonData)
            let moreJsonData = try bundle.loadJSON("TestMoreSpecies")
            let moreSpecies = try decoder.decode(Species.self, from: moreJsonData)
            
            let allSpecies = Species()
            allSpecies.species = species.species + moreSpecies.species
            
            // TODO: random names are hard; for now, get code coverage.
            do {
                _ = speciesNames.randomName(speciesTraits: allSpecies.find("Human")!, gender: .female)
                _ = speciesNames.randomName(speciesTraits: allSpecies.find("Elf")!, gender: .male)
                _ = speciesNames.randomName(speciesTraits: allSpecies.find("Mountain Dwarf")!, gender: nil)
                _ = speciesNames.randomName(speciesTraits: allSpecies.find("Stout")!, gender: nil)
                _ = speciesNames.randomName(speciesTraits: allSpecies.find("Half-Elf")!, gender: nil)
                _ = speciesNames.randomName(speciesTraits: allSpecies.find("Half-Orc")!, gender: nil)
                _ = speciesNames.randomName(speciesTraits: allSpecies.find("Dragonborn")!, gender: nil)
                _ = speciesNames.randomName(speciesTraits: allSpecies.find("Tiefling")!, gender: nil)
                
            }
            
            let encoder = JSONEncoder()
            _ = try encoder.encode(speciesNames)
        }
        catch let error {
            XCTFail("error thrown: \(error)")
        }
    }
}
