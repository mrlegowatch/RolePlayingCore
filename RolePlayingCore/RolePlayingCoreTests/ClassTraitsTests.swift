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
    
    // MARK: - Edge Case Tests
    
    func testExperiencePointsEdgeCases() {
        // Test with empty experience points array
        do {
            let traits = """
            {
                "name": "Novice",
                "plural": "Novices",
                "hit dice": "d6",
                "starting wealth": "2d4x10",
                "experience points": []
            }
            """.data(using: .utf8)!
            
            let classTraits = try decoder.decode(ClassTraits.self, from: traits)
            XCTAssertNotNil(classTraits.experiencePoints, "Should decode empty array")
            XCTAssertEqual(classTraits.experiencePoints?.count, 0, "Should have 0 experience points")
            XCTAssertEqual(classTraits.maxLevel, 0, "Max level should be 0 for empty array")
            XCTAssertEqual(classTraits.minExperiencePoints(at: 1), 0, "Min XP should be 0")
            XCTAssertEqual(classTraits.maxExperiencePoints(at: 1), -1, "Max XP should be -1")
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
        
        // Test with single level experience points
        do {
            let traits = """
            {
                "name": "Novice",
                "plural": "Novices",
                "hit dice": "d6",
                "starting wealth": "2d4x10",
                "experience points": [0]
            }
            """.data(using: .utf8)!
            
            let classTraits = try decoder.decode(ClassTraits.self, from: traits)
            XCTAssertEqual(classTraits.maxLevel, 1, "Max level should be 1")
            XCTAssertEqual(classTraits.minExperiencePoints(at: 1), 0, "Min XP at level 1 should be 0")
            XCTAssertEqual(classTraits.minExperiencePoints(at: 2), 0, "Beyond max level should return last value")
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
        
        // Test level 0 and negative levels
        do {
            let classTraits = ClassTraits(
                name: "Test",
                plural: "Tests",
                hitDice: SimpleDice(.d8),
                startingWealth: SimpleDice(.d4),
                experiencePoints: [0, 300, 900, 2700]
            )
            
            XCTAssertEqual(classTraits.minExperiencePoints(at: 0), 0, "Level 0 should map to level 1")
            XCTAssertEqual(classTraits.minExperiencePoints(at: -5), 0, "Negative level should map to level 1")
            XCTAssertEqual(classTraits.maxExperiencePoints(at: 0), 0, "Max XP at level 0 should work")
        }
        
        // Test beyond max level
        do {
            let classTraits = ClassTraits(
                name: "Test",
                plural: "Tests",
                hitDice: SimpleDice(.d8),
                startingWealth: SimpleDice(.d4),
                experiencePoints: [0, 300, 900]
            )
            
            XCTAssertEqual(classTraits.maxLevel, 3, "Max level should be 3")
            XCTAssertEqual(classTraits.minExperiencePoints(at: 10), 900, "Beyond max should return last value")
            XCTAssertEqual(classTraits.maxExperiencePoints(at: 3), 899, "Max XP at level 3")
        }
    }
    
    func testEmptyAndNilOptionalFields() {
        // Test with all optional fields as empty arrays/dictionaries
        do {
            let traits = """
            {
                "name": "Minimalist",
                "plural": "Minimalists",
                "hit dice": "d8",
                "starting wealth": "3d4x10",
                "descriptive traits": {},
                "primary ability": [],
                "saving throws": [],
                "starting skill count": 0,
                "skill proficiencies": [],
                "weapon proficiencies": [],
                "tool proficiencies": [],
                "armor training": [],
                "starting equipment": []
            }
            """.data(using: .utf8)!
            
            let classTraits = try decoder.decode(ClassTraits.self, from: traits)
            
            XCTAssertEqual(classTraits.descriptiveTraits.count, 0, "Descriptive traits should be empty")
            XCTAssertEqual(classTraits.primaryAbility.count, 0, "Primary ability should be empty")
            XCTAssertNil(classTraits.alternatePrimaryAbility, "Alternate primary ability should be nil")
            XCTAssertEqual(classTraits.savingThrows.count, 0, "Saving throws should be empty")
            XCTAssertEqual(classTraits.startingSkillCount, 0, "Starting skill count should be 0")
            XCTAssertEqual(classTraits.skillProficiencies.count, 0, "Skill proficiencies should be empty")
            XCTAssertEqual(classTraits.weaponProficiencies.count, 0, "Weapon proficiencies should be empty")
            XCTAssertEqual(classTraits.toolProficiencies.count, 0, "Tool proficiencies should be empty")
            XCTAssertEqual(classTraits.armorTraining.count, 0, "Armor training should be empty")
            XCTAssertEqual(classTraits.startingEquipment.count, 0, "Starting equipment should be empty")
            XCTAssertNil(classTraits.experiencePoints, "Experience points should be nil")
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
    }
    
    func testMultiplePrimaryAbilities() {
        // Test with multiple primary and alternate abilities
        do {
            let traits = """
            {
                "name": "Ranger",
                "plural": "Rangers",
                "hit dice": "d10",
                "starting wealth": "5d4x10",
                "primary ability": ["Strength", "Dexterity"],
                "alternate primary ability": ["Constitution", "Wisdom"]
            }
            """.data(using: .utf8)!
            
            let classTraits = try decoder.decode(ClassTraits.self, from: traits)
            
            XCTAssertEqual(classTraits.primaryAbility.count, 2, "Should have 2 primary abilities")
            XCTAssertEqual(classTraits.primaryAbility, [Ability("Strength"), Ability("Dexterity")])
            XCTAssertEqual(classTraits.alternatePrimaryAbility?.count, 2, "Should have 2 alternate abilities")
            XCTAssertEqual(classTraits.alternatePrimaryAbility, [Ability("Constitution"), Ability("Wisdom")])
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
    }
    
    func testNestedStartingEquipment() {
        // Test with complex nested equipment choices
        do {
            let traits = """
            {
                "name": "Paladin",
                "plural": "Paladins",
                "hit dice": "d10",
                "starting wealth": "5d4x10",
                "starting equipment": [
                    ["Longsword", "Shield"],
                    ["Greatsword"],
                    ["5 Javelins", "Simple Weapon"],
                    ["Priest's Pack", "Explorer's Pack"],
                    ["Chain Mail", "Holy Symbol"]
                ]
            }
            """.data(using: .utf8)!
            
            let classTraits = try decoder.decode(ClassTraits.self, from: traits)
            
            XCTAssertEqual(classTraits.startingEquipment.count, 5, "Should have 5 equipment choices")
            XCTAssertEqual(classTraits.startingEquipment[0], ["Longsword", "Shield"])
            XCTAssertEqual(classTraits.startingEquipment[1], ["Greatsword"])
            XCTAssertEqual(classTraits.startingEquipment[3], ["Priest's Pack", "Explorer's Pack"])
        } catch {
            XCTFail("Failed to decode: \(error)")
        }
    }
    
    func testRoundTripEncodingWithAllFields() {
        // Test complete round-trip encoding/decoding with all fields populated
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        
        let original = ClassTraits(
            name: "Bard",
            plural: "Bards",
            hitDice: SimpleDice(.d8),
            startingWealth: CompoundDice(.d4, times: 5, modifier: 10, mathOperator: "x"),
            descriptiveTraits: ["Spellcasting": "Can cast spells", "Bardic Inspiration": "Can inspire others"],
            primaryAbility: [Ability("Charisma")],
            alternatePrimaryAbility: [Ability("Dexterity")],
            savingThrows: [Ability("Dexterity"), Ability("Charisma")],
            startingSkillCount: 3,
            skillProficiencies: ["Acrobatics", "Performance", "Persuasion"],
            weaponProficiencies: ["Simple Weapons", "Hand Crossbows", "Longswords", "Rapiers", "Shortswords"],
            toolProficiencies: ["Three Musical Instruments"],
            armorTraining: ["Light Armor"],
            startingEquipment: [["Rapier", "Longsword"], ["Diplomat's Pack", "Entertainer's Pack"]],
            experiencePoints: [0, 300, 900, 2700, 6500, 14000]
        )
        
        do {
            let encoded = try encoder.encode(original)
            let decoded = try decoder.decode(ClassTraits.self, from: encoded)
            
            XCTAssertEqual(decoded.name, original.name, "Name should match after round-trip")
            XCTAssertEqual(decoded.plural, original.plural, "Plural should match")
            XCTAssertEqual(decoded.primaryAbility, original.primaryAbility, "Primary ability should match")
            XCTAssertEqual(decoded.alternatePrimaryAbility, original.alternatePrimaryAbility, "Alternate ability should match")
            XCTAssertEqual(decoded.savingThrows, original.savingThrows, "Saving throws should match")
            XCTAssertEqual(decoded.startingSkillCount, original.startingSkillCount, "Skill count should match")
            XCTAssertEqual(decoded.skillProficiencies, original.skillProficiencies, "Skill proficiencies should match")
            XCTAssertEqual(decoded.weaponProficiencies, original.weaponProficiencies, "Weapon proficiencies should match")
            XCTAssertEqual(decoded.toolProficiencies, original.toolProficiencies, "Tool proficiencies should match")
            XCTAssertEqual(decoded.armorTraining, original.armorTraining, "Armor training should match")
            XCTAssertEqual(decoded.startingEquipment, original.startingEquipment, "Starting equipment should match")
            XCTAssertEqual(decoded.experiencePoints, original.experiencePoints, "Experience points should match")
            XCTAssertEqual(decoded.descriptiveTraits.count, original.descriptiveTraits.count, "Descriptive traits count should match")
            XCTAssertEqual(decoded.maxLevel, 6, "Max level should be 6")
        } catch {
            XCTFail("Failed round-trip encoding/decoding: \(error)")
        }
    }
}
