//
//  CharacterGeneratorTests.swift
//  RolePlayingCoreTests
//
//  Created by Brian Arnold on 7/9/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class CharacterGeneratorTests: XCTestCase {
    
    let bundle = Bundle(for: CharacterGeneratorTests.self)
    
    let sampleSize = 256
    
    func testCharacterGenerator() {
        do {
            let configuration = try Configuration("TestCharacterGenerator", from: bundle)
            let characterGenerator = try CharacterGenerator(configuration, from: bundle)
            
            for _ in 0..<sampleSize {
                _ = characterGenerator.makeCharacter()
                // TODO: implement a predictable Random implementation and consider testing for expected types, names and properties. Such a test could be too sensitive to order of calls.
            }
        }
        catch let error {
            XCTFail("Loading the test configuration failed, error: \(error)")
        }
    }
    
    func testInvalidConfiguration() {
        do {
            let configuration = try Configuration("TestConfiguration", from: bundle)
            do {
                _ = try CharacterGenerator(configuration, from: bundle)
                XCTFail("Unexpectedly succeeded in creating CharacterGenerator with an invalid/missing racialNames file")
            }
            catch let error {
                print("Caught expected error with invalid configuration: \(error)")
            }
        }
        catch let error {
            XCTFail("Loading the test configuration failed, error: \(error)")
        }
    }
}
