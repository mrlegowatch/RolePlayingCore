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
    
    func testRacialNames() {
        let bundle = Bundle(for: SpeciesNamesTests.self)
        do {
            let data = try bundle.loadJSON("TestRacialNames")
            let decoder = JSONDecoder()
            let speciesNames = try decoder.decode(RacialNames.self, from: data)
            
            XCTAssertEqual(speciesNames.names.count, 10, "Number of species name families")
            
            // TODO: find a way to test just the minimum functionality.
            // In the meantime, use the test species.
            let bundle = Bundle(for: SpeciesNamesTests.self)
            let jsonData = try bundle.loadJSON("TestRaces")
            let species = try decoder.decode(Species.self, from: jsonData)
            let moreJsonData = try bundle.loadJSON("TestMoreRaces")
            let moreRaces = try decoder.decode(Species.self, from: moreJsonData)
            
            let allRaces = Species()
            allRaces.species = species.species + moreRaces.species
            
            // TODO: random names are hard; for now, get code coverage.
            do {
                _ = speciesNames.randomName(speciesTraits: allRaces.find("Human")!, gender: .female)
                _ = speciesNames.randomName(speciesTraits: allRaces.find("Elf")!, gender: .male)
                _ = speciesNames.randomName(speciesTraits: allRaces.find("Mountain Dwarf")!, gender: nil)
                _ = speciesNames.randomName(speciesTraits: allRaces.find("Stout")!, gender: nil)
                _ = speciesNames.randomName(speciesTraits: allRaces.find("Half-Elf")!, gender: nil)
                _ = speciesNames.randomName(speciesTraits: allRaces.find("Half-Orc")!, gender: nil)
                _ = speciesNames.randomName(speciesTraits: allRaces.find("Dragonborn")!, gender: nil)
                _ = speciesNames.randomName(speciesTraits: allRaces.find("Tiefling")!, gender: nil)
                
            }
            
            let encoder = JSONEncoder()
            _ = try encoder.encode(speciesNames)
        }
        catch let error {
            XCTFail("error thrown: \(error)")
        }
    }
}
