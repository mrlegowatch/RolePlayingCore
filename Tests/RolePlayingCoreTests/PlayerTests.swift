//
//  PlayerTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/18/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
@testable import RolePlayingCore
import SwiftDice
import Foundation

@Suite("Player Tests")
struct PlayerTests {
    
    let decoder = JSONDecoder()
    let gameData: GameData
    let skillTraits: Data
    let skills: Skills
    let soldierTraits: Data
    let soldier: BackgroundTraits
    let humanTraits: Data
    let human: SpeciesTraits
    let fighterTraits: Data
    let fighter: ClassTraits
    
    init() throws {
        gameData = try GameData("TestConfiguration", from: .module)
        
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
        self.soldier = try! decoder.decode(BackgroundTraits.self, from: self.soldierTraits, configuration: gameData)
        
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
        self.fighter = try! decoder.decode(ClassTraits.self, from: self.fighterTraits, configuration: gameData)
        
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
        self.human = try! decoder.decode(SpeciesTraits.self, from: self.humanTraits, configuration: gameData)
    }
    
    @Test("Create player with basic traits")
    func player() async throws {
        let player = Player("Frodo", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .female, alignment: CharacterAlignment(.lawful, .neutral))
        #expect(player.name == "Frodo", "player name")
        #expect(player.className == "Fighter", "class name")
        #expect(player.speciesName == "Human", "species name")
        
        #expect(player.descriptiveTraits.count == 0, "descriptiveTraits")
        
        #expect(player.gender == Player.Gender.female, "gender")
        #expect(player.alignment == CharacterAlignment(.lawful, .neutral), "alignment")
        
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
        
        #expect((50...200).contains(player.inventory.money.value), "money \(player.inventory.money.value)")
        
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
            "inventory": { "money": 130 },
            "maximum hit points": 10
        }
        """.data(using: .utf8)!
        
        let player = try decoder.decode(Player.self, from: playerTraits, configuration: gameData)
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
        
        #expect(player.inventory.money.value == 130, "money")
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
            "inventory": { "money": 130 },
            "maximum hit points": 10,
            "experience points": 2300,
            "level": 2
        }
        """.data(using: .utf8)!
        
        let player = try decoder.decode(Player.self, from: playerTraits, configuration: gameData)
        player.speciesTraits = human
        player.classTraits = fighter
        
