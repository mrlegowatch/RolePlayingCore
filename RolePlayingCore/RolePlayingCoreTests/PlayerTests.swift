//
//  PlayerTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/18/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class PlayerTests: XCTestCase {
    
    var humanTraits: [String: Any]!
    var human: RacialTraits!
    var fighterTraits: [String: Any]!
    var fighter: ClassTraits!
    
    override func setUp() {
        // TODO: Need to initialize UnitCurrency before creating Money instances in Player class.
        try! UnitCurrency.load("DefaultCurrencies", in: Bundle(for: PlayerTests.self))

        self.fighterTraits = [
            "name": "Fighter",
            "plural": "Fighters",
            "hit dice": "d10",
            "primary ability": ["Strength"],
            "alternate primary ability": ["Dexterity"],
            "saving throws": ["Strength", "Constitution"],
            "starting wealth": "5d4x10",
            "experience points": [0, 300, 900, 2700]]
        self.fighter = ClassTraits(from: self.fighterTraits)
        
        self.humanTraits = [
            "name": "Human",
            "plural": "Humans",
            "ability scores": ["Strength": 1, "Dexterity": 1, "Constitution": 1, "Intelligence": 1, "Wisdom": 1, "Charisma": 1],
            "minimum age": 18,
            "lifespan": 90,
            "base height": "4'8\"",
            "height modifier": "2d10",
            "base weight": 110,
            "weight modifier": "2d4",
            "speed": 30,
            "languages": ["Common"],
            "extra languages": 1]
        self.human = RacialTraits(from: self.humanTraits)
    }
    
    func testPlayer() {
        // Test construction from types
        do {
            let player = Player("Frodo", racialTraits: human, classTraits: fighter, gender: .female, alignment: Alignment(.lawful, .neutral))
            XCTAssertEqual(player.name, "Frodo", "player name")
            XCTAssertEqual(player.className, "Fighter", "class name")
            XCTAssertEqual(player.raceName, "Human", "race name")
            
            XCTAssertNil(player.description, "description")
            
            XCTAssertEqual(player.gender, Player.Gender.female, "gender")
            XCTAssertEqual(player.alignment, Alignment(.lawful, .neutral), "alignment")
            
            for modifier in player.abilityModifiers.values {
                XCTAssertEqual(modifier, 1, "ability modifier")
            }
            
            // Abilities is scores plus race modifiers, so + 1
            for key in player.abilities.abilities {
                let score = player.abilities[key]!
                XCTAssertTrue((4...19).contains(score), "ability score \(score) for \(key)")
            }
            
            // I do the maths
            XCTAssertTrue((4.83333...6.33334).contains(player.height.value), "height \(player.height.value)")
      
            // 110 + 2...8 * 2...20
            XCTAssertTrue((114...270).contains(player.weight.value), "weight \(player.weight.value)")
            
            XCTAssertTrue((1...10).contains(player.maximumHitPoints), "maximum hit points")
            XCTAssertEqual(player.maximumHitPoints, player.currentHitPoints, "current hit points")
            XCTAssertEqual("\(player.hitDice)", "d10", "hit dice")
            XCTAssertEqual(player.experiencePoints, 0, "experience points")
            XCTAssertEqual(player.level, 1, "level")
            
            XCTAssertTrue((50...200).contains(player.money.value), "money \(player.money.value)")
            
            XCTAssertEqual(player.proficiencyBonus, 2, "proficiency bonus")
        }
        
        // Test construction from minimum required traits
        do {
            let playerTraits: [String: Any] = [
                "name": "Bilbo",
                "gender": "male",
                "height": "3'9\"",
                "weight": 120,
                "ability scores": ["Dexterity": 13],
                "money": 130,
                "hit points": 10]
            
            let player = Player(from: playerTraits)
            player?.racialTraits = human
            player?.classTraits = fighter
            
            XCTAssertEqual(player?.name, "Bilbo", "player name")
            XCTAssertEqual(player?.className, "Fighter", "class name")
            XCTAssertEqual(player?.raceName, "Human", "race name")
            
            XCTAssertEqual(player?.gender, Player.Gender.male, "gender")
            XCTAssertNil(player?.alignment, "alignment")
        
            XCTAssertEqual(player?.height.value, 3.75, "height")
            XCTAssertEqual(player?.weight.value, 120, "weight")
            
            XCTAssertEqual(player?.maximumHitPoints, 10, "maximum hit points")
            XCTAssertEqual(player?.maximumHitPoints, player?.currentHitPoints, "current hit points")

            XCTAssertEqual(player?.experiencePoints, 0, "experience points")
            XCTAssertEqual(player?.level, 1, "level")
            
            XCTAssertEqual(player?.money.value, 130, "money")
        }
        
        // Test construction with optional traits
        do {
            let playerTraits: [String: Any] = [
                "name": "Bilbo",
                "alignment": "Lawful Evil",
                "height": "3'9\"",
                "weight": 120,
                "ability scores": ["Strength": 12],
                "money": 130,
                "hit points": 10,
                "experience points": 2300,
                "level": 2]
            
            let player = Player(from: playerTraits)
            player?.racialTraits = human
            player?.classTraits = fighter
            
            XCTAssertNil(player?.gender, "gender")
            XCTAssertEqual(player?.alignment, Alignment(.lawful, .evil), "alignment")
            
            XCTAssertEqual(player?.canLevelUp, true, "level up")
            player?.levelUp()
            XCTAssertEqual(player?.level, 3, "level")
            XCTAssertTrue(player?.maximumHitPoints ?? 0 > 15, "experience points")
            
            XCTAssertEqual(player?.canLevelUp, false, "level up")
            player?.levelUp()
            XCTAssertEqual(player?.level, 3, "level")
        }
    }
    
    func testMissingTraits() {
        do {
            let player = Player(from: nil)
            XCTAssertNil(player)
        }
        
        // Test that each missing trait results in nil
        do {
            let traits: [String: Any] = [:]
            let player = Player(from: traits)
            XCTAssertNil(player)
        }
        
        do {
            let traits: [String: Any] = [
                "name": "Bilbo"]
            
            let player = Player(from: traits)
            XCTAssertNil(player)
        }
        
        
        do {
            let traits: [String: Any] = [
                "name": "Bilbo",
                "height": "3'9\""]
            let player = Player(from: traits)
            XCTAssertNil(player)
        }
        
        do {
            let traits: [String: Any] = [
                "name": "Bilbo",
                "height": "3'9\"",
                "weight": 120]
            let player = Player(from: traits)
            XCTAssertNil(player)
        }
        
        do {
            let traits: [String: Any] = [
                "name": "Bilbo",
                "height": "3'9\"",
                "weight": 120,
                "ability scores": ["Dexterity": 13]]
            let player = Player(from: traits)
            XCTAssertNil(player)
        }
        
        do {
            let traits: [String: Any] = [
                "name": "Bilbo",
                "height": "3'9\"",
                "weight": 120,
                "ability scores": ["Dexterity": 13],
                "money": 130]
            let player = Player(from: traits)
            XCTAssertNil(player)
        }
    }
    
}
