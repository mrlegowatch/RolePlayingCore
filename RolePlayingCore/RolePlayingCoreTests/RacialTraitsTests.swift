//
//  RacialTraitsTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/11/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class RacialTraitsTests: XCTestCase {
    
    let decoder = JSONDecoder()
    
    func testRacialTraits() {
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
            var racialTraits: RacialTraits? = nil
            do {
                racialTraits = try decoder.decode(RacialTraits.self, from: traits)
            }
            catch let error {
                XCTFail("Failed to decode racial traits, error: \(error)")
            }
            
            XCTAssertNotNil(racialTraits)
            XCTAssertEqual(racialTraits?.name, "Human", "name")
            XCTAssertEqual(racialTraits?.plural, "Humans", "plural")
            XCTAssertEqual(racialTraits?.abilityScoreIncrease.count, 6, "ability score increase")
            if let scores = racialTraits?.abilityScoreIncrease.values {
                for score in scores {
                    XCTAssertEqual(score, 1, "ability score increase")
                }
            }
            
            XCTAssertEqual(racialTraits?.minimumAge, 18, "minimum age")
            XCTAssertEqual(racialTraits?.lifespan, 90, "lifespan")
            XCTAssertEqual(racialTraits?.baseHeight.value ?? 0, 4.666666, accuracy: 0.000001, "base height")
            
            let heightModifier = racialTraits?.heightModifier as? SimpleDice
            XCTAssertNotNil(heightModifier, "height modifier")
            XCTAssertEqual(heightModifier?.sides, 10, "height modifier")
            XCTAssertEqual(heightModifier?.times, 2, "height modifier")
            
            XCTAssertEqual(racialTraits?.baseWeight.value ?? 0, 110.0, "base height")

            let weightModifier = racialTraits?.weightModifier as? SimpleDice
            XCTAssertNotNil(weightModifier, "weight modifier")
            XCTAssertEqual(weightModifier?.sides, 4, "weight modifier")
            XCTAssertEqual(weightModifier?.times, 2, "weight modifier")

            XCTAssertEqual(racialTraits?.speed, 30, "speed")
            
            XCTAssertEqual(racialTraits?.aliases.count, 0, "aliases")
            
            XCTAssertEqual(racialTraits?.size, RacialTraits.Size.medium, "size")
            XCTAssertNil(racialTraits?.alignment, "alignment")
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
            var racialTraits: RacialTraits? = nil
            do {
                racialTraits = try decoder.decode(RacialTraits.self, from: traits)
            }
            catch let error {
                XCTFail("Failed to decode racial traits, error: \(error)")
            }
            XCTAssertNotNil(racialTraits)
            XCTAssertEqual(racialTraits?.name, "Giant Human", "name")
            XCTAssertEqual(racialTraits?.plural, "Giant Humans", "plural")
            XCTAssertEqual(racialTraits?.abilityScoreIncrease.count, 6, "ability score increase")
            if let scores = racialTraits?.abilityScoreIncrease.values {
                for score in scores {
                    XCTAssertEqual(score, 0, "ability score increase")
                }
            }
            
            XCTAssertEqual(racialTraits?.minimumAge, 18, "minimum age")
            XCTAssertEqual(racialTraits?.lifespan, 90, "lifespan")
            XCTAssertEqual(racialTraits?.baseHeight.value ?? 0, 7.666666, accuracy: 0.000001, "base height")
            
            let heightModifier = racialTraits?.heightModifier as? SimpleDice
            XCTAssertNotNil(heightModifier, "height modifier")
            XCTAssertEqual(heightModifier?.sides, 10, "height modifier")
            XCTAssertEqual(heightModifier?.times, 2, "height modifier")
            
            XCTAssertEqual(racialTraits?.baseWeight.value ?? 0, 110.0, "base height")
            
            let weightModifier = racialTraits?.weightModifier as? DiceModifier
            XCTAssertEqual(weightModifier?.modifier, 0, "weight modifier")
            
            XCTAssertEqual(racialTraits?.speed, 30, "speed")
            
            XCTAssertEqual(racialTraits?.aliases.count, 0, "aliases")
            XCTAssertNil(racialTraits?.alignment, "alignment")
            
            XCTAssertEqual(racialTraits?.size, RacialTraits.Size.large, "size")
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
            
            var racialTraits: RacialTraits? = nil
            do {
                racialTraits = try decoder.decode(RacialTraits.self, from: traits)
            }
            catch let error {
                XCTFail("Failed to decode racial traits, error: \(error)")
            }
            XCTAssertNotNil(racialTraits)
            
            XCTAssertEqual(racialTraits?.size, RacialTraits.Size.small, "size")

            XCTAssertNotNil(racialTraits?.alignment, "alignment should be non-nil")
            let foundAlignment = racialTraits?.alignment?.kind ?? Alignment(.neutral, .neutral).kind
            XCTAssertEqual(foundAlignment, Alignment(.lawful, .neutral).kind, "alignment kind")
            
            XCTAssertEqual(racialTraits?.aliases.count, 1, "aliases count")
        }
    }
    
    func testMissingTraits() {

        // Test that each missing trait results in nil
        do {
            let traits = "{}".data(using: .utf8)!
            let racialTraits = try? decoder.decode(RacialTraits.self, from: traits)
            XCTAssertNil(racialTraits)
        }
        
        do {
            let traits = """
                { "name": "Giant Human" }
                """.data(using: .utf8)!
            let racialTraits = try? decoder.decode(RacialTraits.self, from: traits)
            XCTAssertNil(racialTraits)
        }
        
        
        do {
            let traits = """
                {
                    "plural": "Giant Humans"
                }
                """.data(using: .utf8)!
            let racialTraits = try? decoder.decode(RacialTraits.self, from: traits)
            XCTAssertNil(racialTraits)
        }
    }
    
    func testDecodingRacialTraits() {
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
                "subraces": [
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
            let racialTraits = try decoder.decode(RacialTraits.self, from: traits)
            if let subracialTraits = racialTraits.subraces.first {
                
                XCTAssertEqual(subracialTraits.name, "Subhuman", "name")
                XCTAssertEqual(subracialTraits.plural, "Subhumans", "plural")
                XCTAssertEqual(subracialTraits.abilityScoreIncrease.count, 6, "ability score increase")
                for score in subracialTraits.abilityScoreIncrease.values {
                    XCTAssertEqual(score, 0, "ability score increase")
                }
                
                XCTAssertEqual(subracialTraits.minimumAge, 15, "minimum age")
                XCTAssertEqual(subracialTraits.lifespan, 60, "lifespan")
                XCTAssertEqual(subracialTraits.baseHeight.value, 2.666666, accuracy: 0.000001, "base height")
                
                let heightModifier = subracialTraits.heightModifier as? SimpleDice
                XCTAssertNotNil(heightModifier, "height modifier")
                XCTAssertEqual(heightModifier?.sides, 6, "height modifier")
                XCTAssertEqual(heightModifier?.times, 2, "height modifier")
                
                XCTAssertEqual(subracialTraits.baseWeight.value, 45.0, "base height")
                
                let weightModifier = subracialTraits.weightModifier as? SimpleDice
                XCTAssertNil(weightModifier, "weight modifier")
                
                XCTAssertEqual(subracialTraits.speed, 10, "speed")
                
                XCTAssertEqual(subracialTraits.aliases.count, 0, "aliases")
                
                XCTAssertEqual(subracialTraits.size, RacialTraits.Size.small, "size")
                XCTAssertNil(subracialTraits.alignment, "alignment")

                XCTAssertEqual(subracialTraits.hitPointBonus, 0, "hit point bonus")

            } else {
                XCTFail("decode failed for traits with subtrace traits")
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
                "subraces": [
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
            
            let racialTraits = try decoder.decode(RacialTraits.self, from: traits)
            if let subracialTraits = racialTraits.subraces.first {
            
                XCTAssertNotNil(subracialTraits)
                XCTAssertEqual(subracialTraits.name, "Folk", "name")
                XCTAssertEqual(subracialTraits.plural, "Folks", "plural")
                XCTAssertEqual(subracialTraits.abilityScoreIncrease.count, 6, "ability score increase")
                for score in subracialTraits.abilityScoreIncrease.values {
                    XCTAssertNotEqual(score, 0, "ability score increase")
                }
                
                XCTAssertEqual(subracialTraits.minimumAge, 18, "minimum age")
                XCTAssertEqual(subracialTraits.lifespan, 90, "lifespan")
                XCTAssertEqual(subracialTraits.baseHeight.value, 4.666666, accuracy: 0.000001, "base height")
                
                let heightModifier = subracialTraits.heightModifier as? SimpleDice
                XCTAssertNotNil(heightModifier, "height modifier")
                XCTAssertEqual(heightModifier?.sides, 10, "height modifier")
                XCTAssertEqual(heightModifier?.times, 2, "height modifier")
                
                XCTAssertEqual(subracialTraits.baseWeight.value, 110, "base height")
                
                let weightModifier = subracialTraits.weightModifier as? SimpleDice
                XCTAssertNotNil(weightModifier, "weight modifier")
                XCTAssertEqual(weightModifier?.sides, 8, "weight modifier")
                XCTAssertEqual(weightModifier?.times, 1, "weight modifier")
                
                XCTAssertEqual(subracialTraits.speed, 30, "speed")
                
                XCTAssertEqual(subracialTraits.aliases.count, 1, "aliases")
                
                XCTAssertEqual(subracialTraits.size, RacialTraits.Size.medium, "size")
                XCTAssertNotNil(subracialTraits.alignment, "alignment")
                let foundAlignment = subracialTraits.alignment?.kind ?? Alignment(.lawful, .good).kind
                XCTAssertEqual(foundAlignment, Alignment(.neutral, .neutral).kind, "alignment kind")

                XCTAssertEqual(subracialTraits.hitPointBonus, 2, "hit point bonus")
            } else {
                XCTFail("decode failed for traits with subtrace traits")
            }
        }
        catch let error {
            XCTFail("decode failed with error: \(error)")
        }
    }
    
    func testEncodingSubraceTraits() {
        let racialTraits = RacialTraits(name: "Human", plural: "Humans", aliases: [], descriptiveTraits: [:], abilityScoreIncrease: AbilityScores(), minimumAge: 18, lifespan: 90, alignment: Alignment(.lawful, .neutral), baseHeight: "4ft 9 in".parseHeight!, heightModifier: DiceModifier(0), baseWeight: "178 lb".parseWeight!, weightModifier: DiceModifier(0), darkVision: 0, speed: 45, hitPointBonus: 0)
        
        let encoder = JSONEncoder()
        
        do {
            var copyOfRacialTraits = racialTraits
            var subracialTraits = RacialTraits(name: "Subhuman", plural: "Subhumans", minimumAge: 14, lifespan: 45, baseHeight: "3 ft".parseHeight!, baseWeight: "100 lb".parseWeight!, darkVision: 0, speed: 30)
            subracialTraits.blendTraits(from: copyOfRacialTraits)
            copyOfRacialTraits.subraces.append(subracialTraits)
            
            let encoded = try encoder.encode(copyOfRacialTraits)
            let dictionary = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: Any]
            
            // Confirm racial traits
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
            
            // Confirm subracial traits
            if let subraces = dictionary["subraces"] as? [[String: Any]], let subrace = subraces.first {
                XCTAssertEqual(subrace["name"] as? String, "Subhuman", "encoding name")
                XCTAssertEqual(subrace["plural"] as? String, "Subhumans", "encoding name")
                
                XCTAssertEqual(subrace["minimum age"] as? Int, 14, "encoding name")
                XCTAssertEqual(subrace["lifespan"] as? Int, 45, "encoding lifespan")
                XCTAssertNil(subrace["alignment"], "encoding alignment")
                XCTAssertEqual(subrace["base height"]! as! String, "3.0 ft", "encoding base height")
                XCTAssertNil(subrace["height modifier"], "encoding height modifier")
                XCTAssertEqual(subrace["base weight"]! as! String, "100.0 lb", "encoding base weight")
                XCTAssertNil(subrace["weight modifier"], "encoding weight modifier")
                
                XCTAssertNil(subrace["darkvision"], "encoding darkvision")
                XCTAssertEqual(subrace["speed"] as? Int, 30, "encoding speed")
                XCTAssertNil(subrace["hit point bonus"], "encoding hit point bonus")
                
            } else {
                XCTFail("subraces should be non-nil and contain at least one subrace")
            }
        }
        catch let error {
            XCTFail("decode failed with error: \(error)")
        }
        
        do {
            var copyOfRacialTraits = racialTraits
            let subracialTraits = RacialTraits(name: "Subhuman", plural: "Subhumans", aliases: ["Minions"], descriptiveTraits: ["background": "Something"], abilityScoreIncrease: AbilityScores([Ability("Strength"): 2]), minimumAge: 14, lifespan: 45, alignment: Alignment(.neutral, .evil), baseHeight: "3 ft".parseHeight!, heightModifier: "d4".parseDice!, baseWeight: "100 lb".parseWeight!, weightModifier: "d6".parseDice!, darkVision: 10, speed: 45, hitPointBonus: 1)
            copyOfRacialTraits.subraces.append(subracialTraits)
            
            let encoded = try encoder.encode(copyOfRacialTraits)
            let dictionary = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: Any]
            
            // Confirm subracial traits
            if let subraces = dictionary["subraces"] as? [[String: Any]], let subrace = subraces.first {
                XCTAssertEqual(subrace["name"] as? String, "Subhuman", "encoding name")
                XCTAssertEqual(subrace["plural"] as? String, "Subhumans", "encoding name")
                
                XCTAssertEqual(subrace["minimum age"] as? Int, 14, "encoding name")
                XCTAssertEqual(subrace["lifespan"] as? Int, 45, "encoding lifespan")
                XCTAssertEqual(subrace["alignment"] as? String, "Neutral Evil", "encoding alignment")
                XCTAssertEqual(subrace["base height"]! as! String, "3.0 ft", "encoding base height")
                XCTAssertEqual(subrace["height modifier"] as? String, "d4", "encoding height modifier")
                XCTAssertEqual(subrace["base weight"]! as! String, "100.0 lb", "encoding base weight")
                XCTAssertEqual(subrace["weight modifier"] as? String, "d6", "encoding weight modifier")
                
                XCTAssertEqual(subrace["darkvision"] as? Int, 10, "encoding darkvision")
                XCTAssertNil(subrace["speed"], "encoding speed")
                XCTAssertEqual(subrace["hit point bonus"] as? Int, 1, "encoding hit point bonus")
                
            } else {
                XCTFail("subraces should be non-nil and contain at least one subrace")
            }
            
            
        }
        catch let error {
            XCTFail("decode failed with error: \(error)")
        }
        
    }
 
}
