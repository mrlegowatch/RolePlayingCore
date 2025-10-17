//
//  NameGeneratorTests.swift
//  RolePlayingCoreTests
//
//  Created by Brian Arnold on 7/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

/// Use a mock random number generator so we can hardcode expected generated names.

class NameGeneratorTests: XCTestCase {
    
    func testNameGenerator() {
        let bundle = Bundle(for: NameGeneratorTests.self)
        let data = try! bundle.loadJSON("TestNames")
        let decoder = JSONDecoder()
        let nameGenerator = try! decoder.decode(NameGenerator.self, from: data)
        var generator = MockIndexGenerator()
        
        let expectedNames = ["Abadh", "Eunach", "Aillach", "Alsearbore", "Aod", "Aodel", "Edan", "Aodvoda", "Argcran", "Art"]
        var generatedNames = [String]()
        for index in 0..<10 {
            let name = nameGenerator.makeName(using: &generator)
            generatedNames.append(name)
            XCTAssertEqual(expectedNames[index], name, "expected generated name")
        }
        print("Generated names: \(generatedNames)")
        
        // For code coverage: call makeName with the default Random implementation.
        let _ = nameGenerator.makeName()
    }
    
    func testRandomNumberGenerator() {
        var generator = MockIndexGenerator()
        
        let testNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        for _ in 0 ..< testNumbers.count {
            let randomIndex = generator.randomIndex(upperBound: testNumbers.count)
            print(testNumbers[randomIndex])
        }
    }
}
