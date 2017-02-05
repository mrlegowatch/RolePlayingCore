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
    
    func testWeights() {
        do {
            let trait = 3.0
            let howHeavy = weight(from: trait)
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 3.0, "weight should be 3.0")
        }

        do {
            let trait = "45lb"
            let howHeavy = weight(from: trait)
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 45, "weight should be 45")
        }

        do {
            let trait = "174 kg"
            let howHeavy = weight(from: trait)
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 174, "weight should be 174")
        }

    }
    
    func testInvalidWeights() {
        do {
            let trait = "99 hello"
            let howHeavy = weight(from: trait)
            XCTAssertNil(howHeavy, "weight should be nil")
        }

        do {
            let howHeavy = weight(from: nil)
            XCTAssertNil(howHeavy, "weight should be nil")
        }
    }
}
