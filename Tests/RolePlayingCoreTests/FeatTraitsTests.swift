//
//  FeatTraitsTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("FeatTraits Tests")
struct FeatTraitsTests {

    let decoder = JSONDecoder()
    let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = .sortedKeys
        return e
    }()

    // MARK: - Category enum

    @Test("Category raw values")
    func categoryRawValues() {
        #expect(FeatTraits.Category.origin.rawValue == "origin")
        #expect(FeatTraits.Category.general.rawValue == "general")
        #expect(FeatTraits.Category.fightingStyle.rawValue == "fighting style")
        #expect(FeatTraits.Category.epicBoon.rawValue == "epic boon")
    }

    @Test("Category CaseIterable contains all four cases")
    func categoryCaseIterable() {
        let all = FeatTraits.Category.allCases
        #expect(all.count == 4)
        #expect(all.contains(.origin))
        #expect(all.contains(.general))
        #expect(all.contains(.fightingStyle))
        #expect(all.contains(.epicBoon))
    }

    // MARK: - Init

    @Test("Init with defaults")
    func initDefaults() {
        let feat = FeatTraits(name: "Alert")
        #expect(feat.name == "Alert")
        #expect(feat.description == "")
        #expect(feat.category == .general)
    }

    @Test("Init with all properties")
    func initFull() {
        let feat = FeatTraits(name: "Magic Initiate", description: "Learn spells from a class.", category: .origin)
        #expect(feat.name == "Magic Initiate")
        #expect(feat.description == "Learn spells from a class.")
        #expect(feat.category == .origin)
    }

    @Test("Init defaults: empty mechanical effect fields")
    func initDefaultMechanicalFields() {
        let feat = FeatTraits(name: "Alert")
        #expect(feat.abilityScoreIncreases.isEmpty)
        #expect(feat.weaponProficiencies.isEmpty)
        #expect(feat.armorTraining.isEmpty)
    }

    @Test("Init with mechanical effects")
    func initWithMechanicalEffects() {
        let feat = FeatTraits(
            name: "Lightly Armored",
            category: .general,
            abilityScoreIncreases: [.strength: 1],
            weaponProficiencies: [.category(WeaponCategory("simple"))],
            armorTraining: [.light]
        )
        #expect(feat.abilityScoreIncreases[.strength] == 1)
        #expect(feat.weaponProficiencies.count == 1)
        #expect(feat.armorTraining == [.light])
    }

    // MARK: - Equatable

    @Test("Equatable: identical instances are equal")
    func equatable() {
        let a = FeatTraits(name: "Alert", description: "Init bonus", category: .general)
        let b = FeatTraits(name: "Alert", description: "Init bonus", category: .general)
        #expect(a == b)
    }

    @Test("Equatable: different names are not equal")
    func notEqualByName() {
        let a = FeatTraits(name: "Alert")
        let b = FeatTraits(name: "Lucky")
        #expect(a != b)
    }

    @Test("Equatable: same name but different category are not equal")
    func notEqualByCategory() {
        let a = FeatTraits(name: "Feat", category: .origin)
        let b = FeatTraits(name: "Feat", category: .general)
        #expect(a != b)
    }

    // MARK: - Codable decode

    @Test("Decode with all fields present")
    func decodeAllFields() throws {
        let json = """
        {
            "name": "Savage Attacker",
            "description": "Reroll damage dice once per turn.",
            "category": "origin"
        }
        """.data(using: .utf8)!

        let feat = try decoder.decode(FeatTraits.self, from: json)
        #expect(feat.name == "Savage Attacker")
        #expect(feat.description == "Reroll damage dice once per turn.")
        #expect(feat.category == .origin)
        #expect(feat.abilityScoreIncreases.isEmpty)
        #expect(feat.weaponProficiencies.isEmpty)
        #expect(feat.armorTraining.isEmpty)
    }

    @Test("Decode ability score increases")
    func decodeAbilityScoreIncreases() throws {
        let json = """
        {
            "name": "Athlete",
            "ability score increases": { "Strength": 1, "Dexterity": 1 }
        }
        """.data(using: .utf8)!

        let feat = try decoder.decode(FeatTraits.self, from: json)
        #expect(feat.abilityScoreIncreases[.strength] == 1)
        #expect(feat.abilityScoreIncreases[.dexterity] == 1)
        #expect(feat.abilityScoreIncreases.count == 2)
    }

    @Test("Decode weapon proficiencies")
    func decodeWeaponProficiencies() throws {
        let json = """
        {
            "name": "Weapon Master",
            "weapon proficiencies": ["simple", "Longsword"]
        }
        """.data(using: .utf8)!

        let feat = try decoder.decode(FeatTraits.self, from: json)
        #expect(feat.weaponProficiencies.count == 2)
    }

    @Test("Decode armor training")
    func decodeArmorTraining() throws {
        let json = """
        {
            "name": "Lightly Armored",
            "armor training": ["light"]
        }
        """.data(using: .utf8)!

        let feat = try decoder.decode(FeatTraits.self, from: json)
        #expect(feat.armorTraining == [.light])
    }

    @Test("Decode with only name defaults description and category")
    func decodeNameOnly() throws {
        let json = """
        { "name": "Tough" }
        """.data(using: .utf8)!

        let feat = try decoder.decode(FeatTraits.self, from: json)
        #expect(feat.name == "Tough")
        #expect(feat.description == "")
        #expect(feat.category == .general)
    }

    @Test("Decode fighting style category")
    func decodeFightingStyle() throws {
        let json = """
        { "name": "Archery", "category": "fighting style" }
        """.data(using: .utf8)!

        let feat = try decoder.decode(FeatTraits.self, from: json)
        #expect(feat.category == .fightingStyle)
    }

    @Test("Decode epic boon category")
    func decodeEpicBoon() throws {
        let json = """
        { "name": "Epic Boon of the Night Spirit", "category": "epic boon" }
        """.data(using: .utf8)!

        let feat = try decoder.decode(FeatTraits.self, from: json)
        #expect(feat.category == .epicBoon)
    }

    // MARK: - Codable encode (omits defaults)

    @Test("Encode omits empty description")
    func encodeOmitsEmptyDescription() throws {
        let feat = FeatTraits(name: "Alert")
        let data = try encoder.encode(feat)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["description"] == nil, "Empty description should be omitted")
    }

    @Test("Encode omits default .general category")
    func encodeOmitsGeneralCategory() throws {
        let feat = FeatTraits(name: "Lucky", category: .general)
        let data = try encoder.encode(feat)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["category"] == nil, ".general category should be omitted")
    }

    @Test("Encode includes non-default category")
    func encodeIncludesNonDefaultCategory() throws {
        let feat = FeatTraits(name: "Sailor", category: .origin)
        let data = try encoder.encode(feat)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["category"] as? String == "origin")
    }

    @Test("Encode includes non-empty description")
    func encodeIncludesDescription() throws {
        let feat = FeatTraits(name: "Tough", description: "Gain extra HP.")
        let data = try encoder.encode(feat)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["description"] as? String == "Gain extra HP.")
    }

    @Test("Encode omits empty mechanical fields")
    func encodeOmitsMechanicalFieldsWhenEmpty() throws {
        let feat = FeatTraits(name: "Alert")
        let data = try encoder.encode(feat)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["ability score increases"] == nil)
        #expect(dict["weapon proficiencies"] == nil)
        #expect(dict["armor training"] == nil)
    }

    @Test("Encode includes ability score increases")
    func encodeAbilityScoreIncreases() throws {
        let feat = FeatTraits(name: "Athlete", abilityScoreIncreases: [.strength: 1])
        let data = try encoder.encode(feat)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        let increases = try #require(dict["ability score increases"] as? [String: Int])
        #expect(increases["Strength"] == 1)
    }

    @Test("Encode includes armor training")
    func encodeArmorTraining() throws {
        let feat = FeatTraits(name: "Lightly Armored", armorTraining: [.light])
        let data = try encoder.encode(feat)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        let training = try #require(dict["armor training"] as? [String])
        #expect(training == ["light"])
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        let original = FeatTraits(name: "Magic Initiate", description: "Learn spells.", category: .origin)
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(FeatTraits.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip with mechanical effects")
    func codableRoundTripMechanicalEffects() throws {
        let original = FeatTraits(
            name: "Lightly Armored",
            category: .general,
            abilityScoreIncreases: [.strength: 1],
            weaponProficiencies: [.category(WeaponCategory("simple"))],
            armorTraining: [.light]
        )
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(FeatTraits.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - Feats collection

    @Test("Feats init with empty array")
    func featsEmpty() {
        let feats = Feats()
        #expect(feats.count == 0)
        #expect(feats.all.isEmpty)
        #expect(feats["Alert"] == nil)
    }

    @Test("Feats init with array stores and retrieves by name")
    func featsInit() {
        let alert = FeatTraits(name: "Alert")
        let lucky = FeatTraits(name: "Lucky", category: .general)
        let feats = Feats([alert, lucky])
        #expect(feats.count == 2)
        #expect(feats["Alert"]?.name == "Alert")
        #expect(feats["Lucky"]?.name == "Lucky")
        #expect(feats["Unknown"] == nil)
    }

    @Test("Feats deduplicates by name (last wins)")
    func featsDeduplicates() {
        let v1 = FeatTraits(name: "Tough", description: "Version 1")
        let v2 = FeatTraits(name: "Tough", description: "Version 2")
        let feats = Feats([v1, v2])
        #expect(feats.count == 1)
        #expect(feats["Tough"]?.description == "Version 2")
    }

    @Test("feats(ofCategory:) returns only matching feats sorted by name")
    func featsOfCategory() {
        let alert = FeatTraits(name: "Alert", category: .general)
        let lucky = FeatTraits(name: "Lucky", category: .general)
        let tough = FeatTraits(name: "Tough", category: .general)
        let magicInitiate = FeatTraits(name: "Magic Initiate", category: .origin)
        let epicBoon = FeatTraits(name: "Epic Boon of Combat", category: .epicBoon)
        let feats = Feats([alert, lucky, tough, magicInitiate, epicBoon])

        let generals = feats.feats(ofCategory: .general)
        #expect(generals.count == 3)
        #expect(generals.map(\.name) == ["Alert", "Lucky", "Tough"])

        let origins = feats.feats(ofCategory: .origin)
        #expect(origins.count == 1)
        #expect(origins[0].name == "Magic Initiate")

        #expect(feats.feats(ofCategory: .fightingStyle).isEmpty)
    }

    @Test("Feats Codable round-trip")
    func featsRoundTrip() throws {
        let json = """
        {
            "feats": [
                { "name": "Alert" },
                { "name": "Tough", "description": "Gain HP." },
                { "name": "Magic Initiate", "category": "origin" }
            ]
        }
        """.data(using: .utf8)!

        let feats = try decoder.decode(Feats.self, from: json)
        #expect(feats.count == 3)
        #expect(feats["Alert"]?.category == .general)
        #expect(feats["Tough"]?.description == "Gain HP.")
        #expect(feats["Magic Initiate"]?.category == .origin)

        let encodedData = try encoder.encode(feats)
        let decoded = try decoder.decode(Feats.self, from: encodedData)
        #expect(decoded.count == feats.count)
        #expect(decoded["Alert"] == feats["Alert"])
        #expect(decoded["Tough"] == feats["Tough"])
    }
}
