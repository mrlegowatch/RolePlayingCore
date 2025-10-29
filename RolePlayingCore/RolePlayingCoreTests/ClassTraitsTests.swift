//
//  ClassTraitsTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/13/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore

@Suite("ClassTraits Tests")
struct ClassTraitsTests {
    
    let decoder = JSONDecoder()
    
    @Test("Decoding class traits with nominal required traits")
    func decodingNominalClassTraits() throws {
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
        
        let classTraits = try decoder.decode(ClassTraits.self, from: traits)
        
        #expect(classTraits.name == "Fighter", "name")
        #expect(classTraits.plural == "Fighters", "plural")
        let hitDice = classTraits.hitDice as? SimpleDice
        #expect(hitDice != nil, "hit dice")
        #expect(hitDice?.sides == 10, "hit dice sides")
        #expect(hitDice?.times == 1, "hit dice times")
        
        let primaryAbility: [Ability] = classTraits.primaryAbility
        #expect(primaryAbility == [Ability("Strength")], "primary ability")
        
        let savingThrows: [Ability] = classTraits.savingThrows
        #expect(savingThrows == [Ability("Strength"), Ability("Constitution")], "saving throws")
        
        let startingWealth = classTraits.startingWealth as? CompoundDice
        #expect(startingWealth != nil, "starting wealth")
        
        #expect(classTraits.experiencePoints == nil, "experience points")
    }
    
    @Test("Decoding class traits with minimum required traits")
    func decodingMinimumClassTraits() throws {
        let traits = """
        {
            "name": "Fighter",
            "plural": "Fighters",
            "hit dice": "d10",
            "starting wealth": "5d4x10"
        }
        """.data(using: .utf8)!
        
        let classTraits = try decoder.decode(ClassTraits.self, from: traits)
        
        #expect(classTraits.name == "Fighter", "name")
        #expect(classTraits.plural == "Fighters", "plural")
        let hitDice = classTraits.hitDice as? SimpleDice
        #expect(hitDice != nil, "hit dice")
        #expect(hitDice?.sides == 10, "hit dice sides")
        #expect(hitDice?.times == 1, "hit dice times")
        
        let primaryAbility: [Ability] = classTraits.primaryAbility
        #expect(primaryAbility.count == 0, "primary ability")
        
        let savingThrows: [Ability] = classTraits.savingThrows
        #expect(savingThrows.count == 0, "saving throws")
        
        let startingWealth = classTraits.startingWealth as? CompoundDice
        #expect(startingWealth != nil, "starting wealth")
        
        #expect(classTraits.experiencePoints == nil, "experience points")
    }
    
    @Test("Decoding class traits with optional experience points")
    func decodingClassTraitsWithExperiencePoints() throws {
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
        
        let classTraits = try decoder.decode(ClassTraits.self, from: traits)
        
        let experiencePoints: [Int] = classTraits.experiencePoints ?? []
        #expect(experiencePoints == [300, 900, 2700], "experience points")
    }
    
