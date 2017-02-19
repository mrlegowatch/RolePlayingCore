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
            let trait = 70
            let howHeavy = Weight(from: trait)
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 70, "weight should be 3.0")
        }

        do {
            let trait = 3.0
            let howHeavy = Weight(from: trait)
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 3.0, "weight should be 3.0")
        }

        do {
            let trait = "45lb"
            let howHeavy = Weight(from: trait)
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 45, "weight should be 45")
        }

        do {
            let trait = "174 kg"
            let howHeavy = Weight(from: trait)
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 174, "weight should be 174")
        }

    }
    
    func testInvalidWeights() {
        do {
            let trait = "99 hello"
            let howHeavy = Weight(from: trait)
            XCTAssertNil(howHeavy, "weight should be nil")
        }

        do {
            let howHeavy = Weight(from: nil)
            XCTAssertNil(howHeavy, "weight should be nil")
        }
    }
}
