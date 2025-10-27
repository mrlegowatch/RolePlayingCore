//
//  BackgroundsTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/27/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import XCTest
import RolePlayingCore

class BackgroundsTests: XCTestCase {
    
    func testBackgroundTraitsDecoding() throws {
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
        
        let decoder = JSONDecoder()
        
        // When: Decoding the JSON data
        let background = try decoder.decode(BackgroundTraits.self, from: jsonData)
        
        // Then: The properties should match the input
        XCTAssertEqual(background.name, "Acolyte", "Name should match")
        XCTAssertEqual(background.abilityScores, ["Intelligence", "Wisdom"], "Ability scores should match")
        XCTAssertEqual(background.feat, "Magic Initiate", "Feat should match")
        XCTAssertEqual(background.skillProficiencies.count, 2, "Should have 2 skill proficiencies")
        XCTAssertEqual(background.skillProficiencies.skillNames, ["Insight", "Religion"], "Skill names should match")
        XCTAssertEqual(background.toolProficiency, "Calligrapher's Supplies", "Tool proficiency should match")
        XCTAssertEqual(background.equipment.count, 2, "Should have 2 equipment choices")
        XCTAssertEqual(background.equipment[0], ["Holy Symbol", "Prayer Book", "Vestments", "10 GP"], "First equipment choice should match")
    }
    
    func testBackgroundTraitsEncoding() throws {
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
        
        let decoder = JSONDecoder()
        let background = try decoder.decode(BackgroundTraits.self, from: jsonData)
        
        // When: Encoding the background back to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let encodedData = try encoder.encode(background)
        
        // Then: The encoded data should be decodable and match the original
        let decodedBackground = try decoder.decode(BackgroundTraits.self, from: encodedData)
        
        XCTAssertEqual(decodedBackground.name, background.name, "Name should match after round-trip")
        XCTAssertEqual(decodedBackground.abilityScores, background.abilityScores, "Ability scores should match after round-trip")
        XCTAssertEqual(decodedBackground.feat, background.feat, "Feat should match after round-trip")
        XCTAssertEqual(decodedBackground.skillProficiencies.skillNames, background.skillProficiencies.skillNames, "Skills should match after round-trip")
        XCTAssertEqual(decodedBackground.toolProficiency, background.toolProficiency, "Tool proficiency should match after round-trip")
        XCTAssertEqual(decodedBackground.equipment, background.equipment, "Equipment should match after round-trip")
    }
    
    func testBackgroundsCollection() throws {
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
        
        let decoder = JSONDecoder()
        
        // When: Decoding the JSON data into a Backgrounds collection
        let backgrounds = try decoder.decode(Backgrounds.self, from: jsonData)
        
        // Then: The collection should have the correct count
        XCTAssertEqual(backgrounds.count, 3, "Should have 3 backgrounds")
        
        // Then: The find method should locate backgrounds by name
        let acolyte = backgrounds.find("Acolyte")
        XCTAssertNotNil(acolyte, "Should find Acolyte background")
        XCTAssertEqual(acolyte?.name, "Acolyte", "Found background should be Acolyte")
        XCTAssertEqual(acolyte?.feat, "Magic Initiate", "Acolyte feat should match")
        
        let criminal = backgrounds.find("Criminal")
        XCTAssertNotNil(criminal, "Should find Criminal background")
        XCTAssertEqual(criminal?.skillProficiencies.skillNames, ["Deception", "Stealth"], "Criminal skills should match")
        
        // Then: The find method should return nil for non-existent backgrounds
        let nonExistent = backgrounds.find("Wizard")
        XCTAssertNil(nonExistent, "Should not find non-existent background")
        
        // Then: Subscript access should work correctly
        let firstBackground = backgrounds[0]
        XCTAssertNotNil(firstBackground, "Should access first background")
        XCTAssertEqual(firstBackground?.name, "Acolyte", "First background should be Acolyte")
        
        let thirdBackground = backgrounds[2]
        XCTAssertNotNil(thirdBackground, "Should access third background")
        XCTAssertEqual(thirdBackground?.name, "Soldier", "Third background should be Soldier")
        
        // Then: Round-trip encoding should preserve data
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let encodedData = try encoder.encode(backgrounds)
        let decodedBackgrounds = try decoder.decode(Backgrounds.self, from: encodedData)
        
        XCTAssertEqual(decodedBackgrounds.count, backgrounds.count, "Count should match after round-trip")
        XCTAssertEqual(decodedBackgrounds.find("Criminal")?.name, "Criminal", "Should find Criminal after round-trip")
        XCTAssertEqual(decodedBackgrounds[1]?.toolProficiency, backgrounds[1]?.toolProficiency, "Tool proficiency should match after round-trip")
    }
}
