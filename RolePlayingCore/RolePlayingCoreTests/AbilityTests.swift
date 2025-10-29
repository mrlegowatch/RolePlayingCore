//
//  AbilityTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/8/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing

@testable import RolePlayingCore

@Suite("Ability Tests")
struct AbilityTests {
    
    @Test("String abbreviation")
    func stringAbbreviation() {
        let strength = "Strength"
        #expect(strength.abbreviated == "STR", "Strength abbreviated")

        let lettera = "a"
        #expect(lettera.abbreviated == "A", "A abbreviated")
   
        let empty = ""
        #expect(empty.abbreviated == "", "empty abbreviated")
    }
    
    @Test("Int score modifier")
    func intScoreModifier() {
        let expectedScores = [-5, -4, -4, -3, -3, -2, -2, -1, -1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10]
        
        for score in 1...30 {
            let expectedScore = expectedScores[score - 1]
            #expect(score.scoreModifier == expectedScore, "score \(score) modifier")
        }
    }
    
    @Test("Ability struct")
    func abilityStruct() {
        let strength = Ability("Strength")
        #expect(strength.name == "Strength", "strength name")
        #expect(strength.abbreviated == "STR", "strength name abbreviated")
    }
    
    @Test("Ability equatable")
    func abilityEquatable() {
        let strength = Ability("Strength")
        #expect(strength == Ability("Strength"), "strength equatable")
        #expect(strength != Ability("Intelligence"), "intelligence not equal to strength")
    }
    
    @Test("Ability hashable")
    func abilityHashable() {
        let strength = Ability("Strength")
        let strengthClone = Ability("Strength")
        let intelligence = Ability("Intelligence")
        
        var map: [Ability: Int] = [strength: 12, intelligence: 3]
        map[strengthClone] = 9
        #expect(map[strength] == 9, "strength hashable")
    }
    
    @Test("Ability encodable")
    func abilityEncodable() throws {
        struct AbilityContainer: Codable {
            let ability: Ability
        }
        let abilityScores = AbilityContainer(ability: Ability("Strength"))
        let encoder = JSONEncoder()
        
        let encoded = try encoder.encode(abilityScores)
        let dictionary = try JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as? [String: String]
        let unwrappedDictionary = try #require(dictionary, "serialized strength should be non-nil")
        let strength = unwrappedDictionary["ability"]
        #expect(strength == "Strength", "Round-trip for Ability should be Strength")
    }
    
