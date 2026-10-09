//
//  StatLineTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. Licensed under the MIT License.
//

import Testing
import RolePlayingCore
import SwiftDice
import Foundation

@Suite("StatLine Tests")
struct StatLineTests {

    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    // MARK: - Codable

    @Test("Decode a full stat line")
    func decodeFull() throws {
        let json = """
        { "armorClass": 2, "hitDice": "1", "hitPoints": [6, 5, 5, 5, 5], "attacks": 2, "damage": ["d4+1", "d4+1"], "text": "AC2, HD1, hp6, 5(x4), #AT2, D2-5/2-5" }
        """.data(using: .utf8)!
        let stats = try decoder.decode(StatLine.self, from: json)
        #expect(stats.armorClass == 2)
        #expect(stats.hitDice == "1")
        #expect(stats.hitPoints == [6, 5, 5, 5, 5])
        #expect(stats.attacks == 2)
        #expect(stats.damage.map(\.description) == ["d4+1", "d4+1"])
        #expect(stats.special == nil)
        #expect(stats.text == "AC2, HD1, hp6, 5(x4), #AT2, D2-5/2-5")
    }

    @Test("Decode empty object yields empty stat line")
    func decodeEmpty() throws {
        let json = "{}".data(using: .utf8)!
        let stats = try decoder.decode(StatLine.self, from: json)
        #expect(stats.armorClass == nil)
        #expect(stats.hitDice == nil)
        #expect(stats.hitPoints == [])
        #expect(stats.attacks == nil)
        #expect(stats.damage == [])
        #expect(stats.special == nil)
        #expect(stats.text == nil)
    }

    @Test("Decode throws for an invalid damage expression")
    func decodeThrowsForInvalidDamage() {
        let json = #"{ "damage": ["banana"] }"#.data(using: .utf8)!
        #expect(throws: Error.self) {
            try decoder.decode(StatLine.self, from: json)
        }
    }

    @Test("Codable round-trip")
    func roundTrip() throws {
        let original = StatLine(armorClass: 2, hitDice: "1", hitPoints: [6, 5, 5, 5, 5], attacks: 2,
                                 damage: [try AnyRollable(parsing: "d4+1"), try AnyRollable(parsing: "d4+1")],
                                 special: "poison", text: "AC2, HD1, hp6, 5(x4), #AT2, D2-5/2-5")
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(StatLine.self, from: data)
        #expect(decoded == original)
    }

    @Test("Encoding an empty stat line omits all keys")
    func encodeEmptyOmitsKeys() throws {
        let data = try encoder.encode(StatLine())
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(object?.isEmpty == true)
    }

    // MARK: - hitPoints(forCreatureAt:)

    @Test("hitPoints(forCreatureAt:) repeats the last value past the end of the list")
    func hitPointsForCreatureAt() {
        let stats = StatLine(hitPoints: [6, 5])
        #expect(stats.hitPoints(forCreatureAt: 0) == 6)
        #expect(stats.hitPoints(forCreatureAt: 1) == 5)
        #expect(stats.hitPoints(forCreatureAt: 4) == 5)
    }

    @Test("hitPoints(forCreatureAt:) is nil when no hit points are given")
    func hitPointsForCreatureAtEmpty() {
        let stats = StatLine()
        #expect(stats.hitPoints(forCreatureAt: 0) == nil)
    }

    // MARK: - summary

    @Test("summary prefers text when present")
    func summaryPrefersText() {
        let stats = StatLine(armorClass: 5, text: "AC5, HD1, hp6")
        #expect(stats.summary == "AC5, HD1, hp6")
    }

    @Test("summary is built from fields when text is absent")
    func summaryBuiltFromFields() throws {
        let stats = StatLine(armorClass: 5, hitDice: "1+1", hitPoints: [6], attacks: 1,
                              damage: [try AnyRollable(parsing: "d6")])
        #expect(stats.summary == "AC 5, HD 1+1, hp 6, #AT 1, D d6")
    }
}
