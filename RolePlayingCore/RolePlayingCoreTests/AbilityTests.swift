//
//  AbilityTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/8/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

@testable import RolePlayingCore

class AbilityTests: XCTestCase {
    
    func testStringAbbreviation() {
        do {
            let string = "Strength"
            XCTAssertEqual(string.abbreviated, "STR", "Strength abbreviated")
        }
        
        do {
            let string = "a"
            XCTAssertEqual(string.abbreviated, "A", "A abbreviated")
        }
        
        do {
            let empty = ""
            XCTAssertEqual(empty.abbreviated, "", "empty abbreviated")
        }
    }
    
    func testIntScoreModifier() {
        let expectedScores = [-5, -4, -4, -3, -3, -2, -2, -1, -1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10]
        
        for score in 1...30 {
            let expectedScore = expectedScores[score - 1]
            XCTAssertEqual(score.scoreModifier, expectedScore, "score \(score) modifier")
        }
    }
    
    func testAbilityStruct() {
        let strength = Ability("Strength")
        XCTAssertEqual(strength.name, "Strength", "strength name")
        XCTAssertEqual(strength.abbreviated, "STR", "strength name abbreviated")
    }
    
    func testAbilityEquatable() {
        let strength = Ability("Strength")
        XCTAssertTrue(strength == Ability("Strength"), "strength equatable")
    }
    
    func testAbilityHashable() {
        let strength = Ability("Strength")
        let strengthClone = Ability("Strength")
        let intelligence = Ability("Intelligence")
        
        var map: [Ability: Int] = [strength: 12, intelligence: 3]
        map[strengthClone] = 9
        XCTAssertEqual(map[strength], 9, "strength hashable")
    }
    
