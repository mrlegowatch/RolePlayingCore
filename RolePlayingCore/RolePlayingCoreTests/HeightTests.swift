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
    
    let decoder = JSONDecoder()

    func testHeights() {

        do {
            let howTall = "5".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 5.0, "height should be 3.0")
        }

        do {
            let howTall = "3.0".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 3.0, "height should be 3.0")
        }
  
        do {
            let howTall = "4 ft 3 in".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 4.0 + 3.0/12.0, "height should be 4.25")
        }

        do {
            let howTall = "73in".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            let howTallValue = howTall?.value ?? 0.0
            XCTAssertEqualWithAccuracy(howTallValue, 6.0 + 1.0/12.0, accuracy: 0.0001, "height should be 6.08")
        }

        do {
            let howTall = "5'4\"".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 5.0 + 4.0/12.0, "height should be 5.33")
        }
        
        do {
            let howTall = "130 cm".parseHeight?.converted(to: .meters)
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 1.3, "height should be 1.3")
        }
        
        do {
            let howTall = "2.1m".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 2.1, "height should be 2.1")
        }

        
    }
    
    func testInvalidHeights() {
        do {
            let howTall = "3 hello".parseHeight
            XCTAssertNil(howTall, "height should be nil")
        }

    }
}
