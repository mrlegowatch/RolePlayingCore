//
//  JSONFileTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/17/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class JSONFileTests: XCTestCase {
    
    func testJSON() {
        // This test file has all of the basic elements of a JSON file
        let bundle = Bundle(for: JSONFileTests.self)
        do {
            let jsonObject = try bundle.loadJSON("JSONFile")
            
            // Test for contents of JSON file
            
            let bool = jsonObject["boolValue"] as? Bool
            XCTAssertNotNil(bool, "bool should be non-nil")
            XCTAssertEqual(bool, true, "bool should be true")
            
            let dictionary = jsonObject["dictionaryValue"] as? [String: Any]
            XCTAssertNotNil(dictionary, "dictionary should be non-nil")
            
            let string = dictionary?["stringValue"] as? String
            XCTAssertNotNil(string, "string should be non-nil")
            XCTAssertEqual(string, "foo", "string should be \"foo\"")
            
            let double = dictionary?["doubleValue"] as? Double
            XCTAssertNotNil(double, "double should be non-nil")
            XCTAssertEqual(double, 2.1, "double should be 2.1")
            
            let array = dictionary?["arrayValue"] as? [Int]
            XCTAssertNotNil(array, "array should be non-nil")
            XCTAssertEqual(array ?? [], [2, 3], "array should be [2, 3]")
        }
        catch let error {
            XCTFail("loadJSON should not throw an error: \(error)")
        }
    }
    
    func testMissingJSON() {
        // This test file is not present in the bundle.
        let bundle = Bundle(for: JSONFileTests.self)
        do {
            let jsonObject = try bundle.loadJSON("MissingJSONFile")
            XCTAssertNil(jsonObject, "should not get here")
        }
        catch let error {
            XCTAssertTrue(error is ServiceError, "expected ServiceError.runtimeError, got \(error)")
        }
    }
    
    func testInvalidJSON() {
        // This test file contains errors in formatting.
        let bundle = Bundle(for: JSONFileTests.self)
        do {
            let jsonObject = try bundle.loadJSON("InvalidJSONFile")
            XCTAssertNil(jsonObject, "should not get here")
        }
        catch let error {
            print("Successfully caught \(error)")
            // OK we got here. it's an error NSCocoaErrorDomain Code 3840 "No value for key in object around character 41."
        }
    }
    
    func testHalfBakedJSON() {
        // This test file lacks a dictionary at the root.
        let bundle = Bundle(for: JSONFileTests.self)
        do {
            let jsonObject = try bundle.loadJSON("HalfBakedJSONFile")
            XCTAssertNil(jsonObject, "should not get here")
        }
        catch let error {
            print("Successfully caught \(error)")
            // OK we got here. it's an error NSCocoaErrorDomain Code 3840 "JSON text did not start with an array or object and option to allow fragments not set."
        }
    }
}
