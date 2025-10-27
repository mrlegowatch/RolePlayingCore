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
    
    var soldierTraits: Data!
    var soldier: BackgroundTraits!
    var humanTraits: Data!
    var human: SpeciesTraits!
    var fighterTraits: Data!
    var fighter: ClassTraits!
    
    override func setUp() {
        // TODO: Need to initialize UnitCurrency before creating Money instances in Player class.
        // Only load once. TODO: this has a side effect on other unit tests: currencies are already loaded.
        let bundle = Bundle(for: PlayerTests.self)
        let decoder = JSONDecoder()
        let data = try! bundle.loadJSON("TestCurrencies")
        _ = try! decoder.decode(Currencies.self, from: data)
        
        self.soldierTraits = """
        {
            "name": "Soldier",
            "ability scores": ["Strength", "Dexterity", "Constitution"],
            "feat": "Savage Attacker",
            "skill proficiencies" : ["Athletics", "Intimidation"],
            "tool proficiency": "Gaming Set",
            "equipment": [["Spear", "Shortbow", "20 Arrows", "Gaming Set", "Healer's Kit", "Quiver", "Traveler's Clothes", "14 GP"], ["50 GP"]]
        }
        """.data(using: .utf8)
        self.soldier = try! decoder.decode(BackgroundTraits.self, from: self.soldierTraits)
        
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
        self.human = try! decoder.decode(SpeciesTraits.self, from: self.humanTraits)
    }
    
    func testPlayer() {
        let decoder = JSONDecoder()
        
        // Test construction from types
        do {
            let player = Player("Frodo", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .female, alignment: Alignment(.lawful, .neutral))
            XCTAssertEqual(player.name, "Frodo", "player name")
            XCTAssertEqual(player.className, "Fighter", "class name")
            XCTAssertEqual(player.speciesName, "Human", "species name")
            
            XCTAssertEqual(player.descriptiveTraits.count, 0, "descriptiveTraits")
            
            XCTAssertEqual(player.gender, Player.Gender.female, "gender")
            XCTAssertEqual(player.alignment, Alignment(.lawful, .neutral), "alignment")
            
            // Abilities is scores plus species modifiers, so + 1
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
                "background": "Sailor",
                "species": "Human",
                "class": "Fighter",
                "gender": "Male",
                "height": "3'9\\"",
                "weight": 120,
                "ability scores": {"Dexterity": 13, "Charisma": 12},
                "background ability scores": ["Strength", "Strength", "Dexterity"],
                "skills": ["Athletics"],
                "money": 130,
                "maximum hit points": 10
            }
            """.data(using: .utf8)!
            
            do {
                let player = try decoder.decode(Player.self, from: playerTraits)
                player.speciesTraits = human
                player.classTraits = fighter
                
                XCTAssertEqual(player.name, "Bilbo", "player name")
                XCTAssertEqual(player.className, "Fighter", "class name")
                XCTAssertEqual(player.speciesName, "Human", "species name")
                
                XCTAssertEqual(player.gender, Player.Gender.male, "gender")
                XCTAssertNil(player.alignment, "alignment")
                
                XCTAssertEqual(player.abilities[.dexterity], 14, "dexterity")
                XCTAssertEqual(player.abilities[.charisma], 12, "charisma")
                
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
                "background": "Sailor",
                "species": "Human",
                "class": "Fighter",
                "alignment": "Lawful Evil",
                "height": "3'9\\"",
                "weight": 120,
                "ability scores": {"Strength": 12},
                "background ability scores": ["Strength", "Strength", "Dexterity"],
                "skills": ["Athletics"],
                "money": 130,
                "maximum hit points": 10,
                "experience points": 2300,
                "level": 2
            }
            """.data(using: .utf8)!
            
            do {
                let player = try decoder.decode(Player.self, from: playerTraits)
                player.speciesTraits = human
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
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "gender": "Male",
            "alignment": "Neutral Good",
            "height": "3'9\\"",
            "weight": 120,
            "ability scores": {"Dexterity": 13},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skills": ["Athletics"],
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
            
            let backgroundAbilities = encoded["background ability scores"] as? [String]
            XCTAssertNotNil(backgroundAbilities)
            XCTAssertEqual(backgroundAbilities?.count, 3, "player traits round trip background ability scores count")
            XCTAssertTrue(backgroundAbilities!.contains("Strength"), "player traits round trip background ability scores")
            XCTAssertFalse(backgroundAbilities!.contains("Charisma"), "player traits round trip background ability scores")

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
    
    func expectedModifier(for abilityScore: Int) -> Int {
        let selfMinus10 = abilityScore - 10
        return selfMinus10 < 0 ? Int(floor(Double(selfMinus10) / 2.0)) : selfMinus10 / 2
    }
    
    func testComputedProperties() {
        let player = Player("Gandalf", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male, alignment: Alignment(.neutral, .good))
        
        // Test speed (from species traits)
        XCTAssertEqual(player.speed, 30, "speed should match species speed")
        XCTAssertEqual(player.size, .medium, "size should match species size")
        
        // Test modifiers
        for ability in player.modifiers.abilities {
            let abilityScore = player.abilities[ability]!
            let expectedModifier = expectedModifier(for: abilityScore)
            XCTAssertEqual(player.modifiers[ability], expectedModifier, "modifier calculation")
        }
        
        // Test initiative
        XCTAssertEqual(player.initiativeModifier, player.modifiers[.dexterity], "initiative modifier")
        XCTAssertEqual(player.initiativeScore, 10 + player.modifiers[.dexterity], "initiative score")
        
        // Test passive perception
        XCTAssertEqual(player.passivePerception, 10 + player.modifiers[.wisdom], "passive perception")
    }
    
    func testProficiencyBonus() {
        let player = Player("Aragorn", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        
        // Level 1-4: +2
        player.level = 1
        XCTAssertEqual(player.proficiencyBonus, 2, "proficiency bonus at level 1")
        
        player.level = 4
        XCTAssertEqual(player.proficiencyBonus, 2, "proficiency bonus at level 4")
        
        // Level 5-8: +3
        player.level = 5
        XCTAssertEqual(player.proficiencyBonus, 3, "proficiency bonus at level 5")
        
        player.level = 8
        XCTAssertEqual(player.proficiencyBonus, 3, "proficiency bonus at level 8")
        
        // Level 9-12: +4
        player.level = 9
        XCTAssertEqual(player.proficiencyBonus, 4, "proficiency bonus at level 9")
        
        player.level = 12
        XCTAssertEqual(player.proficiencyBonus, 4, "proficiency bonus at level 12")
        
        // Level 13-16: +5
        player.level = 13
        XCTAssertEqual(player.proficiencyBonus, 5, "proficiency bonus at level 13")
        
        player.level = 16
        XCTAssertEqual(player.proficiencyBonus, 5, "proficiency bonus at level 16")
        
        // Level 17-20: +6
        player.level = 17
        XCTAssertEqual(player.proficiencyBonus, 6, "proficiency bonus at level 17")
        
        player.level = 20
        XCTAssertEqual(player.proficiencyBonus, 6, "proficiency bonus at level 20")
    }
    
    func testHitDiceAtDifferentLevels() {
        let player = Player("Legolas", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        
        player.level = 1
        XCTAssertEqual("\(player.hitDice)", "d10", "hit dice at level 1")
        
        player.level = 5
        XCTAssertEqual("\(player.hitDice)", "5d10", "hit dice at level 5")
        
        player.level = 10
        XCTAssertEqual("\(player.hitDice)", "10d10", "hit dice at level 10")
        
        player.level = 20
        XCTAssertEqual("\(player.hitDice)", "20d10", "hit dice at level 20")
    }
    
    func testHashableConformance() {
        let player1 = Player("Gimli", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male, alignment: Alignment(.lawful, .good))
        player1.descriptiveTraits = ["ideal": "Honor", "bond": "My axe"]
        
        let player2 = Player("Gimli", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male, alignment: Alignment(.lawful, .good))
        player2.speciesTraits = human
        player2.classTraits = fighter
        player2.baseAbilities = player1.baseAbilities
        player2.height = player1.height
        player2.weight = player1.weight
        player2.maximumHitPoints = player1.maximumHitPoints
        player2.currentHitPoints = player1.currentHitPoints
        player2.experiencePoints = player1.experiencePoints
        player2.money = player1.money
        player2.descriptiveTraits = ["ideal": "Honor", "bond": "My axe"]
        
        // Test equality
        XCTAssertEqual(player1, player2, "identical players should be equal")
        
        // Test hash values
        var hasher1 = Hasher()
        player1.hash(into: &hasher1)
        let hash1 = hasher1.finalize()
        
        var hasher2 = Hasher()
        player2.hash(into: &hasher2)
        let hash2 = hasher2.finalize()
        
        XCTAssertEqual(hash1, hash2, "identical players should have same hash")
        
        // Test that players can be used in Sets
        let playerSet: Set<Player> = [player1, player2]
        XCTAssertEqual(playerSet.count, 1, "set should contain only one unique player")
    }
    
    func testPlayerInequality() {
        let player1 = Player("Boromir", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let player2 = Player("Faramir", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        
        // Different names
        XCTAssertNotEqual(player1, player2, "players with different names should not be equal")
        
        // Different hit points
        let player3 = Player("Boromir", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player3.baseAbilities = player1.baseAbilities
        player3.height = player1.height
        player3.weight = player1.weight
        player3.money = player1.money
        player3.currentHitPoints = player3.currentHitPoints - 5
        
        XCTAssertNotEqual(player1, player3, "players with different current HP should not be equal")
    }
    
    func testGenderCases() {
        // Test all gender cases
        let female = Player("Diana", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .female)
        XCTAssertEqual(female.gender, .female, "female gender")
        
        let male = Player("Arthur", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male)
        XCTAssertEqual(male.gender, .male, "male gender")
        
        let agender = Player("Riley", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: nil)
        XCTAssertNil(agender.gender, "nil gender for androgynous/hermaphroditic")
    }
    
    func testDescriptiveTraits() {
        let player = Player("Samwise", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        
        // Initially empty
        XCTAssertEqual(player.descriptiveTraits.count, 0)
        
        // Add traits
        player.descriptiveTraits["ideal"] = "Loyalty"
        player.descriptiveTraits["bond"] = "My friends"
        player.descriptiveTraits["flaw"] = "Too trusting"
        player.descriptiveTraits["background"] = "Gardener"
        
        XCTAssertEqual(player.descriptiveTraits.count, 4)
        XCTAssertEqual(player.descriptiveTraits["ideal"], "Loyalty")
        XCTAssertEqual(player.descriptiveTraits["bond"], "My friends")
        XCTAssertEqual(player.descriptiveTraits["flaw"], "Too trusting")
        XCTAssertEqual(player.descriptiveTraits["background"], "Gardener")
    }
    
    func testAbilityScoresRoll() {
        var abilities = AbilityScores()
        abilities.roll()
        
        // Verify all abilities have valid scores (4d6-L should give 3-18)
        for ability in abilities.abilities {
            let score = abilities[ability]!
            XCTAssertTrue((3...18).contains(score), "rolled ability score should be between 3 and 18")
        }
        
        // Verify all six abilities are set
        XCTAssertEqual(abilities.abilities.count, 6, "should have 6 abilities")
    }
    
    func testDiceHitDiceExtension() {
        // Test the hitDice extension on Dice
        let d6 = SimpleDice(.d6)
        
        let level1HitDice = d6.hitDice(level: 1)
        XCTAssertEqual("\(level1HitDice)", "d6")
        
        let level5HitDice = d6.hitDice(level: 5)
        XCTAssertEqual("\(level5HitDice)", "5d6")
        
        let level10HitDice = d6.hitDice(level: 10)
        XCTAssertEqual("\(level10HitDice)", "10d6")
    }
    
    func testSpeciesAndClassTraitsDidSet() {
        let player = Player("Test", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        
        XCTAssertEqual(player.backgroundName, "Soldier")
        XCTAssertEqual(player.speciesName, "Human")
        XCTAssertEqual(player.className, "Fighter")
        
        // Create a mock second species (we'll reuse human but check the didSet is called)
        let mockSpecies = human!
        player.speciesTraits = mockSpecies
        XCTAssertEqual(player.speciesName, mockSpecies.name)
        
        // Create a mock second class (we'll reuse fighter but check the didSet is called)
        let mockClass = fighter!
        player.classTraits = mockClass
        XCTAssertEqual(player.className, mockClass.name)
    }
    
    func testPlayerEncodingWithDescriptiveTraits() {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        let playerTraits = """
        {
            "name": "Pippin",
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "descriptive traits": {
                "ideal": "Adventure",
                "bond": "The Shire",
                "flaw": "Impulsive"
            },
            "height": "4'2\\"",
            "weight": 95,
            "ability scores": {"Charisma": 14, "Dexterity": 15},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skills": ["Athletics"],
            "money": 100,
            "maximum hit points": 12
        }
        """.data(using: .utf8)!
        
        do {
            let player = try decoder.decode(Player.self, from: playerTraits)
            XCTAssertEqual(player.descriptiveTraits.count, 3)
            XCTAssertEqual(player.descriptiveTraits["ideal"], "Adventure")
            XCTAssertEqual(player.descriptiveTraits["bond"], "The Shire")
            XCTAssertEqual(player.descriptiveTraits["flaw"], "Impulsive")
            
            // Test encoding
            let encoded = try encoder.encode(player)
            let decodedDict = try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
            let encodedTraits = decodedDict?["descriptive traits"] as? [String: String]
            XCTAssertNotNil(encodedTraits)
            XCTAssertEqual(encodedTraits?["ideal"], "Adventure")
        } catch {
            XCTFail("Failed to decode/encode player with descriptive traits: \(error)")
        }
    }
    
    func testRollHitPointsClassMethod() {
        // Test the static rollHitPoints method
        let hitPoints = Player.rollHitPoints(classTraits: fighter, speciesTraits: human)
        
        // Fighter has d10, so minimum should be 6 (max(10/2+1, roll)), 
        // but roll could be lower, so minimum is actually 6 + species bonus
        // Maximum is 10 + species bonus
        XCTAssertTrue((6...10).contains(hitPoints), "hit points should be in valid range")
    }
    
    func testMultipleLevelUps() {
        let decoder = JSONDecoder()
        
        let playerTraits = """
        {
            "name": "Merry",
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "height": "4'2\\"",
            "weight": 95,
            "ability scores": {"Strength": 14},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skills": ["Athletics"],
            "money": 100,
            "maximum hit points": 12,
            "experience points": 0,
            "level": 1
        }
        """.data(using: .utf8)!
        
        let player = try! decoder.decode(Player.self, from: playerTraits)
        player.speciesTraits = human
        player.classTraits = fighter
        
        let initialHP = player.maximumHitPoints
        
        // Add enough XP to level up to level 2
        player.experiencePoints = 301
        XCTAssertTrue(player.canLevelUp)
        player.levelUp()
        XCTAssertEqual(player.level, 2)
        XCTAssertTrue(player.maximumHitPoints > initialHP, "HP should increase on level up")
        
        // Add enough XP to level up to level 3
        player.experiencePoints = 901
        XCTAssertTrue(player.canLevelUp)
        player.levelUp()
        XCTAssertEqual(player.level, 3)
        
        // Add enough XP to level up to level 4
        player.experiencePoints = 2701
        XCTAssertTrue(player.canLevelUp)
        player.levelUp()
        XCTAssertEqual(player.level, 4)
        
        // Without enough XP, cannot level up
        player.experiencePoints = 2701
        XCTAssertFalse(player.canLevelUp)
        player.levelUp() // Should do nothing
        XCTAssertEqual(player.level, 4)
    }
    
}
