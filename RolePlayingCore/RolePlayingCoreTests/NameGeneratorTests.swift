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
    
    var current: UInt64 = 0
    
    func next() -> UInt64 {
        defer { current += 1 }
        return current
    }
    
}

class NameGeneratorTests: XCTestCase {
    
    func testNameGenerator() {
        let bundle = Bundle(for: NameGeneratorTests.self)
        let data = try! bundle.loadJSON("TestNames")
        let decoder = JSONDecoder()
        let nameGenerator = try! decoder.decode(NameGenerator.self, from: data)
        var generator = MockRandomNumberGenerator()
        
        let expectedNames = ["Shad", "Sin", "Singnan", "Sirewy", "Teilich", "Tighirgan", "Tirí", "Tatigre", "Toigothar", "Abhdach", "Adcomhadhan", "Aert", "Agus", "Aiel", "Ail", "Ain", "Ain", "Airbhirecan", "Ama", "Aodfingan"]
        var generatedNames = [String]()
        for index in 0..<20 {
            let name = nameGenerator.makeName(using: &generator)
            generatedNames.append(name)
            XCTAssertEqual(expectedNames[index], name, "expected generated name")
        }
        print("Generated names: \(generatedNames)")
        
        // For code coverage: call makeName with the default Random implementation.
        let _ = nameGenerator.makeName()
    }
    
}
