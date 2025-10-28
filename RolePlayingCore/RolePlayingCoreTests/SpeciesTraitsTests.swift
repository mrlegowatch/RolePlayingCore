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
                    "lifespan": 90,
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
            XCTAssertEqual(speciesTraits?.aliases.count, 0, "aliases")

            XCTAssertEqual(speciesTraits?.lifespan, 90, "lifespan")
            
            XCTAssertEqual(speciesTraits?.speed, 30, "speed")
        }

        // Test minimum traits
        do {
            let traits = """
                {
                    "name": "Giant Human",
                    "plural": "Giant Humans",
                    "lifespan": 90,
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
            
            XCTAssertEqual(speciesTraits?.lifespan, 90, "lifespan")
            
            XCTAssertEqual(speciesTraits?.speed, 30, "speed")
            
            XCTAssertEqual(speciesTraits?.aliases.count, 0, "aliases")
        }
        
        // Test optional traits
        do {
            let traits = """
                {
                    "name": "Small Human",
                    "plural": "Small Humans",
                    "lifespan": 90,
                    "speed": 30,
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
                "lifespan": 90,
                "speed": 30,
                "subspecies": [
                    {
                        "name": "Subhuman",
                        "plural": "Subhumans",
                        "lifespan": 60,
                        "speed": 10
                    }
                ]
            }
            """.data(using: .utf8)!
            let speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits)
            if let subspeciesTraits = speciesTraits.subspecies.first {
                
                XCTAssertEqual(subspeciesTraits.name, "Subhuman", "name")
                XCTAssertEqual(subspeciesTraits.plural, "Subhumans", "plural")
                
                XCTAssertEqual(subspeciesTraits.lifespan, 60, "lifespan")
                                
                XCTAssertEqual(subspeciesTraits.speed, 10, "speed")
                
                XCTAssertEqual(subspeciesTraits.aliases.count, 0, "aliases")
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
                "lifespan": 90,
                "speed": 30,
                "subspecies": [
                    {
                        "name": "Folk",
                        "plural": "Folks",
                        "aliases": ["Plainfolk"],
                        "darkvision": 20
                    }
                ]
            }
            """.data(using: .utf8)!
            
            let speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits)
            if let subspeciesTraits = speciesTraits.subspecies.first {
            
                XCTAssertNotNil(subspeciesTraits)
                XCTAssertEqual(subspeciesTraits.name, "Folk", "name")
                XCTAssertEqual(subspeciesTraits.plural, "Folks", "plural")
                
                XCTAssertEqual(subspeciesTraits.lifespan, 90, "lifespan")
                                
                XCTAssertEqual(subspeciesTraits.speed, 30, "speed")
                
                XCTAssertEqual(subspeciesTraits.aliases.count, 1, "aliases")
                
                XCTAssertEqual(subspeciesTraits.baseSizes, speciesTraits.baseSizes, "size")
            } else {
                XCTFail("decode failed for traits with subspecies traits")
            }
        }
        catch let error {
            XCTFail("decode failed with error: \(error)")
        }
    }
    
    func testEncodingSubspeciesTraits() {
        let speciesTraits = SpeciesTraits(name: "Human", plural: "Humans", aliases: [], descriptiveTraits: [:], lifespan: 90, darkVision: 0, speed: 45)
        
        let encoder = JSONEncoder()
        
        do {
            var copyOfSpeciesTraits = speciesTraits
            var subspeciesTraits = SpeciesTraits(name: "Subhuman", plural: "Subhumans", lifespan: 45, darkVision: 0, speed: 30)
            subspeciesTraits.blendTraits(from: copyOfSpeciesTraits)
            copyOfSpeciesTraits.subspecies.append(subspeciesTraits)
            
            let encoded = try encoder.encode(copyOfSpeciesTraits)
            let dictionary = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: Any]
            
            // Confirm species traits
            XCTAssertEqual(dictionary["name"] as? String, "Human", "encoding name")
            XCTAssertEqual(dictionary["plural"] as? String, "Humans", "encoding name")
            
            XCTAssertEqual(dictionary["lifespan"] as? Int, 90, "encoding lifespan")
            
            XCTAssertEqual(dictionary["darkvision"] as? Int, 0, "encoding name")
            XCTAssertEqual(dictionary["speed"] as? Int, 45, "encoding name")
            
            // Confirm subspecies traits
            if let subspecies = dictionary["subspecies"] as? [[String: Any]], let firstSubspecies = subspecies.first {
                XCTAssertEqual(firstSubspecies["name"] as? String, "Subhuman", "encoding name")
                XCTAssertEqual(firstSubspecies["plural"] as? String, "Subhumans", "encoding name")
                
                XCTAssertEqual(firstSubspecies["lifespan"] as? Int, 45, "encoding lifespan")
                
                XCTAssertNil(firstSubspecies["darkvision"], "encoding darkvision")
                XCTAssertEqual(firstSubspecies["speed"] as? Int, 30, "encoding speed")
            } else {
                XCTFail("subspecies should be non-nil and contain at least one subspecies")
            }
        }
        catch let error {
            XCTFail("decode failed with error: \(error)")
        }
        
        do {
            var copyOfSpeciesTraits = speciesTraits
            let subspeciesTraits = SpeciesTraits(name: "Subhuman", plural: "Subhumans", aliases: ["Minions"], descriptiveTraits: ["background": "Something"], lifespan: 45, darkVision: 10, speed: 45)
            copyOfSpeciesTraits.subspecies.append(subspeciesTraits)
            
            let encoded = try encoder.encode(copyOfSpeciesTraits)
            let dictionary = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: Any]
            
            // Confirm subspecies traits
            if let subspecies = dictionary["subspecies"] as? [[String: Any]], let firstSubspecies = subspecies.first {
                XCTAssertEqual(firstSubspecies["name"] as? String, "Subhuman", "encoding name")
                XCTAssertEqual(firstSubspecies["plural"] as? String, "Subhumans", "encoding name")
                
                XCTAssertEqual(firstSubspecies["lifespan"] as? Int, 45, "encoding lifespan")
                
                XCTAssertEqual(firstSubspecies["darkvision"] as? Int, 10, "encoding darkvision")
                XCTAssertNil(firstSubspecies["speed"], "encoding speed")
            } else {
                XCTFail("subspecies should be non-nil and contain at least one subspecies")
            }
        }
        catch let error {
            XCTFail("decode failed with error: \(error)")
        }
        
    }
 
}