    @Test("Encoding class traits with required traits")
    func encodingClassTraits() throws {
        let encoder = JSONEncoder()
        
        let classTraits = ClassTraits(name: "Fighter",
                                      plural: "Fighters",
                                      hitDice: SimpleDice(.d10),
                                      startingWealth: CompoundDice(.d4, times: 5, modifier: 10, mathOperator: "x"))
        
        let encoded = try encoder.encode(classTraits)
        let dictionary = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any]
        #expect(dictionary?["name"] as? String == "Fighter", "name")
        #expect(dictionary?["plural"] as? String == "Fighters", "plural")
        #expect(dictionary?["hit dice"] as? String == "d10", "hit dice")
        #expect(dictionary?["starting wealth"] as? String == "5d4x10", "starting wealth")
    }
    
    @Test("Missing class traits should fail to decode")
    func missingClassTraitsFailDecoding() {
        // Test that each missing trait results in nil
        do {
            let traits = "{}".data(using: .utf8)!
            let classTraits = try? decoder.decode(ClassTraits.self, from: traits)
            #expect(classTraits == nil)
        }
        
        do {
            let traits = """
                {
                    "name": "Fighter"
                }
                """.data(using: .utf8)!
            let classTraits = try? decoder.decode(ClassTraits.self, from: traits)
            #expect(classTraits == nil)
        }
        
        do {
            let traits = """
                {
                    "name": "Fighter",
                    "plural": "Fighters"
                }
                """.data(using: .utf8)!
            let classTraits = try? decoder.decode(ClassTraits.self, from: traits)
            #expect(classTraits == nil)
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
            #expect(classTraits == nil)
        }
    }
    
    // MARK: - Edge Case Tests
    
    @Test("Experience points edge cases - empty array")
    func experiencePointsEmptyArray() throws {
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
        #expect(classTraits.experiencePoints != nil, "Should decode empty array")
        #expect(classTraits.experiencePoints?.count == 0, "Should have 0 experience points")
        #expect(classTraits.maxLevel == 0, "Max level should be 0 for empty array")
        #expect(classTraits.minExperiencePoints(at: 1) == 0, "Min XP should be 0")
        #expect(classTraits.maxExperiencePoints(at: 1) == -1, "Max XP should be -1")
    }
    
    @Test("Experience points edge cases - single level")
    func experiencePointsSingleLevel() throws {
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
        #expect(classTraits.maxLevel == 1, "Max level should be 1")
        #expect(classTraits.minExperiencePoints(at: 1) == 0, "Min XP at level 1 should be 0")
        #expect(classTraits.minExperiencePoints(at: 2) == 0, "Beyond max level should return last value")
    }
    
    @Test("Experience points edge cases - level 0 and negative levels")
    func experiencePointsInvalidLevels() {
        let classTraits = ClassTraits(
            name: "Test",
            plural: "Tests",
            hitDice: SimpleDice(.d8),
            startingWealth: SimpleDice(.d4),
            experiencePoints: [0, 300, 900, 2700]
        )
        
        #expect(classTraits.minExperiencePoints(at: 0) == 0, "Level 0 should map to level 1")
        #expect(classTraits.minExperiencePoints(at: -5) == 0, "Negative level should map to level 1")
        #expect(classTraits.maxExperiencePoints(at: 0) == 0, "Max XP at level 0 should work")
    }
    
    @Test("Experience points edge cases - beyond max level")
    func experiencePointsBeyondMaxLevel() {
        let classTraits = ClassTraits(
            name: "Test",
            plural: "Tests",
            hitDice: SimpleDice(.d8),
            startingWealth: SimpleDice(.d4),
            experiencePoints: [0, 300, 900]
        )
        
        #expect(classTraits.maxLevel == 3, "Max level should be 3")
        #expect(classTraits.minExperiencePoints(at: 10) == 900, "Beyond max should return last value")
        #expect(classTraits.maxExperiencePoints(at: 3) == 899, "Max XP at level 3")
    }
    
    @Test("Empty and nil optional fields")
    func emptyOptionalFields() throws {
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
        
        #expect(classTraits.descriptiveTraits.count == 0, "Descriptive traits should be empty")
        #expect(classTraits.primaryAbility.count == 0, "Primary ability should be empty")
        #expect(classTraits.alternatePrimaryAbility == nil, "Alternate primary ability should be nil")
        #expect(classTraits.savingThrows.count == 0, "Saving throws should be empty")
        #expect(classTraits.startingSkillCount == 0, "Starting skill count should be 0")
        #expect(classTraits.skillProficiencies.count == 0, "Skill proficiencies should be empty")
        #expect(classTraits.weaponProficiencies.count == 0, "Weapon proficiencies should be empty")
        #expect(classTraits.toolProficiencies.count == 0, "Tool proficiencies should be empty")
        #expect(classTraits.armorTraining.count == 0, "Armor training should be empty")
        #expect(classTraits.startingEquipment.count == 0, "Starting equipment should be empty")
        #expect(classTraits.experiencePoints == nil, "Experience points should be nil")
    }
    
    @Test("Multiple primary abilities")
    func multiplePrimaryAbilities() throws {
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
        
        #expect(classTraits.primaryAbility.count == 2, "Should have 2 primary abilities")
        #expect(classTraits.primaryAbility == [Ability("Strength"), Ability("Dexterity")])
        #expect(classTraits.alternatePrimaryAbility?.count == 2, "Should have 2 alternate abilities")
        #expect(classTraits.alternatePrimaryAbility == [Ability("Constitution"), Ability("Wisdom")])
    }
    
    @Test("Nested starting equipment")
    func nestedStartingEquipment() throws {
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
        
        #expect(classTraits.startingEquipment.count == 5, "Should have 5 equipment choices")
        #expect(classTraits.startingEquipment[0] == ["Longsword", "Shield"])
        #expect(classTraits.startingEquipment[1] == ["Greatsword"])
        #expect(classTraits.startingEquipment[3] == ["Priest's Pack", "Explorer's Pack"])
    }
    
    @Test("Round-trip encoding with all fields")
    func roundTripEncodingWithAllFields() throws {
        let encoder = JSONEncoder()
        
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
        
        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(ClassTraits.self, from: encoded)
        
        #expect(decoded.name == original.name, "Name should match after round-trip")
        #expect(decoded.plural == original.plural, "Plural should match")
        #expect(decoded.primaryAbility == original.primaryAbility, "Primary ability should match")
        #expect(decoded.alternatePrimaryAbility == original.alternatePrimaryAbility, "Alternate ability should match")
        #expect(decoded.savingThrows == original.savingThrows, "Saving throws should match")
        #expect(decoded.startingSkillCount == original.startingSkillCount, "Skill count should match")
        #expect(decoded.skillProficiencies == original.skillProficiencies, "Skill proficiencies should match")
        #expect(decoded.weaponProficiencies == original.weaponProficiencies, "Weapon proficiencies should match")
        #expect(decoded.toolProficiencies == original.toolProficiencies, "Tool proficiencies should match")
        #expect(decoded.armorTraining == original.armorTraining, "Armor training should match")
        #expect(decoded.startingEquipment == original.startingEquipment, "Starting equipment should match")
        #expect(decoded.experiencePoints == original.experiencePoints, "Experience points should match")
        #expect(decoded.descriptiveTraits.count == original.descriptiveTraits.count, "Descriptive traits count should match")
        #expect(decoded.maxLevel == 6, "Max level should be 6")
    }
}
