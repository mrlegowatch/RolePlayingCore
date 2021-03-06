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
    
    let bundle = Bundle(for: RacesTests.self)
    let decoder = JSONDecoder()
    
    func testDefaultInit() {
        let races = Races()
        XCTAssertEqual(races.races.count, 0, "default init")
    }
    
    func testRaces() {
        do {
            let jsonData = try bundle.loadJSON("TestRaces")
            let races = try decoder.decode(Races.self, from: jsonData)
            
            XCTAssertNotNil(races, "Races file failed to load")
            
            XCTAssertEqual(races.leafRaces.count, 8, "all races")
            XCTAssertEqual(races.count, 11, "all races")
            XCTAssertNotNil(races[0], "race by index")
            
            // Test finding a race by name
            XCTAssertNotNil(races.find("Human"), "Fighter should be non-nil")
            XCTAssertNil(races.find("Foo"), "Foo should be nil")
            XCTAssertNil(races.find(nil), "nil race name should find nil")
        }
        catch let error {
            XCTFail("Races threw an error: \(error)")
        }
    }
    
    func testUncommonRaces() {
        // Test throwing constructor
        do {
            let jsonData = try bundle.loadJSON("TestMoreRaces")
            let races = try decoder.decode(Races.self, from: jsonData)
            
            XCTAssertNotNil(races, "Races file failed to load")
            
            // There should be 5 races plus 2 subraces
            XCTAssertEqual(races.races.count, 7, "all races")
            
        }
        catch let error {
            XCTFail("Races threw an error: \(error)")
        }
    }
    
}
