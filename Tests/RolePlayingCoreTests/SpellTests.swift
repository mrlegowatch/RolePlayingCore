//
//  SpellTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Spell Tests")
struct SpellTests {

    let decoder = JSONDecoder()
    let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = .sortedKeys
        return e
    }()

    // MARK: - Spell Init

    @Test("Init with defaults")
    func initDefaults() {
        let spell = Spell(name: "Fire Bolt")
        #expect(spell.name == "Fire Bolt")
        #expect(spell.level == 0)
        #expect(spell.school == "")
        #expect(spell.components.isEmpty)
        #expect(spell.castingTime == "")
        #expect(spell.description == "")
    }

    @Test("Init with all properties")
    func initFull() {
        let spell = Spell(name: "Fireball", level: 3, school: "evocation",
                          components: ["V", "S", "M"], castingTime: "1 action",
                          description: "A bright streak flashes from your pointing finger.")
        #expect(spell.name == "Fireball")
        #expect(spell.level == 3)
        #expect(spell.school == "evocation")
        #expect(spell.components == ["V", "S", "M"])
        #expect(spell.castingTime == "1 action")
        #expect(spell.description == "A bright streak flashes from your pointing finger.")
    }

    // MARK: - Spell Equatable / Hashable

    @Test("Equatable: identical spells are equal")
    func equatable() {
        let a = Spell(name: "Fireball", level: 3, school: "evocation")
        let b = Spell(name: "Fireball", level: 3, school: "evocation")
        #expect(a == b)
    }

    @Test("Equatable: different names are not equal")
    func notEqualByName() {
        let a = Spell(name: "Fireball")
        let b = Spell(name: "Ice Storm")
        #expect(a != b)
    }

    @Test("Hashable: same-name spells have same hash")
    func hashable() {
        let a = Spell(name: "Fireball", level: 3)
        let b = Spell(name: "Fireball", level: 3)
        #expect(a.hashValue == b.hashValue)
    }

    // MARK: - Spell Codable decode

    @Test("Decode with all fields")
    func decodeAllFields() throws {
        let json = """
        {
            "name": "Fireball",
            "level": 3,
            "school": "evocation",
            "components": ["V", "S", "M"],
            "casting time": "1 action",
            "description": "A bright streak."
        }
        """.data(using: .utf8)!

        let spell = try decoder.decode(Spell.self, from: json)
        #expect(spell.name == "Fireball")
        #expect(spell.level == 3)
        #expect(spell.school == "evocation")
        #expect(spell.components == ["V", "S", "M"])
        #expect(spell.castingTime == "1 action")
        #expect(spell.description == "A bright streak.")
    }

    @Test("Decode with name only defaults other fields")
    func decodeNameOnly() throws {
        let json = #"{"name": "Fire Bolt"}"#.data(using: .utf8)!
        let spell = try decoder.decode(Spell.self, from: json)
        #expect(spell.name == "Fire Bolt")
        #expect(spell.level == 0)
        #expect(spell.school == "")
        #expect(spell.components.isEmpty)
    }

    @Test("Decode level 0 cantrip")
    func decodeCantrip() throws {
        let json = #"{"name": "Prestidigitation", "level": 0}"#.data(using: .utf8)!
        let spell = try decoder.decode(Spell.self, from: json)
        #expect(spell.level == 0)
    }

    // MARK: - Spell Codable encode

    @Test("Encode always includes name and level")
    func encodeNameAndLevel() throws {
        let spell = Spell(name: "Fire Bolt", level: 0)
        let data = try encoder.encode(spell)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["name"] as? String == "Fire Bolt")
        #expect(dict["level"] as? Int == 0)
    }

    @Test("Encode omits empty optional fields")
    func encodeOmitsEmptyFields() throws {
        let spell = Spell(name: "Fire Bolt")
        let data = try encoder.encode(spell)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["school"] == nil)
        #expect(dict["components"] == nil)
        #expect(dict["casting time"] == nil)
        #expect(dict["description"] == nil)
    }

    @Test("Encode includes non-empty optional fields")
    func encodeIncludesOptionalFields() throws {
        let spell = Spell(name: "Fireball", level: 3, school: "evocation",
                          components: ["V", "S", "M"], castingTime: "1 action",
                          description: "Boom.")
        let data = try encoder.encode(spell)
        let dict = try #require(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(dict["school"] as? String == "evocation")
        #expect(dict["components"] as? [String] == ["V", "S", "M"])
        #expect(dict["casting time"] as? String == "1 action")
        #expect(dict["description"] as? String == "Boom.")
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        let original = Spell(name: "Fireball", level: 3, school: "evocation",
                             components: ["V", "S", "M"], castingTime: "1 action",
                             description: "A bright streak.")
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Spell.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - Spells collection

    @Test("Spells init empty")
    func spellsEmpty() {
        let spells = Spells()
        #expect(spells.count == 0)
        #expect(spells.all.isEmpty)
        #expect(spells["Fireball"] == nil)
    }

    @Test("Spells init with array stores and retrieves by name")
    func spellsInit() {
        let fireball = Spell(name: "Fireball", level: 3)
        let fireBolt = Spell(name: "Fire Bolt", level: 0)
        let spells = Spells([fireball, fireBolt])
        #expect(spells.count == 2)
        #expect(spells["Fireball"]?.level == 3)
        #expect(spells["Fire Bolt"]?.level == 0)
        #expect(spells["Unknown"] == nil)
    }

    @Test("Spells deduplicates by name (last wins)")
    func spellsDeduplicates() {
        let v1 = Spell(name: "Fireball", level: 3, school: "evocation")
        let v2 = Spell(name: "Fireball", level: 3, school: "conjuration")
        let spells = Spells([v1, v2])
        #expect(spells.count == 1)
        #expect(spells["Fireball"]?.school == "conjuration")
    }

    @Test("spells(ofLevel:) filters and sorts by name")
    func spellsOfLevel() {
        let spells = Spells([
            Spell(name: "Fireball", level: 3),
            Spell(name: "Lightning Bolt", level: 3),
            Spell(name: "Fire Bolt", level: 0),
            Spell(name: "Magic Missile", level: 1),
        ])
        let level3 = spells.spells(ofLevel: 3)
        #expect(level3.count == 2)
        #expect(level3.map(\.name) == ["Fireball", "Lightning Bolt"])

        let cantrips = spells.spells(ofLevel: 0)
        #expect(cantrips.count == 1)
        #expect(cantrips[0].name == "Fire Bolt")

        #expect(spells.spells(ofLevel: 9).isEmpty)
    }

    @Test("Spells Codable round-trip")
    func spellsRoundTrip() throws {
        let json = """
        {
            "spells": [
                { "name": "Fire Bolt", "level": 0, "school": "evocation" },
                { "name": "Magic Missile", "level": 1, "school": "evocation" },
                { "name": "Fireball", "level": 3, "school": "evocation",
                  "components": ["V", "S", "M"], "casting time": "1 action" }
            ]
        }
        """.data(using: .utf8)!

        let spells = try decoder.decode(Spells.self, from: json)
        #expect(spells.count == 3)
        #expect(spells["Fire Bolt"]?.level == 0)
        #expect(spells["Magic Missile"]?.level == 1)
        #expect(spells["Fireball"]?.components == ["V", "S", "M"])

        let encodedData = try encoder.encode(spells)
        let decoded = try decoder.decode(Spells.self, from: encodedData)
        #expect(decoded.count == spells.count)
        #expect(decoded["Fireball"] == spells["Fireball"])
    }
}
