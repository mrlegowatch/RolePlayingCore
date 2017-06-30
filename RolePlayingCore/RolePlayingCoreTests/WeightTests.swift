//
//  UnitWeightTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class UnitWeightTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    func testWeights() {
        do {
            let howHeavy = "70".parseWeight
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 70, "weight should be 3.0")
        }

        do {
            let howHeavy = "3.0".parseWeight
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 3.0, "weight should be 3.0")
        }

        do {
            let howHeavy = "45lb".parseWeight
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 45, "weight should be 45")
        }

        do {
            let howHeavy = "174 kg".parseWeight
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 174, "weight should be 174")
        }
    }
    
    func testInvalidWeights() {
        do {
            let howHeavy = "99 hello".parseWeight
            XCTAssertNil(howHeavy, "weight should be nil")
        }
    }
}
