//
//  UnitHeightTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class UnitHeightTests: XCTestCase {
    
    func testHeights() {

        do {
            let trait = 5
            let howTall = height(from: trait)
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 5.0, "height should be 3.0")
        }

        do {
            let trait = 3.0
            let howTall = height(from: trait)
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 3.0, "height should be 3.0")
        }
  
        do {
            let trait = "4 ft 3 in"
            let howTall = height(from: trait)
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 4.0 + 3.0/12.0, "height should be 4.25")
        }

        do {
            let trait = "73in"
            let howTall = height(from: trait)?.converted(to: .feet)
            XCTAssertNotNil(howTall, "height should be non-nil")
            let howTallValue = howTall?.value ?? 0.0
            XCTAssertEqualWithAccuracy(howTallValue, 6.0 + 1.0/12.0, accuracy: 0.0001, "height should be 6.08")
        }

        do {
            let trait = "5'4\""
            let howTall = height(from: trait)
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 5.0 + 4.0/12.0, "height should be 5.33")
        }
        
        do {
            let trait = "130 cm"
            let howTall = height(from: trait)?.converted(to: .meters)
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 1.3, "height should be 1.3")
        }
        
        do {
            let trait = "2.1m"
            let howTall = height(from: trait)
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 2.1, "height should be 2.1")
        }

        
    }
    
    func testInvalidHeights() {
        do {
            let trait = "3 hello"
            let howTall = height(from: trait)
            XCTAssertNil(howTall, "height should be nil")
        }
        
        do {
            let howTall = height(from: nil)
            XCTAssertNil(howTall, "height should be nil")
        }

    }
}