    func testAbilityEncodable() {
        struct AbilityContainer: Codable {
            let ability = Ability("Strength")
        }
        let abilityScores = AbilityContainer()
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(abilityScores)
            let dictionary = try JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as? [String: String]
            XCTAssertNotNil(dictionary, "serialized strength should be non-nil")
            let strength = dictionary?["ability"]
            XCTAssertEqual(strength, "Strength", "Round-trip for Ability should be Strength")
        }
        catch let error {
            XCTFail("encoding threw an error: \(error)")
        }
    }
    
    func testAbilityDecodable() {
        let traits = """
        {
             "ability": "Strength"
        }
        """.data(using: .utf8)!
        struct AbilityContainer: Decodable {
            let ability: Ability
        }
        
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(AbilityContainer.self, from: traits)
            XCTAssertEqual(decoded.ability.name, "Strength", "decoded ability name")
        }
        catch let error {
            XCTFail("decoding threw an error: \(error)")
        }
    }
    
    func testNonMutableAbilityScores() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")
        
        let abilityScores = AbilityScores([brawn: 9, reflexes: 12, stamina: 15])
        
        XCTAssertEqual(abilityScores.count, 3, "ability scores count")
        XCTAssertEqual(abilityScores[brawn], 9, "ability scores brawn")
        XCTAssertEqual(abilityScores[reflexes], 12, "ability scores reflexes")
        XCTAssertEqual(abilityScores[stamina], 15, "ability scores stamina")
        
        let expectedModifiers = AbilityScores([brawn: -1, reflexes: 1, stamina: 2])
        XCTAssertEqual(abilityScores.modifiers, expectedModifiers, "ability scores modifiers")
    }
    
    func testMutableAbilityScores() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")
        
        var abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
        
        // Change 2 of the 3 scores
        abilityScores[reflexes] = 11
        abilityScores[stamina] = 18
        
        // Verify that 2 of the 3 scores changed
        XCTAssertEqual(abilityScores[brawn], 8, "ability scores reflexes")
        XCTAssertEqual(abilityScores[reflexes], 11, "ability scores reflexes")
        XCTAssertEqual(abilityScores[stamina], 18, "ability scores reflexes")
        
        // Check that modifiers reflect mutated scores
        let expectedModifiers = AbilityScores([brawn: -1, reflexes: 0, stamina: 4])
        XCTAssertEqual(abilityScores.modifiers, expectedModifiers, "ability scores modifiers")
        
        // Verify that a score can't be nil'd out
        abilityScores[stamina] = nil
        XCTAssertEqual(abilityScores[stamina], 18, "ability scores can't be set to nil")
        
        let invalidAbility = Ability("Charm")
        abilityScores[invalidAbility] = 8
        XCTAssertNil(abilityScores[invalidAbility], "invalid ability should not set a score")
    }
    
    func testAbilityScoresDecodable() {
        // Test with implicit [String: Int] as from JSON
        do {
            let traits = """
                {"Strength": 12, "Intelligence": 8}
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            let abilityScores = try? decoder.decode(AbilityScores.self, from: traits)
            XCTAssertNotNil(abilityScores, "ability scores should be non-nil")
            
            let strength = Ability("Strength")
            let intelligence = Ability("Intelligence")
            
            XCTAssertEqual(abilityScores?[strength], 12, "ability scores dictionary strength")
            XCTAssertEqual(abilityScores?[intelligence], 8, "ability scores dictionary intelligence")
        }
    }
    
    func testAbilityScoresEncodable() {
        let abilityScores = AbilityScores([Ability("Brawn"): 12, Ability("Charm"): 3])
        
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(abilityScores)
            let serialized = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String:Int]
            let brawn = serialized?["Brawn"]
            let charm = serialized?["Charm"]
            XCTAssertEqual(brawn, 12, "encoded brawn")
            XCTAssertEqual(charm, 3, "encoded charm")
        }
        catch let error {
            XCTFail("decoding threw an error: \(error)")
        }
    }
    
    func testAbilityScoreKey() {
        // Housekeeping: code coverage for AbilityKey
        do {
            let abilityKey = AbilityScores.AbilityKey(stringValue: "Wisdom")!
            XCTAssertNil(abilityKey.intValue, "AbilityKey does not use intValue")
        }
        
        do {
            let abilityKey = AbilityScores.AbilityKey(intValue: 2)
            XCTAssertNil(abilityKey, "AbilityKey does not use intValue")
        }
    }
    
    func testAddingAbilityScores() {
        // Test adding scores with modifiers using = ... + ...
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
            
            let abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
            let combinedScores = abilityScores + abilityScores.modifiers
            
            XCTAssertEqual(combinedScores[brawn], 7, "adding ability scores brawn")
            XCTAssertEqual(combinedScores[reflexes], 14, "adding ability scores reflexes")
            XCTAssertEqual(combinedScores[stamina], 20, "adding ability scores stamina")
        }
        
        // Test adding one score using += ...
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
            
            var abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
            let oneScore = AbilityScores([reflexes: -3])
            abilityScores += oneScore
            
            XCTAssertEqual(abilityScores[brawn], 8, "adding ability scores brawn")
            XCTAssertEqual(abilityScores[reflexes], 10, "adding ability scores reflexes")
            XCTAssertEqual(abilityScores[stamina], 17, "adding ability scores stamina")
        }

        // Test that adding unrelated scores has no effect
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
            
            let abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
            
            let intelligence = Ability("Intelligence")
            let wisdom = Ability("Wisdom")
            let unrelatedScores = AbilityScores([intelligence: 14, wisdom: 5])
            let combinedScores = abilityScores + unrelatedScores
            
            XCTAssertEqual(combinedScores.count, 3, "adding ability scores count")
            
            XCTAssertEqual(combinedScores[brawn], 8, "adding ability scores brawn")
            XCTAssertEqual(combinedScores[reflexes], 13, "adding ability scores reflexes")
            XCTAssertEqual(combinedScores[stamina], 17, "adding ability scores stamina")
        }
    }
    
    func testSubtractingAbilityScores() {
        // Test adding scores with modifiers using = ... + ...
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
            
            let abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
            let combinedScores = abilityScores - abilityScores.modifiers
            
            XCTAssertEqual(combinedScores[brawn], 9, "adding ability scores brawn")
            XCTAssertEqual(combinedScores[reflexes], 12, "adding ability scores reflexes")
            XCTAssertEqual(combinedScores[stamina], 14, "adding ability scores stamina")
        }
        
        // Test adding one score using += ...
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
            
            var abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
            let oneScore = AbilityScores([reflexes: -3])
            abilityScores -= oneScore
            
            XCTAssertEqual(abilityScores[brawn], 8, "adding ability scores brawn")
            XCTAssertEqual(abilityScores[reflexes], 16, "adding ability scores reflexes")
            XCTAssertEqual(abilityScores[stamina], 17, "adding ability scores stamina")
        }
        
        // Test that adding unrelated scores has no effect
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
            
            let abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
            
            let intelligence = Ability("Intelligence")
            let wisdom = Ability("Wisdom")
            let unrelatedScores = AbilityScores([intelligence: 14, wisdom: 5])
            let combinedScores = abilityScores - unrelatedScores
            
            XCTAssertEqual(combinedScores.count, 3, "adding ability scores count")
            
            XCTAssertEqual(combinedScores[brawn], 8, "adding ability scores brawn")
            XCTAssertEqual(combinedScores[reflexes], 13, "adding ability scores reflexes")
            XCTAssertEqual(combinedScores[stamina], 17, "adding ability scores stamina")
        }
    }
    
    func testDefaultAbilityScores() {
        // Test default ability scores
        do {
            let abilityScores = AbilityScores()
            
            XCTAssertEqual(abilityScores.count, 6, "default ability scores count")
            
            // Test names and values
            let abilityNames = ["Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"]
            for ability in abilityScores.abilities {
                XCTAssertTrue(abilityNames.contains(ability.name), "default ability name")
                XCTAssertEqual(abilityScores[ability], 0, "default ability score 0")
            }
        }
        
        // Test default ability scores with non-default abilities
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")

            let abilityScores = AbilityScores(defaults: [brawn, reflexes, stamina])
            XCTAssertEqual(abilityScores.count, 3, "default ability scores count")
            
            // Test values via keys and values
            for ability in abilityScores.abilities {
                XCTAssertEqual(abilityScores[ability], 0, "default ability score 0")
            }
            for value in abilityScores.values {
                XCTAssertEqual(value, 0, "default ability score 0")
            }
        }
    }
    
}
