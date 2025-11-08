//
//  PlayerTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/18/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
@testable import RolePlayingCore
import Foundation

@Suite("Player Tests")
struct PlayerTests {
    
    let decoder = JSONDecoder()
    let configuration: Configuration
    let skillTraits: Data
    let skills: Skills
    let soldierTraits: Data
    let soldier: BackgroundTraits
    let humanTraits: Data
    let human: SpeciesTraits
    let fighterTraits: Data
    let fighter: ClassTraits
    
    init() throws {
        configuration = try Configuration("TestConfiguration", from: .module)
        
        self.skillTraits = """
        {
            "skills": [
        {
            "name": "Acrobatics",
            "ability": "Dexterity"
        },
        {
            "name": "Animal Handling",
            "ability": "Wisdom"
        },
        {
            "name": "Arcana",
            "ability": "Intelligence"
        },
        {
            "name": "Athletics",
            "ability": "Strength"
        },
        {
            "name": "Deception",
            "ability": "Charisma"
        },
        {
            "name": "History",
            "ability": "Intelligence"
        },
        {
            "name": "Insight",
            "ability": "Wisdom"
        },
        {
            "name": "Intimidation",
            "ability": "Charisma"
        },
        {
            "name": "Investigation",
            "ability": "Intelligence"
        },
        {
            "name": "Medicine",
            "ability": "Wisdom"
        },
        {
            "name": "Nature",
            "ability": "Intelligence"
        },
        {
            "name": "Perception",
            "ability": "Wisdom"
        },
        {
            "name": "Performance",
            "ability": "Charisma"
        },
        {
            "name": "Persuasion",
            "ability": "Charisma"
        },
        {
            "name": "Religion",
            "ability": "Intelligence"
        },
        {
            "name": "Sleight of Hand",
            "ability": "Dexterity"
        },
        {
            "name": "Stealth",
            "ability": "Dexterity"
        },
        {
            "name": "Survival",
            "ability": "Wisdom"
        }
            ]
        }
        """.data(using: .utf8)!
        self.skills = try! decoder.decode(Skills.self, from: self.skillTraits)
        
        self.soldierTraits = """
        {
            "name": "Soldier",
            "ability scores": ["Strength", "Dexterity", "Constitution"],
            "feat": "Savage Attacker",
            "skill proficiencies" : ["Athletics", "Intimidation"],
            "tool proficiency": "Gaming Set",
            "equipment": [["Spear", "Shortbow", "20 Arrows", "Gaming Set", "Healer's Kit", "Quiver", "Traveler's Clothes", "14 GP"], ["50 GP"]]
        }
        """.data(using: .utf8)!
        self.soldier = try! decoder.decode(BackgroundTraits.self, from: self.soldierTraits, configuration: configuration)
        
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
        """.data(using: .utf8)!
        self.fighter = try! decoder.decode(ClassTraits.self, from: self.fighterTraits, configuration: configuration)
        
        self.humanTraits = """
        {
            "name": "Human",
            "plural": "Humans",
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
        self.human = try! decoder.decode(SpeciesTraits.self, from: self.humanTraits)
    }
    
    @Test("Create player with basic traits")
    func player() async throws {
        let player = Player("Frodo", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .female, alignment: Alignment(.lawful, .neutral))
        #expect(player.name == "Frodo", "player name")
        #expect(player.className == "Fighter", "class name")
        #expect(player.speciesName == "Human", "species name")
        
        #expect(player.descriptiveTraits.count == 0, "descriptiveTraits")
        
        #expect(player.gender == Player.Gender.female, "gender")
        #expect(player.alignment == Alignment(.lawful, .neutral), "alignment")
        
        // Abilities is scores plus species modifiers, so + 1
        for key in player.abilities.abilities {
            let score = player.abilities[key]!
            #expect((3...20).contains(score), "ability score \(score) for \(key)")
        }
        
        // I do the maths
        #expect((4..<7).contains(player.height.value), "height \(player.height.value)")
        
        #expect((1...10).contains(player.maximumHitPoints), "maximum hit points")
        #expect(player.maximumHitPoints == player.currentHitPoints, "current hit points")
        #expect("\(player.classTraits.hitDice)" == "d10", "hit dice")
        #expect(player.experiencePoints == 0, "experience points")
        #expect(player.level == 1, "level")
        
        #expect((50...200).contains(player.money.value), "money \(player.money.value)")
        
        #expect(player.proficiencyBonus == 2, "proficiency bonus")
    }
    
    @Test("Decode player with minimum required traits")
    func minimumTraitsPlayer() async throws {
        let playerTraits = """
        {
            "name": "Bilbo",
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "gender": "Male",
            "height": "3'9\\"",
            "ability scores": {"Dexterity": 13, "Charisma": 12},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skill proficiencies": ["Athletics"],
            "money": 130,
            "maximum hit points": 10
        }
        """.data(using: .utf8)!
        
        let player = try decoder.decode(Player.self, from: playerTraits, configuration: configuration)
        player.speciesTraits = human
        player.classTraits = fighter
        
        #expect(player.name == "Bilbo", "player name")
        #expect(player.className == "Fighter", "class name")
        #expect(player.speciesName == "Human", "species name")
        
        #expect(player.gender == Player.Gender.male, "gender")
        #expect(player.alignment == nil, "alignment")
        
        #expect(player.abilities[.dexterity] == 14, "dexterity")
        #expect(player.abilities[.charisma] == 12, "charisma")
        
        #expect(player.height.value == 3.75, "height")
        
        #expect(player.maximumHitPoints == 10, "maximum hit points")
        #expect(player.maximumHitPoints == player.currentHitPoints, "current hit points")
        
        #expect(player.experiencePoints == 0, "experience points")
        #expect(player.level == 1, "level")
        
        #expect(player.money.value == 130, "money")
    }
    
    @Test("Decode player with optional traits and level up")
    func optionalPlayerTraits() async throws {
        let playerTraits = """
        {
            "name": "Bilbo",
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "alignment": "Lawful Evil",
            "height": "3'9\\"",
            "ability scores": {"Strength": 12},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skill proficiencies": ["Athletics"],
            "money": 130,
            "maximum hit points": 10,
            "experience points": 2300,
            "level": 2
        }
        """.data(using: .utf8)!
        
        let player = try decoder.decode(Player.self, from: playerTraits, configuration: configuration)
        player.speciesTraits = human
        player.classTraits = fighter
        
        #expect(player.gender == nil, "gender")
        #expect(player.alignment == Alignment(.lawful, .evil), "alignment")
        
        #expect(player.canLevelUp == true, "level up")
        #expect("\(player.hitDice)" == "2d10", "hit dice")
        player.levelUp()
        #expect(player.level == 3, "level")
        #expect(player.maximumHitPoints > 15, "experience points")
        
        #expect(player.canLevelUp == false, "level up")
        #expect("\(player.hitDice)" == "3d10", "hit dice")
        
        player.levelUp()
        #expect(player.level == 3, "level")
    }
    
    @Test("Encode and decode player round trip")
    func playerRoundTrip() async throws {
        let playerTraits = """
        {
            "name": "Bilbo",
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "gender": "Male",
            "alignment": "Neutral Good",
            "height": "3'9\\"",
            "ability scores": {"Dexterity": 13},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skill proficiencies": ["Athletics"],
            "money": 130,
            "maximum hit points": 20,
            "current hit points": 9,
            "level": 2
        }
        """.data(using: .utf8)!
        
        let player = try #require(try? decoder.decode(Player.self, from: playerTraits, configuration: configuration))
        let encoder = JSONEncoder()
        let encodedPlayer = try encoder.encode(player, configuration: configuration)
        let encoded = try #require(try? JSONSerialization.jsonObject(with: encodedPlayer, options: []) as? [String: Any])
        
        #expect(encoded["name"] as? String == "Bilbo", "player traits round trip name")
        #expect(encoded["gender"] as? String == "Male", "player traits round trip gender")
        
        let alignment = try #require(encoded["alignment"] as? [String: Double])
        #expect(alignment["ethics"] == 0, "player traits round trip alignment ethics")
        #expect(alignment["morals"] == 1, "player traits round trip alignment morals")
        
        #expect(encoded["height"] as? String == "3.75 ft", "player traits round trip height")
        
        let abilities = try #require(encoded["ability scores"] as? [String: Int])
        #expect(abilities["Dexterity"] == 13, "player traits round trip ability scores")
        
        let backgroundAbilities = try #require(encoded["background ability scores"] as? [String])
        #expect(backgroundAbilities.count == 3, "player traits round trip background ability scores count")
        #expect(backgroundAbilities.contains("Strength"), "player traits round trip background ability scores")
        #expect(!backgroundAbilities.contains("Charisma"), "player traits round trip background ability scores")
        
        #expect(encoded["money"] as? String == "130.0 gp", "player traits round trip money")
        #expect(encoded["maximum hit points"] as? Int == 20, "player traits round trip maximum hit points")
        #expect(encoded["current hit points"] as? Int == 9, "player traits round trip current hit points")
        #expect(encoded["level"] as? Int == 2, "player traits round trip level")
    }
    
    @Test("Verify missing required traits cause decode failure", arguments: [
        "{:}",
        """
        {
            "name": "Bilbo"
        }
        """,
        """
        {
            "name": "Bilbo",
            "height": "3'9\\"",
        }
        """,
        """
        {
            "name": "Bilbo",
            "height": "3'9\\"",
            "ability scores": {"Dexterity": 13}
        }
        """,
        """
        {
            "name": "Bilbo",
            "height": "3'9\\"",
            "ability scores": {"Dexterity": 13},
            "money": 130]
        }
        """
    ])
    func missingTraits(json: String) async throws {
        let traits = json.data(using: .utf8)!
        let player = try? decoder.decode(Player.self, from: traits, configuration: configuration)
        #expect(player == nil)
    }
    
    func expectedModifier(for abilityScore: Int) -> Int {
        let selfMinus10 = abilityScore - 10
        return selfMinus10 < 0 ? Int((Double(selfMinus10) / 2.0).rounded(.down)) : selfMinus10 / 2
    }
    
    @Test("Verify computed properties")
    func computedProperties() async throws {
        let player = Player("Gandalf", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male, alignment: Alignment(.neutral, .good))
        
        // Test speed (from species traits)
        #expect(player.speed == 30, "speed should match species speed")
        #expect(player.size == .medium, "size should match species size")
        
        // Test modifiers
        for ability in player.modifiers.abilities {
            let abilityScore = player.abilities[ability]!
            let expectedModifier = expectedModifier(for: abilityScore)
            #expect(player.modifiers[ability] == expectedModifier, "modifier calculation")
        }
        
        // Test initiative
        #expect(player.initiativeModifier == player.modifiers[.dexterity], "initiative modifier")
        #expect(player.initiativeScore == 10 + player.modifiers[.dexterity], "initiative score")
        
        // Test passive perception
        #expect(player.passivePerception == 10 + player.modifiers[.wisdom], "passive perception")
    }
    
    @Test("Verify proficiency bonus at different levels", arguments: [
        (1, 2), (4, 2),
        (5, 3), (8, 3),
        (9, 4), (12, 4),
        (13, 5), (16, 5),
        (17, 6), (20, 6)
    ])
    func proficiencyBonus(level: Int, expectedBonus: Int) async throws {
        let player = Player("Aragorn", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player.level = level
        #expect(player.proficiencyBonus == expectedBonus, "proficiency bonus at level \(level)")
    }
    
    @Test("Verify hit dice at different levels", arguments: [
        (1, "d10"),
        (5, "5d10"),
        (10, "10d10"),
        (20, "20d10")
    ])
    func hitDiceAtDifferentLevels(level: Int, expectedDice: String) async throws {
        let player = Player("Legolas", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player.level = level
        #expect("\(player.hitDice)" == expectedDice, "hit dice at level \(level)")
    }
    
    @Test("Verify Hashable conformance")
    func hashableConformance() async throws {
        let player1 = Player("Gimli", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male, alignment: Alignment(.lawful, .good))
        player1.descriptiveTraits = ["ideal": "Honor", "bond": "My axe"]
        
        let player2 = Player("Gimli", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male, alignment: Alignment(.lawful, .good))
        player2.speciesTraits = human
        player2.classTraits = fighter
        player2.baseAbilities = player1.baseAbilities
        player2.height = player1.height
        player2.maximumHitPoints = player1.maximumHitPoints
        player2.currentHitPoints = player1.currentHitPoints
        player2.experiencePoints = player1.experiencePoints
        player2.money = player1.money
        player2.descriptiveTraits = ["ideal": "Honor", "bond": "My axe"]
        
        // Test equality
        #expect(player1 == player2, "identical players should be equal")
        
        // Test hash values
        var hasher1 = Hasher()
        player1.hash(into: &hasher1)
        let hash1 = hasher1.finalize()
        
        var hasher2 = Hasher()
        player2.hash(into: &hasher2)
        let hash2 = hasher2.finalize()
        
        #expect(hash1 == hash2, "identical players should have same hash")
        
        // Test that players can be used in Sets
        let playerSet: Set<Player> = [player1, player2]
        #expect(playerSet.count == 1, "set should contain only one unique player")
    }
    
    @Test("Verify player inequality")
    func playerInequality() async throws {
        let player1 = Player("Boromir", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let player2 = Player("Faramir", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        
        // Different names
        #expect(player1 != player2, "players with different names should not be equal")
        
        // Different hit points
        let player3 = Player("Boromir", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player3.baseAbilities = player1.baseAbilities
        player3.height = player1.height
        player3.money = player1.money
        player3.currentHitPoints = player3.currentHitPoints - 5
        
        #expect(player1 != player3, "players with different current HP should not be equal")
    }
    
    @Test("Verify gender cases")
    func genderCases() async throws {
        // Test all gender cases
        let female = Player("Diana", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .female)
        #expect(female.gender == .female, "female gender")
        
        let male = Player("Arthur", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male)
        #expect(male.gender == .male, "male gender")
        
        let agender = Player("Riley", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: nil)
        #expect(agender.gender == nil, "nil gender for androgynous/hermaphroditic")
    }
    
    @Test("Verify descriptive traits")
    func descriptiveTraits() async throws {
        let player = Player("Samwise", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        
        // Initially empty
        #expect(player.descriptiveTraits.count == 0)
        
        // Add traits
        player.descriptiveTraits["ideal"] = "Loyalty"
        player.descriptiveTraits["bond"] = "My friends"
        player.descriptiveTraits["flaw"] = "Too trusting"
        player.descriptiveTraits["background"] = "Gardener"
        
        #expect(player.descriptiveTraits.count == 4)
        #expect(player.descriptiveTraits["ideal"] == "Loyalty")
        #expect(player.descriptiveTraits["bond"] == "My friends")
        #expect(player.descriptiveTraits["flaw"] == "Too trusting")
        #expect(player.descriptiveTraits["background"] == "Gardener")
    }
    
    @Test("Verify ability scores roll")
    func abilityScoresRoll() async throws {
        var abilities = AbilityScores()
        abilities.roll()
        
        // Verify all abilities have valid scores (4d6-L should give 3-18)
        for ability in abilities.abilities {
            let score = abilities[ability]!
            #expect((3...18).contains(score), "rolled ability score should be between 3 and 18")
        }
        
        // Verify all six abilities are set
        #expect(abilities.abilities.count == 6, "should have 6 abilities")
    }
    
    @Test("Verify dice hit dice extension")
    func diceHitDiceExtension() async throws {
        // Test the hitDice extension on Dice
        let d6 = SimpleDice(.d6)
        
        let level1HitDice = d6.hitDice(level: 1)
        #expect("\(level1HitDice)" == "d6")
        
        let level5HitDice = d6.hitDice(level: 5)
        #expect("\(level5HitDice)" == "5d6")
        
        let level10HitDice = d6.hitDice(level: 10)
        #expect("\(level10HitDice)" == "10d6")
    }
    
    @Test("Verify species and class traits didSet")
    func speciesAndClassTraitsDidSet() async throws {
        let player = Player("Test", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        
        #expect(player.backgroundName == "Soldier")
        #expect(player.speciesName == "Human")
        #expect(player.className == "Fighter")
        
        // Create a mock second species (we'll reuse human but check the didSet is called)
        let mockSpecies = human
        player.speciesTraits = mockSpecies
        #expect(player.speciesName == mockSpecies.name)
        
        // Create a mock second class (we'll reuse fighter but check the didSet is called)
        let mockClass = fighter
        player.classTraits = mockClass
        #expect(player.className == mockClass.name)
    }
    
    @Test("Encode and decode player with descriptive traits")
    func playerEncodingWithDescriptiveTraits() async throws {
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
            "ability scores": {"Charisma": 14, "Dexterity": 15},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skill proficiencies": ["Athletics"],
            "money": 100,
            "maximum hit points": 12
        }
        """.data(using: .utf8)!
        
        let player = try decoder.decode(Player.self, from: playerTraits, configuration: configuration)
        #expect(player.descriptiveTraits.count == 3)
        #expect(player.descriptiveTraits["ideal"] == "Adventure")
        #expect(player.descriptiveTraits["bond"] == "The Shire")
        #expect(player.descriptiveTraits["flaw"] == "Impulsive")
        
        // Test encoding
        let encoded = try encoder.encode(player, configuration: configuration)
        let decodedDict = try #require(try? JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        let encodedTraits = try #require(decodedDict["descriptive traits"] as? [String: String])
        #expect(encodedTraits["ideal"] == "Adventure")
    }
    
    @Test("Verify rollHitPoints class method")
    func rollHitPointsClassMethod() async throws {
        // Test the static rollHitPoints method
        let hitPoints = Player.rollHitPoints(classTraits: fighter, speciesTraits: human)
        
        // Fighter has d10, so minimum should be 6 (max(10/2+1, roll)),
        // but roll could be lower, so minimum is actually 6 + species bonus
        // Maximum is 10 + species bonus
        #expect((6...10).contains(hitPoints), "hit points should be in valid range")
    }
    
    @Test("Verify multiple level ups")
    func multipleLevelUps() async throws {
        let playerTraits = """
        {
            "name": "Merry",
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "height": "4'2\\"",
            "ability scores": {"Strength": 14},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skill proficiencies": ["Athletics"],
            "money": 100,
            "maximum hit points": 12,
            "experience points": 0,
            "level": 1
        }
        """.data(using: .utf8)!
        
        let player = try decoder.decode(Player.self, from: playerTraits, configuration: configuration)
        player.speciesTraits = human
        player.classTraits = fighter
        
        let initialHP = player.maximumHitPoints
        
        // Add enough XP to level up to level 2
        player.experiencePoints = 301
        #expect(player.canLevelUp)
        player.levelUp()
        #expect(player.level == 2)
        #expect(player.maximumHitPoints > initialHP, "HP should increase on level up")
        
        // Add enough XP to level up to level 3
        player.experiencePoints = 901
        #expect(player.canLevelUp)
        player.levelUp()
        #expect(player.level == 3)
        
        // Add enough XP to level up to level 4
        player.experiencePoints = 2701
        #expect(player.canLevelUp)
        player.levelUp()
        #expect(player.level == 4)
        
        // Without enough XP, cannot level up
        player.experiencePoints = 2701
        #expect(player.canLevelUp == false)
        player.levelUp() // Should do nothing
        #expect(player.level == 4)
    }
}
