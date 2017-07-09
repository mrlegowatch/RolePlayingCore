//
//  RacialNamesTests.swift
//  RolePlayingCoreTests
//
//  Created by Brian Arnold on 7/8/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

@testable import RolePlayingCore

class RacialNamesTests: XCTestCase {
    
    func testRacialNames() {
        let bundle = Bundle(for: RacialNamesTests.self)
        do {
            let data = try bundle.loadJSON("TestRacialNames")
            let decoder = JSONDecoder()
            let racialNames = try decoder.decode(RacialNames.self, from: data)
            
            XCTAssertEqual(racialNames.names.count, 10, "Number of racial name families")
            
            // TODO: find a way to test just the minimum functionality.
            // In the meantime, use the test races.
            let bundle = Bundle(for: RacialNamesTests.self)
            let jsonData = try bundle.loadJSON("TestRaces")
            let races = try decoder.decode(Races.self, from: jsonData)
            let moreJsonData = try bundle.loadJSON("TestMoreRaces")
            let moreRaces = try decoder.decode(Races.self, from: moreJsonData)
            
            let allRaces = Races()
            allRaces.races = races.races + moreRaces.races
            
            // TODO: random names are hard; for now, get code coverage.
            do {
                _ = racialNames.randomName(racialTraits: allRaces.find("Human")!, gender: .female)
                _ = racialNames.randomName(racialTraits: allRaces.find("Elf")!, gender: .male)
                _ = racialNames.randomName(racialTraits: allRaces.find("Mountain Dwarf")!, gender: nil)
                _ = racialNames.randomName(racialTraits: allRaces.find("Stout")!, gender: nil)
                _ = racialNames.randomName(racialTraits: allRaces.find("Half-Elf")!, gender: nil)
                _ = racialNames.randomName(racialTraits: allRaces.find("Half-Orc")!, gender: nil)
                _ = racialNames.randomName(racialTraits: allRaces.find("Dragonborn")!, gender: nil)
                _ = racialNames.randomName(racialTraits: allRaces.find("Tiefling")!, gender: nil)
                
            }
            
            let encoder = JSONEncoder()
            _ = try encoder.encode(racialNames)
        }
        catch let error {
            XCTFail("error thrown: \(error)")
        }
    }
}
