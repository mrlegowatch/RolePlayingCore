//
//  SpeciesTraitsTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/11/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Species Traits Tests")
struct SpeciesTraitsTests {
    
    let decoder = JSONDecoder()
    let configuration: Configuration
    
    init() throws {
        configuration = try Configuration("TestConfiguration", from: .module)
    }
    
    @Test("Decode basic species traits")
    func speciesTraits() async throws {
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
        
        let speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits, configuration: configuration)
        
        #expect(speciesTraits.name == "Human", "name")
        #expect(speciesTraits.plural == "Humans", "plural")
        #expect(speciesTraits.aliases.count == 0, "aliases")
        #expect(speciesTraits.lifespan == 90, "lifespan")
        #expect(speciesTraits.speed == 30, "speed")
    }
    
    @Test("Decode minimum required traits")
    func minimumTraits() async throws {
        let traits = """
            {
                "name": "Giant Human",
                "plural": "Giant Humans",
                "lifespan": 90,
                "speed": 30
            }
            """.data(using: .utf8)!
        
        let speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits, configuration: configuration)
        
        #expect(speciesTraits.name == "Giant Human", "name")
        #expect(speciesTraits.plural == "Giant Humans", "plural")
        #expect(speciesTraits.lifespan == 90, "lifespan")
        #expect(speciesTraits.speed == 30, "speed")
        #expect(speciesTraits.aliases.count == 0, "aliases")
    }
    
    @Test("Decode optional traits like aliases")
    func optionalTraits() async throws {
        let traits = """
            {
                "name": "Small Human",
                "plural": "Small Humans",
                "lifespan": 90,
                "speed": 30,
                "aliases": ["Big Human"]
            }
            """.data(using: .utf8)!
        
        let speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits, configuration: configuration)
        
        #expect(speciesTraits.aliases.count == 1, "aliases count")
    }
    
    @Test("Verify missing required traits cause decode failure", arguments: [
        "{}",
        """
        { "name": "Giant Human" }
        """,
        """
        {
            "plural": "Giant Humans"
        }
        """
    ])
    func missingTraits(json: String) async throws {
        let traits = json.data(using: .utf8)!
        
        #expect(throws: (any Error).self) {
            _ = try decoder.decode(SpeciesTraits.self, from: traits, configuration: configuration)
        }
    }
    
    @Test("Decode species with subspecies")
    func decodingSpeciesTraits() async throws {
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
        
        let speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits, configuration: configuration)
        let subspeciesTraits = try #require(speciesTraits.subspecies.first)
        
        #expect(subspeciesTraits.name == "Subhuman", "name")
        #expect(subspeciesTraits.plural == "Subhumans", "plural")
        #expect(subspeciesTraits.lifespan == 60, "lifespan")
        #expect(subspeciesTraits.speed == 10, "speed")
        #expect(subspeciesTraits.aliases.count == 0, "aliases")
    }
    
    @Test("Subspecies inherit parent traits")
    func subspeciesOverrides() async throws {
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
        
        let speciesTraits = try decoder.decode(SpeciesTraits.self, from: traits, configuration: configuration)
        let subspeciesTraits = try #require(speciesTraits.subspecies.first)
        
        #expect(subspeciesTraits.name == "Folk", "name")
        #expect(subspeciesTraits.plural == "Folks", "plural")
        #expect(subspeciesTraits.lifespan == 90, "lifespan")
        #expect(subspeciesTraits.speed == 30, "speed")
        #expect(subspeciesTraits.aliases.count == 1, "aliases")
        #expect(subspeciesTraits.baseSizes == speciesTraits.baseSizes, "size")
    }
    
    @Test("Encode subspecies traits with blending")
    func encodingSubspeciesTraits() async throws {
        let speciesTraits = SpeciesTraits(name: "Human", plural: "Humans", aliases: [], creatureType: configuration.species.defaultCreatureType, descriptiveTraits: [:], lifespan: 90, darkVision: 0, speed: 45)
        
        let encoder = JSONEncoder()
        
        // Test 1: Subspecies with blended traits
        do {
            var copyOfSpeciesTraits = speciesTraits
            var subspeciesTraits = SpeciesTraits(name: "Subhuman", plural: "Subhumans", creatureType: configuration.species.defaultCreatureType, lifespan: 45, darkVision: 0, speed: 30)
            subspeciesTraits.blendTraits(from: copyOfSpeciesTraits)
            copyOfSpeciesTraits.subspecies.append(subspeciesTraits)
            
            let encoded = try encoder.encode(copyOfSpeciesTraits, configuration: configuration)
            let dictionary = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: Any]
            
            // Confirm species traits
            #expect(dictionary["name"] as? String == "Human", "encoding name")
            #expect(dictionary["plural"] as? String == "Humans", "encoding plural")
            #expect(dictionary["lifespan"] as? Int == 90, "encoding lifespan")
            #expect(dictionary["darkvision"] as? Int == 0, "encoding darkvision")
            #expect(dictionary["speed"] as? Int == 45, "encoding speed")
            
            // Confirm subspecies traits
            let subspecies = try #require(dictionary["subspecies"] as? [[String: Any]])
            let firstSubspecies = try #require(subspecies.first)
            #expect(firstSubspecies["name"] as? String == "Subhuman", "encoding name")
            #expect(firstSubspecies["plural"] as? String == "Subhumans", "encoding plural")
            #expect(firstSubspecies["lifespan"] as? Int == 45, "encoding lifespan")
            #expect(firstSubspecies["darkvision"] == nil, "encoding darkvision should be nil")
            #expect(firstSubspecies["speed"] as? Int == 30, "encoding speed")
        }
        
        // Test 2: Subspecies with different overrides
        do {
            var copyOfSpeciesTraits = speciesTraits
            let subspeciesTraits = SpeciesTraits(name: "Subhuman", plural: "Subhumans", aliases: ["Minions"], creatureType: configuration.species.defaultCreatureType, descriptiveTraits: ["background": "Something"], lifespan: 45, darkVision: 10, speed: 45)
            copyOfSpeciesTraits.subspecies.append(subspeciesTraits)
            
            let encoded = try encoder.encode(copyOfSpeciesTraits, configuration: configuration)
            let dictionary = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: Any]
            
            // Confirm subspecies traits
            let subspecies = try #require(dictionary["subspecies"] as? [[String: Any]])
            let firstSubspecies = try #require(subspecies.first)
            #expect(firstSubspecies["name"] as? String == "Subhuman", "encoding name")
            #expect(firstSubspecies["plural"] as? String == "Subhumans", "encoding plural")
            #expect(firstSubspecies["lifespan"] as? Int == 45, "encoding lifespan")
            #expect(firstSubspecies["darkvision"] as? Int == 10, "encoding darkvision")
            #expect(firstSubspecies["speed"] == nil, "encoding speed should be nil")
        }
    }
}
