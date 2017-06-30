//
//  JSONFileTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/17/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

struct JSONFileData: Codable {
    let boolValue: Bool
    
    struct DictionaryValue: Codable {
        let stringValue: String
        let doubleValue: Double
        let arrayValue: [Int]
    }
    let dictionaryValue: DictionaryValue
}

class JSONFileTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    func testJSON() {
        // This test file has all of the basic elements of a JSON file
        let bundle = Bundle(for: JSONFileTests.self)
        do {
            let jsonData = try bundle.loadJSON("JSONFile")
            let jsonObject = try decoder.decode(JSONFileData.self, from: jsonData)
            
            // Test for contents of JSON file
            
            let bool = jsonObject.boolValue
            XCTAssertNotNil(bool, "bool should be non-nil")
            XCTAssertEqual(bool, true, "bool should be true")
            
            let dictionary = jsonObject.dictionaryValue
            
            let string = dictionary.stringValue
            XCTAssertEqual(string, "foo", "string should be \"foo\"")
            
            let double = dictionary.doubleValue
            XCTAssertEqual(double, 2.1, "double should be 2.1")
            
            let array = dictionary.arrayValue
            XCTAssertEqual(array, [2, 3], "array should be [2, 3]")
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
            let jsonData = try bundle.loadJSON("InvalidJSONFile")
            let jsonObject = try decoder.decode([String:Any].self, from: jsonData)
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
            let jsonData = try bundle.loadJSON("HalfBakedJSONFile")
            let jsonObject = try decoder.decode([String:Any].self, from: jsonData)
            XCTAssertNil(jsonObject, "should not get here")
        }
        catch let error {
            print("Successfully caught \(error)")
            // OK we got here. it's an error NSCocoaErrorDomain Code 3840 "JSON text did not start with an array or object and option to allow fragments not set."
        }
    }
}
