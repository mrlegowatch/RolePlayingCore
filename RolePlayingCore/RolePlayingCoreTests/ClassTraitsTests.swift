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
    
    func testDecodingClassTraits() {
        // Test nominal required traits
        do {
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
                let classTraits = try decoder.decode(ClassTraits.self, from: traits)
                
                XCTAssertEqual(classTraits.name, "Fighter", "name")
                XCTAssertEqual(classTraits.plural, "Fighters", "plural")
                let hitDice = classTraits.hitDice as? SimpleDice
                XCTAssertNotNil(hitDice, "hit dice")
                XCTAssertEqual(hitDice?.sides, 10, "hit dice sides")
                XCTAssertEqual(hitDice?.times, 1, "hit dice times")
                
                let primaryAbility: [Ability] = classTraits.primaryAbility
                XCTAssertEqual(primaryAbility, [Ability("Strength")], "primary ability")
                
                let savingThrows: [Ability] = classTraits.savingThrows
                XCTAssertEqual(savingThrows, [Ability("Strength"), Ability("Constitution")], "saving throws")
                
                let startingWealth = classTraits.startingWealth as? CompoundDice
                XCTAssertNotNil(startingWealth, "starting wealth")
                
                XCTAssertNil(classTraits.experiencePoints, "experience points")
            }
            catch let error {
                XCTFail("Error decoding classTraits: \(error)")
            }
        }
        
        // Test minimum required traits
        do {
            let traits = """
            {
                "name": "Fighter",
                "plural": "Fighters",
                "hit dice": "d10",
                "starting wealth": "5d4x10"
            }
            """.data(using: .utf8)!
            do {
                let classTraits = try decoder.decode(ClassTraits.self, from: traits)
                
                XCTAssertNotNil(classTraits)
                XCTAssertEqual(classTraits.name, "Fighter", "name")
                XCTAssertEqual(classTraits.plural, "Fighters", "plural")
                let hitDice = classTraits.hitDice as? SimpleDice
                XCTAssertNotNil(hitDice, "hit dice")
                XCTAssertEqual(hitDice?.sides, 10, "hit dice sides")
                XCTAssertEqual(hitDice?.times, 1, "hit dice times")
                
                let primaryAbility: [Ability] = classTraits.primaryAbility
                XCTAssertEqual(primaryAbility.count, 0, "primary ability")
                
                let savingThrows: [Ability] = classTraits.savingThrows
                XCTAssertEqual(savingThrows.count, 0, "saving throws")
                
                let startingWealth = classTraits.startingWealth as? CompoundDice
                XCTAssertNotNil(startingWealth, "starting wealth")
                
                XCTAssertNil(classTraits.experiencePoints, "experience points")
            }
            catch let error {
                XCTFail("Error decoding classTraits: \(error)")
            }
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
                
                let experiencePoints: [Int] = classTraits?.experiencePoints ?? []
                XCTAssertEqual(experiencePoints, [300, 900, 2700], "experience points")
            }
            catch let error {
                XCTFail("Error decoding classTraits: \(error)")
            }
        }
    }
    
    func testEncodingClassTraits() {
        let encoder = JSONEncoder()
        
        // Test encoding required traits
        do {
            let classTraits = ClassTraits(name: "Fighter",
                                          plural: "Fighters",
                                          hitDice: SimpleDice(.d10),
                                          startingWealth: CompoundDice(.d4, times: 5, modifier: 10, mathOperator: "x"))
            
            do {
                let encoded = try encoder.encode(classTraits)
                let dictionary = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any]
                XCTAssertEqual(dictionary?["name"] as? String, "Fighter", "name")
                XCTAssertEqual(dictionary?["plural"] as? String, "Fighters", "plural")
                XCTAssertEqual(dictionary?["hit dice"] as? String, "d10", "hit dice")
                XCTAssertEqual(dictionary?["starting wealth"] as? String, "5d4x10", "starting wealth")
            }
            catch let error {
                XCTFail("Error decoding classTraits: \(error)")
            }
        }
    }
    
    func testMissingClassTraits() {
        
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
    }

}
