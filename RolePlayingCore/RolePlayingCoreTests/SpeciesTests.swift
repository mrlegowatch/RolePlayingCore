//
//  SpeciesTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/16/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class SpeciesTests: XCTestCase {
    
    let bundle = Bundle(for: SpeciesTests.self)
    let decoder = JSONDecoder()
    
    func testDefaultInit() {
        let species = Species()
        XCTAssertEqual(species.species.count, 0, "default init")
    }
    
    func testSpecies() {
        do {
            let jsonData = try bundle.loadJSON("TestSpecies")
            let species = try decoder.decode(Species.self, from: jsonData)
            
            XCTAssertNotNil(species, "Species file failed to load")
            
            XCTAssertEqual(species.leafSpecies.count, 8, "all species")
            XCTAssertEqual(species.count, 11, "all species")
            XCTAssertNotNil(species[0], "species by index")
            
            // Test finding a species by name
            XCTAssertNotNil(species.find("Human"), "Fighter should be non-nil")
            XCTAssertNil(species.find("Foo"), "Foo should be nil")
            XCTAssertNil(species.find(nil), "nil species name should find nil")
        }
        catch let error {
            XCTFail("Species threw an error: \(error)")
        }
    }
    
    func testUncommonSpecies() {
        // Test throwing constructor
        do {
            let jsonData = try bundle.loadJSON("TestMoreSpecies")
            let species = try decoder.decode(Species.self, from: jsonData)
            
            XCTAssertNotNil(species, "Species file failed to load")
            
            // There should be 5 species plus 2 subspecies
            XCTAssertEqual(species.species.count, 7, "all species")
            
        }
        catch let error {
            XCTFail("Species threw an error: \(error)")
        }
    }
}
