//
//  JSONFileTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/17/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

struct JSONFileData: Codable {
    let boolValue: Bool
    
    struct DictionaryValue: Codable {
        let stringValue: String
        let doubleValue: Double
        let arrayValue: [Int]
    }
    let dictionaryValue: DictionaryValue
}

struct AnyFileData: Codable {
    // No-op
}

@Suite("JSON File Loading Tests")
struct JSONFileTests {
    
    let decoder = JSONDecoder()
    
    let testBundle = Bundle.module
    
    @Test("Load and parse valid JSON file")
    func json() async throws {
        // This test file has all of the basic elements of a JSON file
        let bundle = testBundle
        
        let jsonData = try bundle.loadJSON("JSONFile")
        let jsonObject = try decoder.decode(JSONFileData.self, from: jsonData)
        
        // Test for contents of JSON file
        let bool = jsonObject.boolValue
        #expect(bool == true, "bool should be true")
        
        let dictionary = jsonObject.dictionaryValue
        
        let string = dictionary.stringValue
        #expect(string == "foo", "string should be \"foo\"")
        
        let double = dictionary.doubleValue
        #expect(double == 2.1, "double should be 2.1")
        
        let array = dictionary.arrayValue
        #expect(array == [2, 3], "array should be [2, 3]")
    }
    
    @Test("Attempt to load missing JSON file")
    func missingJSON() async throws {
        // This test file is not present in the bundle.
        let bundle = testBundle
        
        #expect(throws: (any Error).self) {
            _ = try bundle.loadJSON("MissingJSONFile")
        }
        
        // Verify it's specifically a ServiceError
        do {
            _ = try bundle.loadJSON("MissingJSONFile")
            Issue.record("Should have thrown an error")
        } catch {
            #expect(error is ServiceError, "expected ServiceError, got \(error)")
        }
    }
    
    @Test("Attempt to parse invalid JSON file")
    func invalidJSON() async throws {
        // This test file contains errors in formatting.
        let bundle = testBundle

        #expect(throws: (any Error).self) {
            let jsonData = try bundle.loadJSON("InvalidJSONFile")
            _ = try decoder.decode(AnyFileData.self, from: jsonData)
        }
    }
    
    @Test("Attempt to parse half-baked JSON file")
    func halfBakedJSON() async throws {
        // This test file lacks a dictionary at the root.
        let bundle = testBundle

        #expect(throws: (any Error).self) {
            let jsonData = try bundle.loadJSON("HalfBakedJSONFile")
            _ = try decoder.decode(AnyFileData.self, from: jsonData)
        }
    }
}
