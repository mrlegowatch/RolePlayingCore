//
//  BackgroundsTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/27/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Backgrounds Tests")
struct BackgroundsTests {
    
    let decoder = JSONDecoder()
    let configuration: Configuration
    
    init() throws {
        configuration = try Configuration("TestConfiguration", from: .module)
    }
    
    @Test("Decode background traits")
    func backgroundTraitsDecoding() async throws {
        // Given: JSON data representing a background
        let jsonData = """
        {
            "name": "Acolyte",
            "ability scores": ["Intelligence", "Wisdom"],
            "feat": "Magic Initiate",
            "skill proficiencies": ["Insight", "Religion"],
            "tool proficiency": "Calligrapher's Supplies",
            "equipment": [["Holy Symbol", "Prayer Book", "Vestments", "10 GP"], ["15 GP"]]
        }
        """.data(using: .utf8)!
        
        // When: Decoding the JSON data with configuration
        let background = try decoder.decode(BackgroundTraits.self, from: jsonData, configuration: configuration)
        
        // Then: The properties should match the input
        #expect(background.name == "Acolyte", "Name should match")
        #expect(background.abilityScores == ["Intelligence", "Wisdom"], "Ability scores should match")
        #expect(background.feat == "Magic Initiate", "Feat should match")
        #expect(background.skillProficiencies.count == 2, "Should have 2 skill proficiencies")
        #expect(background.skillProficiencies.skillNames == ["Insight", "Religion"], "Skill names should match")
        #expect(background.toolProficiency == "Calligrapher's Supplies", "Tool proficiency should match")
        #expect(background.equipment.count == 2, "Should have 2 equipment choices")
        #expect(background.equipment[0] == ["Holy Symbol", "Prayer Book", "Vestments", "10 GP"], "First equipment choice should match")
    }
    
    @Test("Encode background traits with round-trip")
    func backgroundTraitsEncoding() async throws {
        // Given: A BackgroundTraits instance
        let jsonData = """
        {
            "name": "Criminal",
            "ability scores": ["Dexterity", "Intelligence"],
            "feat": "Alert",
            "skill proficiencies": ["Deception", "Stealth"],
            "tool proficiency": "Thieves' Tools",
            "equipment": [["Crowbar", "Dark Clothes", "Thieves' Tools", "16 GP"]]
        }
        """.data(using: .utf8)!
        
        let background = try decoder.decode(BackgroundTraits.self, from: jsonData, configuration: configuration)
        
        // When: Encoding the background back to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let encodedData = try encoder.encode(background, configuration: configuration)
        
        // Then: The encoded data should be decodable and match the original
        let decodedBackground = try decoder.decode(BackgroundTraits.self, from: encodedData, configuration: configuration)
        
        #expect(decodedBackground.name == background.name, "Name should match after round-trip")
        #expect(decodedBackground.abilityScores == background.abilityScores, "Ability scores should match after round-trip")
        #expect(decodedBackground.feat == background.feat, "Feat should match after round-trip")
        #expect(decodedBackground.skillProficiencies.skillNames == background.skillProficiencies.skillNames, "Skills should match after round-trip")
        #expect(decodedBackground.toolProficiency == background.toolProficiency, "Tool proficiency should match after round-trip")
        #expect(decodedBackground.equipment == background.equipment, "Equipment should match after round-trip")
    }
    
    @Test("Decode and query backgrounds collection")
    func backgroundsCollection() async throws {
        // Given: JSON data representing a collection of backgrounds
        let jsonData = """
        {
            "backgrounds": [
                {
                    "name": "Acolyte",
                    "ability scores": ["Intelligence", "Wisdom"],
                    "feat": "Magic Initiate",
                    "skill proficiencies": ["Insight", "Religion"],
                    "tool proficiency": "Calligrapher's Supplies",
                    "equipment": [["Holy Symbol", "Prayer Book", "Vestments", "10 GP"], ["15 GP"]]
                },
                {
                    "name": "Criminal",
                    "ability scores": ["Dexterity", "Intelligence"],
                    "feat": "Alert",
                    "skill proficiencies": ["Deception", "Stealth"],
                    "tool proficiency": "Thieves' Tools",
                    "equipment": [["Crowbar", "Dark Clothes", "Thieves' Tools", "16 GP"]]
                },
                {
                    "name": "Soldier",
                    "ability scores": ["Strength", "Constitution"],
                    "feat": "Savage Attacker",
                    "skill proficiencies": ["Athletics", "Intimidation"],
                    "tool proficiency": "Gaming Set",
                    "equipment": [["Spear", "Shortbow", "20 Arrows", "Quiver", "Uniform", "16 GP"]]
                }
            ]
        }
        """.data(using: .utf8)!
        
        // When: Decoding the JSON data into a Backgrounds collection with configuration
        let backgrounds = try decoder.decode(Backgrounds.self, from: jsonData, configuration: configuration)
        
        // Then: The collection should have the correct count
        #expect(backgrounds.count == 3, "Should have 3 backgrounds")
        
        // Then: The find method should locate backgrounds by name
        let acolyte = try #require(backgrounds.find("Acolyte"))
        #expect(acolyte.name == "Acolyte", "Found background should be Acolyte")
        #expect(acolyte.feat == "Magic Initiate", "Acolyte feat should match")
        
        let criminal = try #require(backgrounds.find("Criminal"))
        #expect(criminal.skillProficiencies.skillNames == ["Deception", "Stealth"], "Criminal skills should match")
        
        // Then: The find method should return nil for non-existent backgrounds
        let nonExistent = backgrounds.find("Wizard")
        #expect(nonExistent == nil, "Should not find non-existent background")
        
        // Then: Subscript access should work correctly
        let firstBackground = try #require(backgrounds[0])
        #expect(firstBackground.name == "Acolyte", "First background should be Acolyte")
        
        let thirdBackground = try #require(backgrounds[2])
        #expect(thirdBackground.name == "Soldier", "Third background should be Soldier")
        
        // Then: Round-trip encoding should preserve data
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let encodedData = try encoder.encode(backgrounds, configuration: configuration)
        let decodedBackgrounds = try decoder.decode(Backgrounds.self, from: encodedData, configuration: configuration)
        
        #expect(decodedBackgrounds.count == backgrounds.count, "Count should match after round-trip")
        #expect(decodedBackgrounds.find("Criminal")?.name == "Criminal", "Should find Criminal after round-trip")
        #expect(decodedBackgrounds[1]?.toolProficiency == backgrounds[1]?.toolProficiency, "Tool proficiency should match after round-trip")
    }
}
