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
class MockRandomNumberGenerator: RandomNumberGenerator {
    
    var current: Int = 0
    
    func random(_ upperBound: Int) -> Int {
        defer { current += 1 }
        return current % upperBound
    }
    
}
class NameGeneratorTests: XCTestCase {
    
    func testNameGenerator() {
        NameGenerator.randomNumberGenerator = MockRandomNumberGenerator()
        defer { NameGenerator.randomNumberGenerator = DefaultRandomNumberGenerator() }
        
        let bundle = Bundle(for: NameGeneratorTests.self)
        let data = try! bundle.loadJSON("TestNames")
        let decoder = JSONDecoder()
        let generator = try! decoder.decode(NameGenerator.self, from: data)
        
        let expectedNames = ["Abadh", "Eunach", "Aillach", "Alsearbore", "Aod", "Aodel", "Edan", "Aodvoda", "Argcran", "Art", "Baedan", "Behman", "Borigricus", "Briccus", "Kerbeas", "Caoinn", "Keid", "Cardhan", "Cathailgne", "Cathach"]
        var generatedNames = [String]()
        for index in 0..<20 {
            let name = generator.makeName()
            generatedNames.append(name)
            XCTAssertEqual(expectedNames[index], name, "expected generated name")
        }
        print("Generated names: \(generatedNames)")
    }
    
}