    @Test("Ability decodable")
    func abilityDecodable() throws {
        let traits = """
        {
             "ability": "Strength"
        }
        """.data(using: .utf8)!
        struct AbilityContainer: Decodable {
            let ability: Ability
        }
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AbilityContainer.self, from: traits)
        #expect(decoded.ability.name == "Strength", "decoded ability name")
    }
    
    @Test("Non-mutable ability scores")
    func nonMutableAbilityScores() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")
        
        let abilityScores = AbilityScores([brawn: 9, reflexes: 12, stamina: 15])
        
        #expect(abilityScores.count == 3, "ability scores count")
        #expect(abilityScores[brawn] == 9, "ability scores brawn")
        #expect(abilityScores[reflexes] == 12, "ability scores reflexes")
        #expect(abilityScores[stamina] == 15, "ability scores stamina")
        
        let expectedModifiers = AbilityScores([brawn: -1, reflexes: 1, stamina: 2])
        #expect(abilityScores.modifiers == expectedModifiers, "ability scores modifiers")
    }
    
    @Test("Mutable ability scores")
    func mutableAbilityScores() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")
        
        var abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
        
        // Change 2 of the 3 scores
        abilityScores[reflexes] = 11
        abilityScores[stamina] = 18
        
        // Verify that 2 of the 3 scores changed
        #expect(abilityScores[brawn] == 8, "ability scores reflexes")
        #expect(abilityScores[reflexes] == 11, "ability scores reflexes")
        #expect(abilityScores[stamina] == 18, "ability scores reflexes")
        
        // Check that modifiers reflect mutated scores
        let expectedModifiers = AbilityScores([brawn: -1, reflexes: 0, stamina: 4])
        #expect(abilityScores.modifiers == expectedModifiers, "ability scores modifiers")
        
        // Verify that a score can't be nil'd out
        abilityScores[stamina] = nil
        #expect(abilityScores[stamina] == 18, "ability scores can't be set to nil")
        
        let invalidAbility = Ability("Charm")
        abilityScores[invalidAbility] = 8
        #expect(abilityScores[invalidAbility] == nil, "invalid ability should not set a score")
    }
    
    @Test("Ability scores decodable")
    func abilityScoresDecodable() throws {
        // Test with implicit [String: Int] as from JSON
        let traits = """
            {"Strength": 12, "Intelligence": 8}
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let abilityScores = try? decoder.decode(AbilityScores.self, from: traits)
        let unwrappedAbilityScores = try #require(abilityScores, "ability scores should be non-nil")
        
        let strength = Ability("Strength")
        let intelligence = Ability("Intelligence")
        
        #expect(unwrappedAbilityScores[strength] == 12, "ability scores dictionary strength")
        #expect(unwrappedAbilityScores[intelligence] == 8, "ability scores dictionary intelligence")
    }
    
    @Test("Ability scores encodable")
    func abilityScoresEncodable() throws {
        let abilityScores = AbilityScores([Ability("Brawn"): 12, Ability("Charm"): 3])
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(abilityScores)
        let serialized = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String:Int]
        let brawn = serialized?["Brawn"]
        let charm = serialized?["Charm"]
        #expect(brawn == 12, "encoded brawn")
        #expect(charm == 3, "encoded charm")
    }
    
    @Test("Ability score key")
    func abilityScoreKey() {
        // Housekeeping: code coverage for AbilityKey
        let wisdomKey = AbilityScores.AbilityKey(stringValue: "Wisdom")!
        #expect(wisdomKey.intValue == nil, "AbilityKey does not use intValue")

        let intKey = AbilityScores.AbilityKey(intValue: 2)
        #expect(intKey == nil, "AbilityKey does not use intValue")
    }
    
    @Test("Adding modifiers")
    func addingModifiers() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")
        
        let abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
        let combinedScores = abilityScores + abilityScores.modifiers
        
        #expect(combinedScores[brawn] == 7, "adding ability scores brawn")
        #expect(combinedScores[reflexes] == 14, "adding ability scores reflexes")
        #expect(combinedScores[stamina] == 20, "adding ability scores stamina")
    }
    
    @Test("Adding one score")
    func addingOneScore() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")
        
        var abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
        let oneScore = AbilityScores([reflexes: -3])
        abilityScores += oneScore
        
        #expect(abilityScores[brawn] == 8, "adding ability scores brawn")
        #expect(abilityScores[reflexes] == 10, "adding ability scores reflexes")
        #expect(abilityScores[stamina] == 17, "adding ability scores stamina")
    }
    
    @Test("Adding unrelated scores")
    func addingUnrelatedScores() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")
        
        let abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
        
        let intelligence = Ability("Intelligence")
        let wisdom = Ability("Wisdom")
        let unrelatedScores = AbilityScores([intelligence: 14, wisdom: 5])
        let combinedScores = abilityScores + unrelatedScores
        
        #expect(combinedScores.count == 3, "adding ability scores count")
        
        #expect(combinedScores[brawn] == 8, "adding ability scores brawn")
        #expect(combinedScores[reflexes] == 13, "adding ability scores reflexes")
        #expect(combinedScores[stamina] == 17, "adding ability scores stamina")
    }
    
    @Test("Subtracting ability scores")
    func subtractingAbilityScores() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")
        
        let abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
        let combinedScores = abilityScores - abilityScores.modifiers
        
        #expect(combinedScores[brawn] == 9, "adding ability scores brawn")
        #expect(combinedScores[reflexes] == 12, "adding ability scores reflexes")
        #expect(combinedScores[stamina] == 14, "adding ability scores stamina")
    }
    
    @Test("Subtracting one score")
    func subtractingOneScore() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")
        
        var abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
        let oneScore = AbilityScores([reflexes: -3])
        abilityScores -= oneScore
        
        #expect(abilityScores[brawn] == 8, "adding ability scores brawn")
        #expect(abilityScores[reflexes] == 16, "adding ability scores reflexes")
        #expect(abilityScores[stamina] == 17, "adding ability scores stamina")
    }
        
    @Test("Subtracting unrelated scores")
    func subtractingUnrelatedScores() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")
        
        let abilityScores = AbilityScores([brawn: 8, reflexes: 13, stamina: 17])
        
        let intelligence = Ability("Intelligence")
        let wisdom = Ability("Wisdom")
        let unrelatedScores = AbilityScores([intelligence: 14, wisdom: 5])
        let combinedScores = abilityScores - unrelatedScores
        
        #expect(combinedScores.count == 3, "adding ability scores count")
        
        #expect(combinedScores[brawn] == 8, "adding ability scores brawn")
        #expect(combinedScores[reflexes] == 13, "adding ability scores reflexes")
        #expect(combinedScores[stamina] == 17, "adding ability scores stamina")
    }
    
    @Test("Default ability scores")
    func defaultAbilityScores() {
        let abilityScores = AbilityScores()
        
        #expect(abilityScores.count == 6, "default ability scores count")
        
        // Test names and values
        let abilityNames = ["Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"]
        for ability in abilityScores.abilities {
            #expect(abilityNames.contains(ability.name), "default ability name")
            #expect(abilityScores[ability] == 0, "default ability score 0")
        }
    }
    
    @Test("Non-default ability scores")
    func nonDefaultAbilityScores() {
        let brawn = Ability("Brawn")
        let reflexes = Ability("Reflexes")
        let stamina = Ability("Stamina")

        let abilityScores = AbilityScores(defaults: [brawn, reflexes, stamina])
        #expect(abilityScores.count == 3, "default ability scores count")
        
        // Test values via keys and values
        for ability in abilityScores.abilities {
            #expect(abilityScores[ability] == 0, "default ability score 0")
        }
        for value in abilityScores.values {
            #expect(value == 0, "default ability score 0")
        }
    }
}
