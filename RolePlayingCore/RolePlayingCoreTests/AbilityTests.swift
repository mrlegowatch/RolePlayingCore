//
//  AbilityTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/8/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

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
        // Test ability struct and equatable
        do {
            let strength = Ability("Strength")
            XCTAssertEqual(strength.name, "Strength", "strength name")
            XCTAssertEqual(strength.abbreviated, "STR", "strength abbreviated")
            XCTAssertTrue(strength == Ability("Strength"), "strength equatable")
        }
        
        // Test ability hashable
        do {
            let strength = Ability("Strength")
            let strengthClone = Ability("Strength")
            let intelligence = Ability("Intelligence")

            var map: [Ability: Int] = [strength: 12, intelligence: 3]
            map[strengthClone] = 9
            XCTAssertEqual(map[strength], 9, "strength hashable")
        }
    }
    
    func testAbilityScores() {
        // Test non-mutable scores
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
        
            let abilityScores = Ability.Scores(values: [brawn: 9, reflexes: 12, stamina: 15])
            
            XCTAssertEqual(abilityScores.count, 3, "ability scores count")
            XCTAssertEqual(abilityScores[brawn], 9, "ability scores brawn")
            XCTAssertEqual(abilityScores[reflexes], 12, "ability scores reflexes")
            XCTAssertEqual(abilityScores[stamina], 15, "ability scores stamina")
            
            let expectedModifiers = Ability.Scores(values: [brawn: -1, reflexes: 1, stamina: 2])
            XCTAssertEqual(abilityScores.modifiers, expectedModifiers, "ability scores modifiers")
        }

        // Test mutable scores
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
            
            var abilityScores = Ability.Scores(values: [brawn: 8, reflexes: 13, stamina: 17])
            
            // Change 2 of the 3 scores
            abilityScores[reflexes] = 11
            abilityScores[stamina] = 18
            
            // Verify that 2 of the 3 scores changed
            XCTAssertEqual(abilityScores[brawn], 8, "ability scores reflexes")
            XCTAssertEqual(abilityScores[reflexes], 11, "ability scores reflexes")
            XCTAssertEqual(abilityScores[stamina], 18, "ability scores reflexes")
            
            // Check that modifiers reflect mutated scores
            let expectedModifiers = Ability.Scores(values: [brawn: -1, reflexes: 0, stamina: 4])
            XCTAssertEqual(abilityScores.modifiers, expectedModifiers, "ability scores modifiers")
            
            // Verify that a score can't be nil'd out
            abilityScores[stamina] = nil
            XCTAssertEqual(abilityScores[stamina], 18, "ability scores can't be set to nil")
            
            let invalidAbility = Ability("Charm")
            abilityScores[invalidAbility] = 8
            XCTAssertNil(abilityScores[invalidAbility], "invalid ability should not set a score")
        }
    }
    
    func testAbilityScoresFromDictionary() {
        // Test with implicit [String: Int] as from JSON
        do {
            let traits = ["Strength": 12, "Intelligence": 8]
            let abilityScores = Ability.Scores(from: traits)
            
            let strength = Ability("Strength")
            let intelligence = Ability("Intelligence")
            
            XCTAssertEqual(abilityScores[strength], 12, "ability scores dictionary strength")
            XCTAssertEqual(abilityScores[intelligence], 8, "ability scores dictionary intelligence")
        }
        
        // Test with [String: NSNumber] as from NSDictionary or plist
        do {
            let traits: NSDictionary = ["Wisdom": NSNumber(value: 8), "Charisma": NSNumber(value: 13)]
            let abilityScores = Ability.Scores(from: traits as! [String: Int])
            
            let wisdom = Ability("Wisdom")
            let charisma = Ability("Charisma")
            
            XCTAssertEqual(abilityScores[wisdom], 8, "ability scores dictionary wisdom")
            XCTAssertEqual(abilityScores[charisma], 13, "ability scores dictionary charisma")
        }
    }
    
    func testAddingAbilityScores() {
        // Test adding scores with modifiers
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
            
            let abilityScores = Ability.Scores(values: [brawn: 8, reflexes: 13, stamina: 17])
            let combinedScores = abilityScores + abilityScores.modifiers
            
            XCTAssertEqual(combinedScores[brawn], 7, "adding ability scores brawn")
            XCTAssertEqual(combinedScores[reflexes], 14, "adding ability scores reflexes")
            XCTAssertEqual(combinedScores[stamina], 20, "adding ability scores stamina")
        }
        
        // Test adding one score
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
            
            let abilityScores = Ability.Scores(values: [brawn: 8, reflexes: 13, stamina: 17])
            let oneScore = Ability.Scores(values: [reflexes: -3])
            let combinedScores = abilityScores + oneScore
            
            XCTAssertEqual(combinedScores[brawn], 8, "adding ability scores brawn")
            XCTAssertEqual(combinedScores[reflexes], 10, "adding ability scores reflexes")
            XCTAssertEqual(combinedScores[stamina], 17, "adding ability scores stamina")
        }

        // Test that adding unrelated scores has no effect
        do {
            let brawn = Ability("Brawn")
            let reflexes = Ability("Reflexes")
            let stamina = Ability("Stamina")
            
            let abilityScores = Ability.Scores(values: [brawn: 8, reflexes: 13, stamina: 17])
            
            let intelligence = Ability("Intelligence")
            let wisdom = Ability("Wisdom")
            let unrelatedScores = Ability.Scores(values: [intelligence: 14, wisdom: 5])
            let combinedScores = abilityScores + unrelatedScores
            
            XCTAssertEqual(combinedScores.count, 3, "adding ability scores count")
            
            XCTAssertEqual(combinedScores[brawn], 8, "adding ability scores brawn")
            XCTAssertEqual(combinedScores[reflexes], 13, "adding ability scores reflexes")
            XCTAssertEqual(combinedScores[stamina], 17, "adding ability scores stamina")
            
        }
    }
    
    func testDefaultAbilityScores() {
        // Test default ability scores
        do {
            let abilityScores = Ability.Scores()
            
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

            let abilityScores = Ability.Scores(defaults: [brawn, reflexes, stamina])
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
