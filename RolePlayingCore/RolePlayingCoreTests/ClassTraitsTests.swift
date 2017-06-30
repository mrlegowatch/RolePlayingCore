//
//  ClassTraitsTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/13/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class ClassTraitsTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    func testClassTraits() {
        // Test minimum required traits
        do {
            var classTraits: ClassTraits! = nil
            let traits = """
            {
                "name": "Fighter",
                "plural": "Fighters",
                "hit dice": "d10",
                "primary ability": ["Strength"],
                "alternate primary ability": ["Dexterity"],
                "saving throws": ["Strength", "Constitution"],
                "starting wealth": "5d4x10"
            }
            """.data(using: .utf8)!
            do {
                classTraits = try decoder.decode(ClassTraits.self, from: traits)
            }
            catch let error {
                XCTFail("Error decoding classTraits: \(error)")
            }
            XCTAssertNotNil(classTraits)
            XCTAssertEqual(classTraits?.name, "Fighter", "name")
            XCTAssertEqual(classTraits?.plural, "Fighters", "plural")
            let hitDice = classTraits?.hitDice as? SimpleDice
            XCTAssertNotNil(hitDice, "hit dice")
            XCTAssertEqual(hitDice?.sides, 10, "hit dice sides")
            XCTAssertEqual(hitDice?.times, 1, "hit dice times")

            let primaryAbility: [Ability] = classTraits?.primaryAbility ?? []
            XCTAssertEqual(primaryAbility, [Ability("Strength")], "primary ability")
            
            let savingThrows: [Ability] = classTraits?.savingThrows ?? []
            XCTAssertEqual(savingThrows, [Ability("Strength"), Ability("Constitution")], "saving throws")

            let startingWealth = classTraits?.startingWealth as? CompoundDice
            XCTAssertNotNil(startingWealth, "starting wealth")
            
            XCTAssertNil(classTraits?.experiencePoints, "experience points")
        }
        
        // Test traits with optional experience points
        
        do {
            var classTraits: ClassTraits! = nil
            
            let traits = """
                {
                    "name": "Fighter",
                    "plural": "Fighters",
                    "hit dice": "d10",
                    "primary ability": ["Strength"],
                    "alternate primary ability": ["Dexterity"],
                    "saving throws": ["Strength", "Constitution"],
                    "starting wealth": "5d4x10",
                    "experience points": [300, 900, 2700]
                }
                """.data(using: .utf8)!
            do {
                classTraits = try decoder.decode(ClassTraits.self, from: traits)
            }
            catch let error {
                XCTFail("Error decoding classTraits: \(error)")
            }
        
            let experiencePoints: [Int] = classTraits?.experiencePoints ?? []
            XCTAssertEqual(experiencePoints, [300, 900, 2700], "experience points")
        }
    }

    func testMissingTraits() {
        
        // Test that each missing trait results in nil
        do {
            let traits = "{}".data(using: .utf8)!
            let classTraits = try? decoder.decode(ClassTraits.self, from: traits)
            XCTAssertNil(classTraits)
        }
        
        do {
            let traits = """
                {
                    "name": "Fighter"
                }
                """.data(using: .utf8)!
            let classTraits = try? decoder.decode(ClassTraits.self, from: traits)
            XCTAssertNil(classTraits)
        }
        
        
        do {
            let traits = """
                {
                    "name": "Fighter",
                    "plural": "Fighters"
                }
                """.data(using: .utf8)!
            let classTraits = try? decoder.decode(ClassTraits.self, from: traits)
            XCTAssertNil(classTraits)
        }
        
        do {
            let traits = """
                {
                    "name": "Fighter",
                    "plural": "Fighters",
                    "hit dice": "d10"
                }
                """.data(using: .utf8)!
            let classTraits = try? decoder.decode(ClassTraits.self, from: traits)
            XCTAssertNil(classTraits)
        }
        
        do {
            let traits = """
                {
                    "name": "Fighter",
                    "plural": "Fighters",
                    "hit dice": "d10",
                    "primary ability": ["Strength"]
                }
                """.data(using: .utf8)!
            let classTraits = try? decoder.decode(ClassTraits.self, from: traits)
            XCTAssertNil(classTraits)
        }
        
        do {
            let traits = """
                {
                    "name": "Fighter",
                    "plural": "Fighters",
                    "hit dice": "d10",
                    "primary ability": ["Strength"],
                    "alternate primary ability": ["Dexterity"]
                }
                """.data(using: .utf8)!
            let classTraits = try? decoder.decode(ClassTraits.self, from: traits)
            XCTAssertNil(classTraits)
        }
        
        do {
            let traits = """
                {
                    "name": "Fighter",
                    "plural": "Fighters",
                    "hit dice": "d10",
                    "primary ability": ["Strength"],
                    "alternate primary ability": ["Dexterity"],
                    "saving throws": ["Strength", "Constitution"]
                }
                """.data(using: .utf8)!
            let classTraits = try? decoder.decode(ClassTraits.self, from: traits)
            XCTAssertNil(classTraits)
        }
    }

}
