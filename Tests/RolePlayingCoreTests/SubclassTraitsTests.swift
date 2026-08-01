//
//  SubclassTraitsTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("SubclassTraits Tests")
struct SubclassTraitsTests {

    let decoder = JSONDecoder()
    let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = .sortedKeys
        return e
    }()

    // MARK: - Init

    @Test("Init with defaults")
    func initDefaults() {
        let sub = SubclassTraits(name: "Life Domain")
        #expect(sub.name == "Life Domain")
        #expect(sub.descriptiveTraits.isEmpty)
        #expect(sub.features.isEmpty)
        #expect(sub.additionalSpells == nil)
    }

    @Test("Init with all properties")
    func initFull() {
        let sub = SubclassTraits(
            name: "Thief",
            descriptiveTraits: ["role": "Roguish archetype"],
            features: [3: ["Fast Hands", "Second-Story Work"], 9: ["Supreme Sneak"]],
            additionalSpells: nil
        )
        #expect(sub.name == "Thief")
        #expect(sub.descriptiveTraits["role"] == "Roguish archetype")
        #expect(sub.features[3]?.contains("Fast Hands") == true)
        #expect(sub.features[9]?.contains("Supreme Sneak") == true)
    }

    // MARK: - Equatable

    @Test("Equatable: identical instances are equal")
    func equatable() {
        let a = SubclassTraits(name: "Life Domain", features: [3: ["Disciple of Life"]])
        let b = SubclassTraits(name: "Life Domain", features: [3: ["Disciple of Life"]])
        #expect(a == b)
    }

    @Test("Equatable: different names are not equal")
    func notEquatable() {
        let a = SubclassTraits(name: "Life Domain")
        let b = SubclassTraits(name: "Death Domain")
        #expect(a != b)
    }

    // MARK: - Codable: features only

    @Test("Decode features with string level keys converted to Int")
    func decodeFeaturesStringKeys() throws {
        let json = """
        {
            "name": "Thief",
            "features": {
                "3": ["Fast Hands", "Second-Story Work"],
                "9": ["Supreme Sneak"],
                "13": ["Use Magic Device"]
            }
        }
        """.data(using: .utf8)!

        let sub = try decoder.decode(SubclassTraits.self, from: json)
        #expect(sub.name == "Thief")
        #expect(sub.features[3]?.count == 2)
        #expect(sub.features[3]?.contains("Fast Hands") == true)
        #expect(sub.features[3]?.contains("Second-Story Work") == true)
        #expect(sub.features[9]?.first == "Supreme Sneak")
        #expect(sub.features[13]?.first == "Use Magic Device")
        #expect(sub.additionalSpells == nil)
    }

    @Test("Decode with descriptive traits")
    func decodeDescriptiveTraits() throws {
        let json = """
        {
            "name": "Berserker",
            "descriptive traits": {
                "flavor": "Primal rage and fury"
            },
            "features": {
                "3": ["Frenzy"]
            }
        }
        """.data(using: .utf8)!

        let sub = try decoder.decode(SubclassTraits.self, from: json)
        #expect(sub.descriptiveTraits["flavor"] == "Primal rage and fury")
        #expect(sub.features[3]?.first == "Frenzy")
    }

    // MARK: - Codable: with additionalSpells

    @Test("Decode additional spells with string level keys")
    func decodeAdditionalSpells() throws {
        let json = """
        {
            "name": "Life Domain",
            "features": {
                "3": ["Disciple of Life"],
                "6": ["Blessed Healer"]
            },
            "additional spells": {
                "3": ["Bless", "Cure Wounds"],
                "5": ["Lesser Restoration", "Spiritual Weapon"]
            }
        }
        """.data(using: .utf8)!

        let sub = try decoder.decode(SubclassTraits.self, from: json)
        #expect(sub.name == "Life Domain")
        let spells3 = try #require(sub.additionalSpells?[3])
        #expect(spells3.contains("Bless"))
        #expect(spells3.contains("Cure Wounds"))
        let spells5 = try #require(sub.additionalSpells?[5])
        #expect(spells5.contains("Lesser Restoration"))
    }

    // MARK: - Codable: encode / round-trip

    @Test("Encode omits empty descriptiveTraits")
    func encodeOmitsEmptyDescriptiveTraits() throws {
        let sub = SubclassTraits(name: "Thief", features: [3: ["Fast Hands"]])
        let data = try encoder.encode(sub)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["descriptive traits"] == nil, "Empty descriptiveTraits should be omitted")
    }

    @Test("Encode omits empty features")
    func encodeOmitsEmptyFeatures() throws {
        let sub = SubclassTraits(name: "Placeholder")
        let data = try encoder.encode(sub)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["features"] == nil, "Empty features should be omitted")
    }

    @Test("Codable round-trip preserves all data")
    func codableRoundTrip() throws {
        let original = SubclassTraits(
            name: "Life Domain",
            descriptiveTraits: ["role": "Healer"],
            features: [3: ["Disciple of Life"], 6: ["Blessed Healer"]],
            additionalSpells: [3: ["Bless", "Cure Wounds"]]
        )

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(SubclassTraits.self, from: data)

        #expect(decoded == original)
        #expect(decoded.descriptiveTraits["role"] == "Healer")
        #expect(decoded.features[3]?.contains("Disciple of Life") == true)
        let spells = try #require(decoded.additionalSpells?[3])
        #expect(spells.contains("Bless"))
    }

    @Test("Non-integer string feature keys are silently dropped")
    func nonIntegerKeysDropped() throws {
        let json = """
        {
            "name": "Test",
            "features": {
                "3": ["Valid Feature"],
                "abc": ["Invalid Key Feature"]
            }
        }
        """.data(using: .utf8)!

        let sub = try decoder.decode(SubclassTraits.self, from: json)
        #expect(sub.features.count == 1, "Non-integer string key should be dropped")
        #expect(sub.features[3] != nil)
    }
}