        #expect(player.gender == nil, "gender")
        #expect(player.alignment == CharacterAlignment(.lawful, .evil), "alignment")
        
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
            "inventory": { "money": 130 },
            "maximum hit points": 20,
            "current hit points": 9,
            "level": 2
        }
        """.data(using: .utf8)!
        
        let player = try #require(try? decoder.decode(Player.self, from: playerTraits, configuration: gameData))
        let encoder = JSONEncoder()
        let encodedPlayer = try encoder.encode(player, configuration: gameData)
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
        
        let inventoryDict = try #require(encoded["inventory"] as? [String: Any])
        #expect(inventoryDict["money"] as? String == "130.0 gp", "player traits round trip money")
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
            "inventory": { "money": 130 }]
        }
        """
    ])
    func missingTraits(json: String) async throws {
        let traits = json.data(using: .utf8)!
        let player = try? decoder.decode(Player.self, from: traits, configuration: gameData)
        #expect(player == nil)
    }
    
    func expectedModifier(for abilityScore: Int) -> Int {
        let selfMinus10 = abilityScore - 10
        return selfMinus10 < 0 ? Int((Double(selfMinus10) / 2.0).rounded(.down)) : selfMinus10 / 2
    }
    
    @Test("Verify computed properties")
    func computedProperties() async throws {
        let player = Player("Gandalf", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male, alignment: CharacterAlignment(.neutral, .good))
        
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
        let player1 = Player("Gimli", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male, alignment: CharacterAlignment(.lawful, .good))
        player1.descriptiveTraits = ["ideal": "Honor", "bond": "My axe"]
        
        let player2 = Player("Gimli", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter, gender: .male, alignment: CharacterAlignment(.lawful, .good))
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
            "inventory": { "money": 100 },
            "maximum hit points": 12
        }
        """.data(using: .utf8)!
        
        let player = try decoder.decode(Player.self, from: playerTraits, configuration: gameData)
        #expect(player.descriptiveTraits.count == 3)
        #expect(player.descriptiveTraits["ideal"] == "Adventure")
        #expect(player.descriptiveTraits["bond"] == "The Shire")
        #expect(player.descriptiveTraits["flaw"] == "Impulsive")
        
        // Test encoding
        let encoded = try encoder.encode(player, configuration: gameData)
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
            "inventory": { "money": 100 },
            "maximum hit points": 12,
            "experience points": 0,
            "level": 1
        }
        """.data(using: .utf8)!

        let player = try decoder.decode(Player.self, from: playerTraits, configuration: gameData)
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

    // MARK: - LevelUpResult and selectSubclass

    // MARK: - Rest mechanics

    @Test("Short rest spends hit dice and heals HP")
    func shortRestHealsHP() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let initialMax = player.maximumHitPoints
        player.currentHitPoints = 1                    // nearly dead

        let result = player.shortRest(hitDiceToSpend: 1)

        #expect(result.hitDiceSpent == 1)
        #expect(result.hitPointsGained >= 0)
        #expect(player.currentHitPoints >= 1)
        #expect(player.currentHitPoints <= initialMax)
        #expect(player.usedHitDice == 1)
        #expect(player.availableHitDice == player.level - 1)
    }

    @Test("Short rest caps healing at maximum HP")
    func shortRestCapsAtMaxHP() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        // Start at full HP — spending dice should not overheal.
        let result = player.shortRest(hitDiceToSpend: 1)
        #expect(result.hitDiceSpent == 1)
        #expect(result.hitPointsGained == 0)
        #expect(player.currentHitPoints == player.maximumHitPoints)
    }

    @Test("Short rest with zero available hit dice gains nothing")
    func shortRestNoAvailableDice() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player.currentHitPoints = 1
        player.usedHitDice = player.level             // exhaust the entire pool

        let result = player.shortRest(hitDiceToSpend: 1)

        #expect(result.hitDiceSpent == 0)
        #expect(result.hitPointsGained == 0)
        #expect(player.currentHitPoints == 1)
        #expect(player.usedHitDice == player.level)
    }

    @Test("Short rest clamps requested dice to available pool")
    func shortRestClampsToAvailable() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player.currentHitPoints = 1
        // Level 1 fighter has 1 hit die total; requesting 5 should spend at most 1.
        let result = player.shortRest(hitDiceToSpend: 5)
        #expect(result.hitDiceSpent == 1)
        #expect(player.usedHitDice == 1)
    }

    @Test("Long rest restores full HP")
    func longRestRestoresHP() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player.currentHitPoints = 1
        player.longRest()
        #expect(player.currentHitPoints == player.maximumHitPoints)
    }

    @Test("Long rest resets used hit dice")
    func longRestResetsHitDice() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player.currentHitPoints = 1
        player.shortRest(hitDiceToSpend: 1)
        #expect(player.usedHitDice == 1)

        player.currentHitPoints = 1
        player.longRest()
        #expect(player.usedHitDice == 0)
        #expect(player.availableHitDice == player.level)
    }

    @Test("Short rest result round-trips through encode/decode")
    func usedHitDiceRoundTrip() async throws {
        let playerTraits = """
        {
            "name": "Bilbo",
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "height": "3'9\\"",
            "ability scores": {"Strength": 12},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skill proficiencies": ["Athletics"],
            "inventory": { "money": 130 },
            "maximum hit points": 10,
            "current hit points": 7,
            "used hit dice": 1,
            "level": 2
        }
        """.data(using: .utf8)!

        let player = try decoder.decode(Player.self, from: playerTraits, configuration: gameData)
        #expect(player.usedHitDice == 1)
        #expect(player.availableHitDice == 1)  // level 2, 1 used

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(player, configuration: gameData)
        let dict = try #require(try? JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        #expect(dict["used hit dice"] as? Int == 1)
    }

    @Test("Used hit dice not encoded when zero")
    func usedHitDiceOmittedWhenZero() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(player, configuration: gameData)
        let dict = try #require(try? JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        #expect(dict["used hit dice"] == nil)
    }

    @Test("levelUp returns nil when canLevelUp is false")
    func levelUpReturnsNilWhenBlocked() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player.experiencePoints = 0
        #expect(player.canLevelUp == false)
        let result = player.levelUp()
        #expect(result == nil)
        #expect(player.level == 1)
    }

    @Test("levelUp returns result with correct new level and HP gained")
    func levelUpResult() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let initialMax = player.maximumHitPoints
        let initialCurrent = player.currentHitPoints
        player.experiencePoints = 301

        let result = try #require(player.levelUp())
        #expect(result.newLevel == 2)
        #expect(result.hitPointsGained > 0)
        #expect(player.maximumHitPoints == initialMax + result.hitPointsGained)
        #expect(player.currentHitPoints == initialCurrent + result.hitPointsGained)
    }

    @Test("levelUp updates currentHitPoints to match HP gained")
    func levelUpUpdatesCurrentHP() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        // Injure the player; current HP should increase by the same amount as max HP on level-up.
        player.currentHitPoints = player.maximumHitPoints - 4
        let injuryGap = player.maximumHitPoints - player.currentHitPoints
        player.experiencePoints = 301

        let result = try #require(player.levelUp())
        #expect(player.maximumHitPoints - player.currentHitPoints == injuryGap, "injury gap should be preserved")
        #expect(player.currentHitPoints == player.maximumHitPoints - injuryGap)
        #expect(result.hitPointsGained > 0)
    }

    @Test("levelUp grants general feat at levels 4, 8, 12, 16, 19", arguments: [4, 8, 12, 16, 19])
    func levelUpGrantsGeneralFeat(targetLevel: Int) async throws {
        // Use a full 20-level XP table so all target levels are reachable.
        let fullClassData = """
        {
            "name": "Fighter",
            "plural": "Fighters",
            "hit dice": "d10",
            "primary ability": ["Strength"],
            "saving throws": ["Strength", "Constitution"],
            "starting wealth": "5d4x10",
            "experience points": [0, 300, 900, 2700, 6500, 14000, 23000, 34000,
                                   48000, 64000, 85000, 100000, 120000, 140000,
                                   165000, 195000, 225000, 265000, 305000, 355000]
        }
        """.data(using: .utf8)!
        let fullFighter = try decoder.decode(ClassTraits.self, from: fullClassData, configuration: gameData)

        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fullFighter)
        player.level = targetLevel - 1
        player.experiencePoints = fullFighter.minExperiencePoints(at: targetLevel) + 1

        let result = try #require(player.levelUp())
        #expect(result.featCategoryToSelect == .general)
        #expect(result.newLevel == targetLevel)
    }

    @Test("levelUp grants epic boon at level 20")
    func levelUpGrantsEpicBoon() async throws {
        let fullClassData = """
        {
            "name": "Fighter",
            "plural": "Fighters",
            "hit dice": "d10",
            "primary ability": ["Strength"],
            "saving throws": ["Strength", "Constitution"],
            "starting wealth": "5d4x10",
            "experience points": [0, 300, 900, 2700, 6500, 14000, 23000, 34000,
                                   48000, 64000, 85000, 100000, 120000, 140000,
                                   165000, 195000, 225000, 265000, 305000, 355000]
        }
        """.data(using: .utf8)!
        let fullFighter = try decoder.decode(ClassTraits.self, from: fullClassData, configuration: gameData)

        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fullFighter)
        player.level = 19
        player.experiencePoints = 355001

        let result = try #require(player.levelUp())
        #expect(result.newLevel == 20)
        #expect(result.featCategoryToSelect == .epicBoon)
    }

    @Test("levelUp grants no feat at non-feat levels")
    func levelUpNoFeatAtOtherLevels() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player.experiencePoints = 301  // enough for level 2

        let result = try #require(player.levelUp())
        #expect(result.newLevel == 2)
        #expect(result.featCategoryToSelect == nil)
    }

    @Test("levelUp signals subclass selection at subclassChoiceLevel")
    func levelUpRequiresSubclassSelection() async throws {
        let classWithSubclasses = """
        {
            "name": "Fighter",
            "plural": "Fighters",
            "hit dice": "d10",
            "primary ability": ["Strength"],
            "saving throws": ["Strength", "Constitution"],
            "starting wealth": "5d4x10",
            "experience points": [0, 300, 900, 2700],
            "subclass title": "Martial Archetype",
            "subclass choice level": 3,
            "subclasses": [
                { "name": "Champion" },
                { "name": "Battle Master" }
            ]
        }
        """.data(using: .utf8)!
        let archetypeFighter = try decoder.decode(ClassTraits.self, from: classWithSubclasses, configuration: gameData)

        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: archetypeFighter)
        player.level = 2
        player.experiencePoints = 901

        let result = try #require(player.levelUp())
        #expect(result.newLevel == 3)
        #expect(result.requiresSubclassSelection == true)
    }

    @Test("levelUp does not signal subclass selection at non-triggering levels")
    func levelUpNoSubclassSelectionOtherLevels() async throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        player.experiencePoints = 301

        let result = try #require(player.levelUp())
        #expect(result.requiresSubclassSelection == false)
    }

    @Test("selectSubclass assigns subclass when valid")
    func selectSubclassValid() async throws {
        let classWithSubclasses = """
        {
            "name": "Fighter",
            "plural": "Fighters",
            "hit dice": "d10",
            "primary ability": ["Strength"],
            "saving throws": ["Strength", "Constitution"],
            "starting wealth": "5d4x10",
            "experience points": [0, 300, 900, 2700],
            "subclass choice level": 3,
            "subclasses": [{ "name": "Champion" }]
        }
        """.data(using: .utf8)!
        let archetypeFighter = try decoder.decode(ClassTraits.self, from: classWithSubclasses, configuration: gameData)
        let champion = archetypeFighter.subclasses[0]

        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: archetypeFighter)
        player.level = 3
        #expect(player.subclassTraits == nil)

        player.selectSubclass(champion)
        #expect(player.subclassTraits == champion)
        #expect(player.subclassName == "Champion")
    }

    @Test("selectSubclass ignores subclass not belonging to class")
    func selectSubclassWrongClass() async throws {
        let classWithSubclasses = """
        {
            "name": "Fighter",
            "plural": "Fighters",
            "hit dice": "d10",
            "primary ability": ["Strength"],
            "saving throws": ["Strength", "Constitution"],
            "starting wealth": "5d4x10",
            "experience points": [0, 300, 900, 2700],
            "subclass choice level": 3,
            "subclasses": [{ "name": "Champion" }]
        }
        """.data(using: .utf8)!
        let archetypeFighter = try decoder.decode(ClassTraits.self, from: classWithSubclasses, configuration: gameData)

        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: archetypeFighter)
        player.level = 3

        let foreignSubclass = SubclassTraits(name: "Life Domain")
        player.selectSubclass(foreignSubclass)
        #expect(player.subclassTraits == nil, "subclass from another class should be rejected")
    }

    @Test("selectSubclass ignores call when level is too low")
    func selectSubclassLevelTooLow() async throws {
        let classWithSubclasses = """
        {
            "name": "Fighter",
            "plural": "Fighters",
            "hit dice": "d10",
            "primary ability": ["Strength"],
            "saving throws": ["Strength", "Constitution"],
            "starting wealth": "5d4x10",
            "experience points": [0, 300, 900, 2700],
            "subclass choice level": 3,
            "subclasses": [{ "name": "Champion" }]
        }
        """.data(using: .utf8)!
        let archetypeFighter = try decoder.decode(ClassTraits.self, from: classWithSubclasses, configuration: gameData)
        let champion = archetypeFighter.subclasses[0]

        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: archetypeFighter)
        player.level = 2

        player.selectSubclass(champion)
        #expect(player.subclassTraits == nil, "subclass selection should be ignored below required level")
    }

    // MARK: - Inventory Mutation

    @Test("addToInventory creates new entry for unknown item")
    func addToInventoryNewEntry() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let countBefore = player.inventory.entries.count
        let longsword = gameData.items["Longsword"]!
        player.inventory.add(longsword)
        #expect(player.inventory.entries.count == countBefore + 1)
        #expect(player.inventory.entries.last?.item.name == "Longsword")
        #expect(player.inventory.entries.last?.quantity == 1)
    }

    @Test("addToInventory stacks quantity with existing entry for same item")
    func addToInventoryStacksExisting() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let arrow = gameData.items["Arrow"]!
        let arrowEntry = player.inventory.entries.first(where: { $0.item.name == "Arrow" })
        let originalQuantity = arrowEntry?.quantity ?? 0
        let countBefore = player.inventory.entries.count

        player.inventory.add(arrow, quantity: 5)
        #expect(player.inventory.entries.count == countBefore, "no new entry should be created")
        let updated = player.inventory.entries.first(where: { $0.item.name == "Arrow" })
        #expect(updated?.quantity == originalQuantity + 5)
    }

    @Test("addToInventory with quantity 1 is the default")
    func addToInventoryDefaultQuantity() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let dagger = gameData.items["Dagger"]!
        player.inventory.add(dagger)
        #expect(player.inventory.entries.first(where: { $0.item.name == "Dagger" })?.quantity == 1)
    }

    @Test("addToInventory ignores zero or negative quantity")
    func addToInventoryIgnoresNonPositive() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let countBefore = player.inventory.entries.count
        let longsword = gameData.items["Longsword"]!
        player.inventory.add(longsword, quantity: 0)
        player.inventory.add(longsword, quantity: -3)
        #expect(player.inventory.entries.count == countBefore)
    }

    @Test("removeFromInventory removes entry by ID")
    func removeFromInventory() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let longsword = gameData.items["Longsword"]!
        player.inventory.add(longsword)
        let id = player.inventory.entries.first(where: { $0.item.name == "Longsword" })!.id
        let countBefore = player.inventory.entries.count

        player.inventory.remove(id: id)
        #expect(player.inventory.entries.count == countBefore - 1)
        #expect(player.inventory.entries.first(where: { $0.item.name == "Longsword" }) == nil)
    }

    @Test("removeFromInventory ignores unknown ID")
    func removeFromInventoryUnknownID() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let countBefore = player.inventory.entries.count
        player.inventory.remove(id: UUID())
        #expect(player.inventory.entries.count == countBefore)
    }

    @Test("equipItem sets isEquipped on the entry")
    func equipItem() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let leatherArmor = gameData.items["Leather Armor"]!
        player.inventory.add(leatherArmor)
        let id = player.inventory.entries.first(where: { $0.item.name == "Leather Armor" })!.id

        player.inventory.equip(id: id)
        #expect(player.inventory.entries.first(where: { $0.item.name == "Leather Armor" })?.isEquipped == true)
    }

    @Test("equipItem auto-unequips conflicting non-shield armor")
    func equipItemUnequipsConflictingArmor() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let chainMail = gameData.items["Chain Mail"]!
        let leatherArmor = gameData.items["Leather Armor"]!
        player.inventory.add(chainMail)
        player.inventory.add(leatherArmor)

        let chainID = player.inventory.entries.first(where: { $0.item.name == "Chain Mail" })!.id
        let leatherID = player.inventory.entries.first(where: { $0.item.name == "Leather Armor" })!.id

        player.inventory.equip(id: chainID)
        #expect(player.inventory.equippedArmor?.name == "Chain Mail")

        player.inventory.equip(id: leatherID)
        #expect(player.inventory.equippedArmor?.name == "Leather Armor", "leather should now be equipped")
        #expect(player.inventory.entries.first(where: { $0.item.name == "Chain Mail" })?.isEquipped == false, "chain mail should be auto-unequipped")
    }

    @Test("equipItem auto-unequips conflicting shield")
    func equipItemUnequipsConflictingShield() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let shield1 = gameData.items["Shield"]!
        player.inventory.add(shield1, quantity: 2)
        // Two separate entries wouldn't happen with stacking, so add via two different paths:
        // Re-add after removing to get a second distinct entry
        let firstShieldID = player.inventory.entries.first(where: { $0.item.name == "Shield" })!.id
        player.inventory.equip(id: firstShieldID)
        #expect(player.inventory.equippedShield != nil)

        // Remove equipped shield and add a fresh one to get a new ID
        player.inventory.remove(id: firstShieldID)
        player.inventory.add(shield1)
        let secondShieldID = player.inventory.entries.first(where: { $0.item.name == "Shield" })!.id
        player.inventory.equip(id: secondShieldID)
        #expect(player.inventory.equippedShield?.name == "Shield")
        let equippedCount = player.inventory.entries.filter { $0.isEquipped && ($0.item as? Armor)?.category == .shield }.count
        #expect(equippedCount == 1, "only one shield should be equipped at a time")
    }

    @Test("unequipItem clears isEquipped")
    func unequipItem() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let leatherArmor = gameData.items["Leather Armor"]!
        player.inventory.add(leatherArmor)
        let id = player.inventory.entries.first(where: { $0.item.name == "Leather Armor" })!.id
        player.inventory.equip(id: id)
        #expect(player.inventory.equippedArmor != nil)

        player.inventory.unequip(id: id)
        #expect(player.inventory.equippedArmor == nil)
    }

    @Test("adjustQuantity updates the quantity of an entry")
    func adjustQuantity() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let arrowEntry = player.inventory.entries.first(where: { $0.item.name == "Arrow" })!
        player.inventory.adjustQuantity(50, for: arrowEntry.id)
        #expect(player.inventory.entries.first(where: { $0.item.name == "Arrow" })?.quantity == 50)
    }

    @Test("adjustQuantity removes entry when quantity is zero")
    func adjustQuantityRemovesAtZero() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let countBefore = player.inventory.entries.count
        let spearID = player.inventory.entries.first(where: { $0.item.name == "Spear" })!.id
        player.inventory.adjustQuantity(0, for: spearID)
        #expect(player.inventory.entries.count == countBefore - 1)
        #expect(player.inventory.entries.first(where: { $0.item.name == "Spear" }) == nil)
    }

    @Test("adjustQuantity ignores unknown ID")
    func adjustQuantityUnknownID() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let countBefore = player.inventory.entries.count
        player.inventory.adjustQuantity(99, for: UUID())
        #expect(player.inventory.entries.count == countBefore)
    }

    // MARK: - Spellcasting

    @Test("Non-spellcasting class has nil spellcasting computed properties")
    func nonSpellcasterNilProperties() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        #expect(player.spellcastingAbility == nil)
        #expect(player.spellcastingModifier == nil)
        #expect(player.spellSaveDC == nil)
        #expect(player.spellAttackBonus == nil)
        #expect(player.maxPreparedSpells == nil)
    }

    @Test("Spellcasting class has correct computed properties")
    func spellcasterComputedProperties() throws {
        let clericTraits = """
        {
            "name": "Cleric",
            "plural": "Clerics",
            "hit dice": "d8",
            "starting wealth": "5d4x10",
            "spellcasting ability": "Wisdom",
            "spellcasting type": "prepared",
            "spell slots": [[2], [3], [4, 2]]
        }
        """.data(using: .utf8)!
        let cleric = try decoder.decode(ClassTraits.self, from: clericTraits, configuration: gameData)

        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: cleric)
        player.baseAbilities[.wisdom] = 16  // +3 modifier

        #expect(player.spellcastingAbility == Ability("Wisdom"))
        #expect(player.spellcastingModifier == 3)
        #expect(player.spellSaveDC == 8 + player.proficiencyBonus + 3)
        #expect(player.spellAttackBonus == player.proficiencyBonus + 3)
        #expect(player.maxPreparedSpells == max(1, 3 + player.level))
    }

    @Test("totalSpellSlots returns correct count for class level")
    func totalSpellSlots() throws {
        let clericTraits = """
        {
            "name": "Cleric",
            "plural": "Clerics",
            "hit dice": "d8",
            "starting wealth": "5d4x10",
            "spellcasting ability": "Wisdom",
            "spellcasting type": "prepared",
            "spell slots": [[2], [3], [4, 2], [4, 3]]
        }
        """.data(using: .utf8)!
        let cleric = try decoder.decode(ClassTraits.self, from: clericTraits, configuration: gameData)
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: cleric)

        player.level = 1
        #expect(player.totalSpellSlots(at: 1) == 2)
        #expect(player.totalSpellSlots(at: 2) == 0)

        player.level = 3
        #expect(player.totalSpellSlots(at: 1) == 4)
        #expect(player.totalSpellSlots(at: 2) == 2)

        // Out-of-range slot levels
        #expect(player.totalSpellSlots(at: 0) == 0)
        #expect(player.totalSpellSlots(at: 9) == 0)
    }

    @Test("castSpell expends a slot and returns true; returns false when exhausted")
    func castSpell() throws {
        let clericTraits = """
        {
            "name": "Cleric",
            "plural": "Clerics",
            "hit dice": "d8",
            "starting wealth": "5d4x10",
            "spellcasting ability": "Wisdom",
            "spellcasting type": "prepared",
            "spell slots": [[2]]
        }
        """.data(using: .utf8)!
        let cleric = try decoder.decode(ClassTraits.self, from: clericTraits, configuration: gameData)
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: cleric)

        #expect(player.totalSpellSlots(at: 1) == 2)
        #expect(player.availableSpellSlots(at: 1) == 2)

        #expect(player.castSpell(usingSlotLevel: 1) == true)
        #expect(player.availableSpellSlots(at: 1) == 1)

        #expect(player.castSpell(usingSlotLevel: 1) == true)
        #expect(player.availableSpellSlots(at: 1) == 0)

        #expect(player.castSpell(usingSlotLevel: 1) == false, "no slots remaining")
    }

    @Test("castSpell returns false when no spell slots exist at level")
    func castSpellNoSlots() throws {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        #expect(player.castSpell(usingSlotLevel: 1) == false)
    }

    @Test("prepareSpell adds spell; is idempotent")
    func prepareSpell() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let bless = gameData.spells["Bless"]!
        #expect(player.preparedSpells.isEmpty)

        player.prepareSpell(bless)
        #expect(player.preparedSpells.count == 1)

        player.prepareSpell(bless)
        #expect(player.preparedSpells.count == 1, "duplicate prepareSpell should be ignored")
    }

    @Test("unprepareSpell removes a prepared spell")
    func unprepareSpell() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let bless = gameData.spells["Bless"]!
        let fireball = gameData.spells["Fireball"]!
        player.prepareSpell(bless)
        player.prepareSpell(fireball)
        #expect(player.preparedSpells.count == 2)

        player.unprepareSpell(bless)
        #expect(player.preparedSpells.count == 1)
        #expect(player.preparedSpells.first?.name == "Fireball")

        player.unprepareSpell(bless)  // already removed — no-op
        #expect(player.preparedSpells.count == 1)
    }

    @Test("Long rest resets used spell slots")
    func longRestResetSpellSlots() throws {
        let clericTraits = """
        {
            "name": "Cleric",
            "plural": "Clerics",
            "hit dice": "d8",
            "starting wealth": "5d4x10",
            "spellcasting ability": "Wisdom",
            "spellcasting type": "prepared",
            "spell slots": [[2, 1]]
        }
        """.data(using: .utf8)!
        let cleric = try decoder.decode(ClassTraits.self, from: clericTraits, configuration: gameData)
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: cleric)

        player.castSpell(usingSlotLevel: 1)
        player.castSpell(usingSlotLevel: 2)
        #expect(!player.usedSpellSlots.isEmpty)

        player.longRest()
        #expect(player.usedSpellSlots.isEmpty)
        #expect(player.availableSpellSlots(at: 1) == 2)
        #expect(player.availableSpellSlots(at: 2) == 1)
    }

    @Test("Prepared spells survive encode/decode round-trip")
    func preparedSpellsRoundTrip() async throws {
        let playerTraits = """
        {
            "name": "Frodo",
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "height": "3'9\\"",
            "ability scores": {"Wisdom": 14},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skill proficiencies": ["Athletics"],
            "inventory": { "money": 130 },
            "maximum hit points": 10,
            "prepared spells": ["Bless", "Fireball"]
        }
        """.data(using: .utf8)!

        let player = try decoder.decode(Player.self, from: playerTraits, configuration: gameData)
        #expect(player.preparedSpells.count == 2)
        #expect(player.preparedSpells.contains(where: { $0.name == "Bless" }))
        #expect(player.preparedSpells.contains(where: { $0.name == "Fireball" }))

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(player, configuration: gameData)
        let dict = try #require(try? JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        let names = try #require(dict["prepared spells"] as? [String])
        #expect(Set(names) == Set(["Bless", "Fireball"]))
    }

    @Test("Unknown prepared spell name silently skipped on decode")
    func unknownPreparedSpellSkipped() async throws {
        let playerTraits = """
        {
            "name": "Frodo",
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "height": "3'9\\"",
            "ability scores": {},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skill proficiencies": ["Athletics"],
            "inventory": { "money": 130 },
            "maximum hit points": 10,
            "prepared spells": ["Bless", "Nonexistent Spell XYZ"]
        }
        """.data(using: .utf8)!

        let player = try decoder.decode(Player.self, from: playerTraits, configuration: gameData)
        #expect(player.preparedSpells.count == 1)
        #expect(player.preparedSpells.first?.name == "Bless")
    }

    @Test("Used spell slots survive encode/decode round-trip")
    func usedSpellSlotsRoundTrip() async throws {
        let playerTraits = """
        {
            "name": "Frodo",
            "background": "Sailor",
            "species": "Human",
            "class": "Fighter",
            "height": "3'9\\"",
            "ability scores": {},
            "background ability scores": ["Strength", "Strength", "Dexterity"],
            "skill proficiencies": ["Athletics"],
            "inventory": { "money": 130 },
            "maximum hit points": 10,
            "used spell slots": [1, 0, 2]
        }
        """.data(using: .utf8)!

        let player = try decoder.decode(Player.self, from: playerTraits, configuration: gameData)
        #expect(player.usedSpellSlots == [1, 0, 2])

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(player, configuration: gameData)
        let dict = try #require(try? JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        let slots = try #require(dict["used spell slots"] as? [Int])
        #expect(slots == [1, 0, 2])
    }

    @Test("Used spell slots not encoded when empty")
    func usedSpellSlotsOmittedWhenEmpty() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(player, configuration: gameData)
        let dict = try! JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        #expect(dict["used spell slots"] == nil)
    }

    // MARK: - Proficiency and feat properties

    @Test("allWeaponProficiencies combines class and feat proficiencies")
    func allWeaponProficiencies() {
        let classWithProfs = ClassTraits(
            name: "Fighter",
            plural: "Fighters",
            hitDice: .d10,
            startingWealth: Dice.d4,
            weaponProficiencies: [.category(.simple), .category(.martial)]
        )
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: classWithProfs)
        let featWithProf = FeatTraits(name: "Weapon Expert", weaponProficiencies: [.specific("Longsword")])
        player.feats = [featWithProf]

        // 2 from class + 1 from feat
        #expect(player.allWeaponProficiencies.count == 3)
    }

    @Test("allArmorTraining combines class and feat training")
    func allArmorTraining() {
        let classWithArmor = ClassTraits(
            name: "Fighter",
            plural: "Fighters",
            hitDice: .d10,
            startingWealth: Dice.d4,
            armorTraining: [.light, .medium]
        )
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: classWithArmor)
        let featWithArmor = FeatTraits(name: "Heavy Armor Master", armorTraining: [.heavy])
        player.feats = [featWithArmor]

        // 2 from class + 1 from feat
        #expect(player.allArmorTraining.count == 3)
    }

    @Test("featAbilityIncrease sums ability score increases across all feats")
    func featAbilityIncrease() {
        let player = Player("Tester", backgroundTraits: soldier, speciesTraits: human, classTraits: fighter)
        let feat1 = FeatTraits(name: "Tough", abilityScoreIncreases: [Ability("Strength"): 2])
        let feat2 = FeatTraits(name: "Alert", abilityScoreIncreases: [Ability("Strength"): 1, Ability("Wisdom"): 1])
        player.feats = [feat1, feat2]

        let increase = player.featAbilityIncrease
        #expect(increase[Ability("Strength")] == 3)
        #expect(increase[Ability("Wisdom")] == 1)
        #expect(increase[Ability("Dexterity")] == nil)
    }
}
