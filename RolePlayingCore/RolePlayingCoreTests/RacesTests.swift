//
//  RacesTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/16/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class RacesTests: XCTestCase {
    
    func testRaces() {
        let races = Races()
        do {
            try races.load("TestRaces", in: Bundle(for: RacesTests.self))
        }
        catch let error {
            XCTFail("Races threw an error: \(error)")
        }
        
        XCTAssertNotNil(races, "Races file failed to load")

        XCTAssertEqual(races.allRacialTraits.count, 11, "all racial traits")
        XCTAssertEqual(races.races.count, 8, "all races")
        XCTAssertEqual(races.count, 8, "all races")
        XCTAssertNotNil(races[0], "race by index")
        
        // Test finding a race by name
        XCTAssertNotNil(races.find("Human"), "Fighter should be non-nil")
        XCTAssertNil(races.find("Foo"), "Foo should be nil")
        XCTAssertNil(races.find(nil), "nil race name should find nil")

    }
    
    func testUncommonRaces() {
        // Test throwing constructor
        var races: Races? = nil
        do {
            races = try Races("TestMoreRaces", in: Bundle(for: RacesTests.self))
        }
        catch let error {
            XCTFail("Races threw an error: \(error)")
        }
        
        XCTAssertNotNil(races, "Races file failed to load")
        
        // There should be 5 races plus 2 subraces
        XCTAssertEqual(races?.allRacialTraits.count, 7, "all racial traits")
        XCTAssertEqual(races?.races.count, 6, "all races")
    }
}
