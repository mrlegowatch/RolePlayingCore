//
//  SpeciesTraitsTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/11/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class SpeciesTraitsTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    func testSpeciesTraits() {
        // Test typical traits
        do {
            let traits = """
                {
                    "name": "Human",
                    "plural": "Humans",
                    "ability scores": {"Strength": 1, "Dexterity": 1, "Constitution": 1, "Intelligence": 1, "Wisdom": 1, "Charisma": 1},
                    "minimum age": 18,
                    "lifespan": 90,
                    "base height": "4'8\\"",
                    "height modifier": "2d10",
                    "base weight": 110,
                    "weight modifier": "2d4",
                    "speed": 30,
                    "languages": ["Common"],
                    "extra languages": 1
                }
                """.data(using: .utf8)!
            var speciesTraits: SpeciesTraits? = nil
            do {
                speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits)
            }
            catch let error {
                XCTFail("Failed to decode species traits, error: \(error)")
            }
            
            XCTAssertNotNil(speciesTraits)
            XCTAssertEqual(speciesTraits?.name, "Human", "name")
            XCTAssertEqual(speciesTraits?.plural, "Humans", "plural")
            XCTAssertEqual(speciesTraits?.abilityScoreIncrease.count, 6, "ability score increase")
            if let scores = speciesTraits?.abilityScoreIncrease.values {
                for score in scores {
                    XCTAssertEqual(score, 1, "ability score increase")
                }
            }
            
            XCTAssertEqual(speciesTraits?.minimumAge, 18, "minimum age")
            XCTAssertEqual(speciesTraits?.lifespan, 90, "lifespan")
            XCTAssertEqual(speciesTraits?.baseHeight.value ?? 0, 4.666666, accuracy: 0.000001, "base height")
            
            let heightModifier = speciesTraits?.heightModifier as? SimpleDice
            XCTAssertNotNil(heightModifier, "height modifier")
            XCTAssertEqual(heightModifier?.sides, 10, "height modifier")
            XCTAssertEqual(heightModifier?.times, 2, "height modifier")
            
            XCTAssertEqual(speciesTraits?.baseWeight.value ?? 0, 110.0, "base height")

            let weightModifier = speciesTraits?.weightModifier as? SimpleDice
            XCTAssertNotNil(weightModifier, "weight modifier")
            XCTAssertEqual(weightModifier?.sides, 4, "weight modifier")
            XCTAssertEqual(weightModifier?.times, 2, "weight modifier")

            XCTAssertEqual(speciesTraits?.speed, 30, "speed")
            
            XCTAssertEqual(speciesTraits?.aliases.count, 0, "aliases")
            
            XCTAssertEqual(speciesTraits?.size, SpeciesTraits.Size.medium, "size")
            XCTAssertNil(speciesTraits?.alignment, "alignment")
        }

        // Test minimum traits
        do {
            let traits = """
                {
                    "name": "Giant Human",
                    "plural": "Giant Humans",
                    "minimum age": 18,
                    "lifespan": 90,
                    "base height": "7'8\\"",
                    "height modifier": "2d10",
                    "base weight": 110,
                    "speed": 30
                }
                """.data(using: .utf8)!
            var speciesTraits: SpeciesTraits? = nil
            do {
                speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits)
            }
            catch let error {
                XCTFail("Failed to decode species traits, error: \(error)")
            }
            XCTAssertNotNil(speciesTraits)
            XCTAssertEqual(speciesTraits?.name, "Giant Human", "name")
            XCTAssertEqual(speciesTraits?.plural, "Giant Humans", "plural")
            XCTAssertEqual(speciesTraits?.abilityScoreIncrease.count, 6, "ability score increase")
            if let scores = speciesTraits?.abilityScoreIncrease.values {
                for score in scores {
                    XCTAssertEqual(score, 0, "ability score increase")
                }
            }
            
            XCTAssertEqual(speciesTraits?.minimumAge, 18, "minimum age")
            XCTAssertEqual(speciesTraits?.lifespan, 90, "lifespan")
            XCTAssertEqual(speciesTraits?.baseHeight.value ?? 0, 7.666666, accuracy: 0.000001, "base height")
            
            let heightModifier = speciesTraits?.heightModifier as? SimpleDice
            XCTAssertNotNil(heightModifier, "height modifier")
            XCTAssertEqual(heightModifier?.sides, 10, "height modifier")
            XCTAssertEqual(heightModifier?.times, 2, "height modifier")
            
            XCTAssertEqual(speciesTraits?.baseWeight.value ?? 0, 110.0, "base height")
            
            let weightModifier = speciesTraits?.weightModifier as? DiceModifier
            XCTAssertEqual(weightModifier?.modifier, 0, "weight modifier")
            
            XCTAssertEqual(speciesTraits?.speed, 30, "speed")
            
            XCTAssertEqual(speciesTraits?.aliases.count, 0, "aliases")
            XCTAssertNil(speciesTraits?.alignment, "alignment")
            
            XCTAssertEqual(speciesTraits?.size, SpeciesTraits.Size.large, "size")
        }
        
        // Test optional traits
        do {
            let traits = """
                {
                    "name": "Small Human",
                    "plural": "Small Humans",
                    "minimum age": 18,
                    "lifespan": 90,
                    "base height": "2'8\\"",
                    "height modifier": "2d10",
                    "base weight": 110,
                    "speed": 30,
                    "alignment": "Lawful Neutral",
                    "aliases": ["Big Human"]
                }
                """.data(using: .utf8)!
            
            var speciesTraits: SpeciesTraits? = nil
            do {
                speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits)
            }
            catch let error {
                XCTFail("Failed to decode species traits, error: \(error)")
            }
            XCTAssertNotNil(speciesTraits)
            
            XCTAssertEqual(speciesTraits?.size, SpeciesTraits.Size.small, "size")

            XCTAssertNotNil(speciesTraits?.alignment, "alignment should be non-nil")
            let foundAlignment = speciesTraits?.alignment?.kind ?? Alignment(.neutral, .neutral).kind
            XCTAssertEqual(foundAlignment, Alignment(.lawful, .neutral).kind, "alignment kind")
            
            XCTAssertEqual(speciesTraits?.aliases.count, 1, "aliases count")
        }
    }
    
    func testMissingTraits() {

        // Test that each missing trait results in nil
        do {
            let traits = "{}".data(using: .utf8)!
            let speciesTraits = try? decoder.decode(SpeciesTraits.self, from: traits)
            XCTAssertNil(speciesTraits)
        }
        
        do {
            let traits = """
                { "name": "Giant Human" }
                """.data(using: .utf8)!
            let speciesTraits = try? decoder.decode(SpeciesTraits.self, from: traits)
            XCTAssertNil(speciesTraits)
        }
        
        
        do {
            let traits = """
                {
                    "plural": "Giant Humans"
                }
                """.data(using: .utf8)!
            let speciesTraits = try? decoder.decode(SpeciesTraits.self, from: traits)
            XCTAssertNil(speciesTraits)
        }
    }
    
    func testDecodingSpeciesTraits() {
        do {
            let traits = """
            {
                "name": "Human",
                "plural": "Humans",
                "minimum age": 18,
                "lifespan": 90,
                "base height": "4'8\\"",
                "height modifier": "2d10",
                "base weight": 110,
                "speed": 30,
                "subspecies": [
                    {
                        "name": "Subhuman",
                        "plural": "Subhumans",
                        "minimum age": 15,
                        "lifespan": 60,
                        "base height": "2'8\\"",
                        "height modifier": "2d6",
                        "base weight": 45,
                        "speed": 10
                    }
                ]
            }
            """.data(using: .utf8)!
            let speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits)
            if let subspeciesTraits = speciesTraits.subspecies.first {
                
                XCTAssertEqual(subspeciesTraits.name, "Subhuman", "name")
                XCTAssertEqual(subspeciesTraits.plural, "Subhumans", "plural")
                XCTAssertEqual(subspeciesTraits.abilityScoreIncrease.count, 6, "ability score increase")
                for score in subspeciesTraits.abilityScoreIncrease.values {
                    XCTAssertEqual(score, 0, "ability score increase")
                }
                
                XCTAssertEqual(subspeciesTraits.minimumAge, 15, "minimum age")
                XCTAssertEqual(subspeciesTraits.lifespan, 60, "lifespan")
                XCTAssertEqual(subspeciesTraits.baseHeight.value, 2.666666, accuracy: 0.000001, "base height")
                
                let heightModifier = subspeciesTraits.heightModifier as? SimpleDice
                XCTAssertNotNil(heightModifier, "height modifier")
                XCTAssertEqual(heightModifier?.sides, 6, "height modifier")
                XCTAssertEqual(heightModifier?.times, 2, "height modifier")
                
                XCTAssertEqual(subspeciesTraits.baseWeight.value, 45.0, "base height")
                
                let weightModifier = subspeciesTraits.weightModifier as? SimpleDice
                XCTAssertNil(weightModifier, "weight modifier")
                
                XCTAssertEqual(subspeciesTraits.speed, 10, "speed")
                
                XCTAssertEqual(subspeciesTraits.aliases.count, 0, "aliases")
                
                XCTAssertEqual(subspeciesTraits.size, SpeciesTraits.Size.small, "size")
                XCTAssertNil(subspeciesTraits.alignment, "alignment")

                XCTAssertEqual(subspeciesTraits.hitPointBonus, 0, "hit point bonus")

            } else {
                XCTFail("decode failed for traits with subspecies traits")
            }
        }
        catch let error {
            XCTFail("decode failed, error: \(error)")
        }
        
        // Test the other half overrides
        do {
            let traits = """
            {
                "name": "Human",
                "plural": "Humans",
                "minimum age": 18,
                "lifespan": 90,
                "base height": "4'8\\"",
                "height modifier": "2d10",
                "base weight": 110,
                "speed": 30,
                "subspecies": [
                    {
                        "name": "Folk",
                        "plural": "Folks",
                        "aliases": ["Plainfolk"],
                        "weight modifier": "d8",
                        "ability scores": {"Strength": 2, "Dexterity": 1, "Constitution": 3, "Intelligence": 2, "Wisdom": 1, "Charisma": 1},
                        "alignment": "Neutral",
                        "darkvision": 20,
                        "hit point bonus": 2
                    }
                ]
            }
            """.data(using: .utf8)!
            
            let speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits)
            if let subspeciesTraits = speciesTraits.subspecies.first {
            
                XCTAssertNotNil(subspeciesTraits)
                XCTAssertEqual(subspeciesTraits.name, "Folk", "name")
                XCTAssertEqual(subspeciesTraits.plural, "Folks", "plural")
                XCTAssertEqual(subspeciesTraits.abilityScoreIncrease.count, 6, "ability score increase")
                for score in subspeciesTraits.abilityScoreIncrease.values {
                    XCTAssertNotEqual(score, 0, "ability score increase")
                }
                
                XCTAssertEqual(subspeciesTraits.minimumAge, 18, "minimum age")
                XCTAssertEqual(subspeciesTraits.lifespan, 90, "lifespan")
                XCTAssertEqual(subspeciesTraits.baseHeight.value, 4.666666, accuracy: 0.000001, "base height")
                
                let heightModifier = subspeciesTraits.heightModifier as? SimpleDice
                XCTAssertNotNil(heightModifier, "height modifier")
                XCTAssertEqual(heightModifier?.sides, 10, "height modifier")
                XCTAssertEqual(heightModifier?.times, 2, "height modifier")
                
                XCTAssertEqual(subspeciesTraits.baseWeight.value, 110, "base height")
                
                let weightModifier = subspeciesTraits.weightModifier as? SimpleDice
                XCTAssertNotNil(weightModifier, "weight modifier")
                XCTAssertEqual(weightModifier?.sides, 8, "weight modifier")
                XCTAssertEqual(weightModifier?.times, 1, "weight modifier")
                
                XCTAssertEqual(subspeciesTraits.speed, 30, "speed")
                
                XCTAssertEqual(subspeciesTraits.aliases.count, 1, "aliases")
                
                XCTAssertEqual(subspeciesTraits.size, SpeciesTraits.Size.medium, "size")
                XCTAssertNotNil(subspeciesTraits.alignment, "alignment")
                let foundAlignment = subspeciesTraits.alignment?.kind ?? Alignment(.lawful, .good).kind
                XCTAssertEqual(foundAlignment, Alignment(.neutral, .neutral).kind, "alignment kind")

                XCTAssertEqual(subspeciesTraits.hitPointBonus, 2, "hit point bonus")
            } else {
                XCTFail("decode failed for traits with subspecies traits")
            }
        }
        catch let error {
            XCTFail("decode failed with error: \(error)")
        }
    }
    
    func testEncodingSubspeciesTraits() {
        let speciesTraits = SpeciesTraits(name: "Human", plural: "Humans", aliases: [], descriptiveTraits: [:], abilityScoreIncrease: AbilityScores(), minimumAge: 18, lifespan: 90, alignment: Alignment(.lawful, .neutral), baseHeight: "4ft 9 in".parseHeight!, heightModifier: DiceModifier(0), baseWeight: "178 lb".parseWeight!, weightModifier: DiceModifier(0), darkVision: 0, speed: 45, hitPointBonus: 0)
        
        let encoder = JSONEncoder()
        
        do {
            var copyOfSpeciesTraits = speciesTraits
            var subspeciesTraits = SpeciesTraits(name: "Subhuman", plural: "Subhumans", minimumAge: 14, lifespan: 45, baseHeight: "3 ft".parseHeight!, baseWeight: "100 lb".parseWeight!, darkVision: 0, speed: 30)
            subspeciesTraits.blendTraits(from: copyOfSpeciesTraits)
            copyOfSpeciesTraits.subspecies.append(subspeciesTraits)
            
            let encoded = try encoder.encode(copyOfSpeciesTraits)
            let dictionary = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: Any]
            
            // Confirm species traits
            XCTAssertEqual(dictionary["name"] as? String, "Human", "encoding name")
            XCTAssertEqual(dictionary["plural"] as? String, "Humans", "encoding name")
            
            XCTAssertEqual(dictionary["minimum age"] as? Int, 18, "encoding name")
            XCTAssertEqual(dictionary["lifespan"] as? Int, 90, "encoding lifespan")
            XCTAssertEqual(dictionary["alignment"] as? String, "Lawful Neutral", "encoding alignment")
            XCTAssertEqual(dictionary["base height"]! as! String, "4.75 ft", "encoding base height")
            XCTAssertEqual(dictionary["height modifier"] as? String, "0", "encoding height modifier")
            XCTAssertEqual(dictionary["base weight"]! as! String, "178.0 lb", "encoding base weight")
            XCTAssertEqual(dictionary["weight modifier"] as? String, "0", "encoding weight modifier")
            
            XCTAssertEqual(dictionary["darkvision"] as? Int, 0, "encoding name")
            XCTAssertEqual(dictionary["speed"] as? Int, 45, "encoding name")
            XCTAssertEqual(dictionary["hit point bonus"] as? Int, 0, "encoding base height")
            
            // Confirm subspecies traits
            if let subspecies = dictionary["subspecies"] as? [[String: Any]], let firstSubspecies = subspecies.first {
                XCTAssertEqual(firstSubspecies["name"] as? String, "Subhuman", "encoding name")
                XCTAssertEqual(firstSubspecies["plural"] as? String, "Subhumans", "encoding name")
                
                XCTAssertEqual(firstSubspecies["minimum age"] as? Int, 14, "encoding name")
                XCTAssertEqual(firstSubspecies["lifespan"] as? Int, 45, "encoding lifespan")
                XCTAssertNil(firstSubspecies["alignment"], "encoding alignment")
                XCTAssertEqual(firstSubspecies["base height"]! as! String, "3.0 ft", "encoding base height")
                XCTAssertNil(firstSubspecies["height modifier"], "encoding height modifier")
                XCTAssertEqual(firstSubspecies["base weight"]! as! String, "100.0 lb", "encoding base weight")
                XCTAssertNil(firstSubspecies["weight modifier"], "encoding weight modifier")
                
                XCTAssertNil(firstSubspecies["darkvision"], "encoding darkvision")
                XCTAssertEqual(firstSubspecies["speed"] as? Int, 30, "encoding speed")
                XCTAssertNil(firstSubspecies["hit point bonus"], "encoding hit point bonus")
                
            } else {
                XCTFail("subspecies should be non-nil and contain at least one subspecies")
            }
        }
        catch let error {
            XCTFail("decode failed with error: \(error)")
        }
        
        do {
            var copyOfSpeciesTraits = speciesTraits
            let subspeciesTraits = SpeciesTraits(name: "Subhuman", plural: "Subhumans", aliases: ["Minions"], descriptiveTraits: ["background": "Something"], abilityScoreIncrease: AbilityScores([Ability("Strength"): 2]), minimumAge: 14, lifespan: 45, alignment: Alignment(.neutral, .evil), baseHeight: "3 ft".parseHeight!, heightModifier: "d4".parseDice!, baseWeight: "100 lb".parseWeight!, weightModifier: "d6".parseDice!, darkVision: 10, speed: 45, hitPointBonus: 1)
            copyOfSpeciesTraits.subspecies.append(subspeciesTraits)
            
            let encoded = try encoder.encode(copyOfSpeciesTraits)
            let dictionary = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: Any]
            
            // Confirm subspecies traits
            if let subspecies = dictionary["subspecies"] as? [[String: Any]], let firstSubspecies = subspecies.first {
                XCTAssertEqual(firstSubspecies["name"] as? String, "Subhuman", "encoding name")
                XCTAssertEqual(firstSubspecies["plural"] as? String, "Subhumans", "encoding name")
                
                XCTAssertEqual(firstSubspecies["minimum age"] as? Int, 14, "encoding name")
                XCTAssertEqual(firstSubspecies["lifespan"] as? Int, 45, "encoding lifespan")
                XCTAssertEqual(firstSubspecies["alignment"] as? String, "Neutral Evil", "encoding alignment")
                XCTAssertEqual(firstSubspecies["base height"]! as! String, "3.0 ft", "encoding base height")
                XCTAssertEqual(firstSubspecies["height modifier"] as? String, "d4", "encoding height modifier")
                XCTAssertEqual(firstSubspecies["base weight"]! as! String, "100.0 lb", "encoding base weight")
                XCTAssertEqual(firstSubspecies["weight modifier"] as? String, "d6", "encoding weight modifier")
                
                XCTAssertEqual(firstSubspecies["darkvision"] as? Int, 10, "encoding darkvision")
                XCTAssertNil(firstSubspecies["speed"], "encoding speed")
                XCTAssertEqual(firstSubspecies["hit point bonus"] as? Int, 1, "encoding hit point bonus")
            } else {
                XCTFail("subspecies should be non-nil and contain at least one subspecies")
            }
        }
        catch let error {
            XCTFail("decode failed with error: \(error)")
        }
        
    }
 
}
