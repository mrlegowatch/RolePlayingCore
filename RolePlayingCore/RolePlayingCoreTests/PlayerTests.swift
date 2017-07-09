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
    
    var humanTraits: Data!
    var human: RacialTraits!
    var fighterTraits: Data!
    var fighter: ClassTraits!
    
    override func setUp() {
        // TODO: Need to initialize UnitCurrency before creating Money instances in Player class.
        // Only load once. TODO: this has a side effect on other unit tests: currencies are already loaded.
        let bundle = Bundle(for: PlayerTests.self)
        let decoder = JSONDecoder()
        let data = try! bundle.loadJSON("TestCurrencies")
        _ = try! decoder.decode(Currencies.self, from: data)
        
        self.fighterTraits = """
        {
            "name": "Fighter",
            "plural": "Fighters",
            "hit dice": "d10",
            "primary ability": ["Strength"],
            "alternate primary ability": ["Dexterity"],
            "saving throws": ["Strength", "Constitution"],
            "starting wealth": "5d4x10",
            "experience points": [0, 300, 900, 2700]
        }
        """.data(using: .utf8)
        self.fighter = try! decoder.decode(ClassTraits.self, from: self.fighterTraits)
        
        self.humanTraits = """
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
        """.data(using: .utf8)
        self.human = try! decoder.decode(RacialTraits.self, from: self.humanTraits)
    }
    
    func testGender() {
        XCTAssertEqual("\(Player.Gender.male)", "Male", "Gender CustomStringConvertible should be uppercase")
        XCTAssertEqual("\(Player.Gender.female)", "Female", "Gender CustomStringConvertible should be uppercase")
    }
    
    func testPlayer() {
        let decoder = JSONDecoder()
        
        // Test construction from types
        do {
            let player = Player("Frodo", racialTraits: human, classTraits: fighter, gender: .female, alignment: Alignment(.lawful, .neutral))
            XCTAssertEqual(player.name, "Frodo", "player name")
            XCTAssertEqual(player.className, "Fighter", "class name")
            XCTAssertEqual(player.raceName, "Human", "race name")
            
            XCTAssertEqual(player.descriptiveTraits.count, 0, "descriptiveTraits")
            
            XCTAssertEqual(player.gender, Player.Gender.female, "gender")
            XCTAssertEqual(player.alignment, Alignment(.lawful, .neutral), "alignment")
            
            // Abilities is scores plus race modifiers, so + 1
            for key in player.abilities.abilities {
                let score = player.abilities[key]!
                XCTAssertTrue((4...19).contains(score), "ability score \(score) for \(key)")
            }
            
            // I do the maths
            XCTAssertTrue((4.66666...6.33334).contains(player.height.value), "height \(player.height.value)")
      
            // 110 + 2...8 * 2...20
            XCTAssertTrue((114...270).contains(player.weight.value), "weight \(player.weight.value)")
            
            XCTAssertTrue((1...10).contains(player.maximumHitPoints), "maximum hit points")
            XCTAssertEqual(player.maximumHitPoints, player.currentHitPoints, "current hit points")
            XCTAssertEqual("\(player.classTraits.hitDice)", "d10", "hit dice")
            XCTAssertEqual(player.experiencePoints, 0, "experience points")
            XCTAssertEqual(player.level, 1, "level")
            
            XCTAssertTrue((50...200).contains(player.money.value), "money \(player.money.value)")
            
            XCTAssertEqual(player.proficiencyBonus, 2, "proficiency bonus")
        }
        
        // Test construction from minimum required traits
        do {
            let playerTraits = """
            {
                "name": "Bilbo",
                "race": "Human",
                "class": "Fighter",
                "gender": "Male",
                "height": "3'9\\"",
                "weight": 120,
                "ability scores": {"Dexterity": 13},
                "money": 130,
                "maximum hit points": 10
            }
            """.data(using: .utf8)!
            
            do {
                let player = try decoder.decode(Player.self, from: playerTraits)
                player.racialTraits = human
                player.classTraits = fighter
                
                XCTAssertEqual(player.name, "Bilbo", "player name")
                XCTAssertEqual(player.className, "Fighter", "class name")
                XCTAssertEqual(player.raceName, "Human", "race name")
                
                XCTAssertEqual(player.gender, Player.Gender.male, "gender")
                XCTAssertNil(player.alignment, "alignment")
                
                XCTAssertEqual(player.height.value, 3.75, "height")
                XCTAssertEqual(player.weight.value, 120, "weight")
                
                XCTAssertEqual(player.maximumHitPoints, 10, "maximum hit points")
                XCTAssertEqual(player.maximumHitPoints, player.currentHitPoints, "current hit points")
                
                XCTAssertEqual(player.experiencePoints, 0, "experience points")
                XCTAssertEqual(player.level, 1, "level")
                
                XCTAssertEqual(player.money.value, 130, "money")
                
            }
            catch let error {
                XCTFail("decode player failed, error: \(error)")
            }
        }
        
        // Test construction with optional traits
        do {
            let playerTraits = """
            {
                "name": "Bilbo",
                "race": "Human",
                "class": "Fighter",
                "alignment": "Lawful Evil",
                "height": "3'9\\"",
                "weight": 120,
                "ability scores": {"Strength": 12},
                "money": 130,
                "maximum hit points": 10,
                "experience points": 2300,
                "level": 2
            }
            """.data(using: .utf8)!
            
            do {
                let player = try decoder.decode(Player.self, from: playerTraits)
                player.racialTraits = human
                player.classTraits = fighter
                
                XCTAssertNil(player.gender, "gender")
                XCTAssertEqual(player.alignment, Alignment(.lawful, .evil), "alignment")
                
                XCTAssertEqual(player.canLevelUp, true, "level up")
                XCTAssertEqual("\(player.hitDice)", "2d10", "hit dice")
                player.levelUp()
                XCTAssertEqual(player.level, 3, "level")
                XCTAssertTrue(player.maximumHitPoints > 15, "experience points")
                
                XCTAssertEqual(player.canLevelUp, false, "level up")
                XCTAssertEqual("\(player.hitDice)", "3d10", "hit dice")
                
                player.levelUp()
                XCTAssertEqual(player.level, 3, "level")
            }
            catch let error {
                XCTFail("decode player failed, error: \(error)")
            }
        }
    }
    
    func testPlayerRoundTrip() {
        let playerTraits = """
        {
            "name": "Bilbo",
            "race": "Human",
            "class": "Fighter",
            "gender": "Male",
            "alignment": "Neutral Good",
            "height": "3'9\\"",
            "weight": 120,
            "ability scores": {"Dexterity": 13},
            "money": 130,
            "maximum hit points": 20,
            "current hit points": 9,
            "level": 2
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let player = try? decoder.decode(Player.self, from: playerTraits)
        let encoder = JSONEncoder()
        let encodedPlayer = try! encoder.encode(player)
        let encoded = try? JSONSerialization.jsonObject(with: encodedPlayer, options: [])
        XCTAssertNotNil(encoded, "player traits round trip")
        
        if let encoded = encoded as? [String: Any] {
            XCTAssertEqual(encoded["name"] as? String, "Bilbo", "player traits round trip name")
            XCTAssertEqual(encoded["gender"] as? String, "Male", "player traits round trip gender")
            XCTAssertNotNil(encoded["alignment"] as? [String: Double], "player traits round trip alignment")
            if let alignment = encoded["alignment"] as? [String: Double] {
                XCTAssertEqual(alignment["ethics"], 0, "player traits round trip alignment ethics")
                XCTAssertEqual(alignment["morals"], 1, "player traits round trip alignment ethics")
            }
            XCTAssertEqual(encoded["height"] as? String, "3.75 ft", "player traits round trip height")
            XCTAssertEqual(encoded["weight"] as? String, "120.0 lb", "player traits round trip weight")
            
            let abilities = encoded["ability scores"] as? [String: Int]
            XCTAssertNotNil(abilities)
            print("\(String(describing: abilities))")
            XCTAssertEqual(abilities?["Dexterity"], 13, "player traits round trip ability scores")
            
            XCTAssertEqual(encoded["money"] as? String, "130.0 gp", "player traits round trip money")
            XCTAssertEqual(encoded["maximum hit points"] as? Int, 20, "player traits round trip maximum hit points")
            XCTAssertEqual(encoded["current hit points"] as? Int, 9, "player traits round trip current hit points")
            XCTAssertEqual(encoded["level"] as? Int, 2, "player traits round trip level")
        } else {
            XCTFail("Failed to deserialize encoded Player into dictionary")
        }
    }
    
    func testMissingTraits() {
        let decoder = JSONDecoder()
        
        // Test that each missing trait results in nil
        do {
            let traits = "{:}".data(using: .utf8)!
            let player = try? decoder.decode(Player.self, from: traits)
            XCTAssertNil(player)
        }
        
        do {
            let traits = """
            {
                "name": "Bilbo"
            }
            """.data(using: .utf8)!
            let player = try? decoder.decode(Player.self, from: traits)
            XCTAssertNil(player)
        }
        
        
        do {
            let traits = """
            {
                "name": "Bilbo",
                "height": "3'9\\""
            }
            """.data(using: .utf8)!
            let player = try? decoder.decode(Player.self, from: traits)
            XCTAssertNil(player)
        }
        
        do {
            let traits = """
            {
                "name": "Bilbo",
                "height": "3'9\\"",
                "weight": 120
            }
            """.data(using: .utf8)!
            let player = try? decoder.decode(Player.self, from: traits)
            XCTAssertNil(player)
        }
        
        do {
            let traits = """
            {
                "name": "Bilbo",
                "height": "3'9\\"",
                "weight": 120,
                "ability scores": {"Dexterity": 13}
            }
            """.data(using: .utf8)!
            let player = try? decoder.decode(Player.self, from: traits)
            XCTAssertNil(player)
        }
        
        do {
            let traits = """
            {
                "name": "Bilbo",
                "height": "3'9\\"",
                "weight": 120,
                "ability scores": {"Dexterity": 13},
                "money": 130]
            }
            """.data(using: .utf8)!
            let player = try? decoder.decode(Player.self, from: traits)
            XCTAssertNil(player)
        }
    }
    
}
