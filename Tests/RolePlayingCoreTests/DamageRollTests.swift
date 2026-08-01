//
//  DamageRollTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("DamageRoll Tests")
struct DamageRollTests {

    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    // MARK: - Parsing

    @Test("Parse valid expressions")
    func parseValid() throws {
        // SwiftDice normalizes coefficient 1: "1d8" renders as "d8"
        let slashing = try #require(DamageRoll(parsing: "1d8 slashing"))
        #expect(slashing.type == .slashing)
        #expect(slashing.description == "d8 slashing")

        let fire = try #require(DamageRoll(parsing: "2d6 fire"))
        #expect(fire.type == .fire)
        #expect(fire.description == "2d6 fire")

        let piercing = try #require(DamageRoll(parsing: "1d4 piercing"))
        #expect(piercing.type == .piercing)
        #expect(piercing.description == "d4 piercing")

        let bludgeoning = try #require(DamageRoll(parsing: "1d6 bludgeoning"))
        #expect(bludgeoning.type == .bludgeoning)
        #expect(bludgeoning.description == "d6 bludgeoning")

        let cold = try #require(DamageRoll(parsing: "1d10 cold"))
        #expect(cold.type == .cold)
        #expect(cold.description == "d10 cold")
    }

    @Test("Parse trims surrounding whitespace")
    func parseTrimWhitespace() throws {
        let roll = try #require(DamageRoll(parsing: "  1d8 slashing  "))
        #expect(roll.type == .slashing)
        #expect(roll.description == "d8 slashing")
    }

    @Test("Parse returns nil for invalid expressions")
    func parseInvalid() {
        #expect(DamageRoll(parsing: "") == nil, "empty string")
        #expect(DamageRoll(parsing: "slashing") == nil, "missing dice, no space")
        #expect(DamageRoll(parsing: "1d8") == nil, "dice only, no space")
        #expect(DamageRoll(parsing: "notadice slashing") == nil, "invalid dice expression")
    }

    // MARK: - CustomStringConvertible

    @Test("Description is '<dice> <type>'")
    func customStringConvertible() throws {
        let roll = try #require(DamageRoll(parsing: "2d6 fire"))
        #expect(roll.description == "2d6 fire")
        #expect("\(roll)" == "2d6 fire")
    }

    // MARK: - Codable

    @Test("Decode from JSON string")
    func decodeFromJSON() throws {
        let json = "\"1d8 slashing\"".data(using: .utf8)!
        let roll = try decoder.decode(DamageRoll.self, from: json)
        #expect(roll.type == .slashing)
        #expect(roll.description == "d8 slashing")
    }

    @Test("Decode throws for invalid string")
    func decodeThrowsForInvalid() {
        let json = "\"notdice piercing\"".data(using: .utf8)!
        #expect(throws: Error.self) {
            try decoder.decode(DamageRoll.self, from: json)
        }
    }

    @Test("Encode to JSON string")
    func encodeToJSON() throws {
        let roll = try #require(DamageRoll(parsing: "1d6 piercing"))
        let data = try encoder.encode(roll)
        let string = try decoder.decode(String.self, from: data)
        #expect(string == "d6 piercing")
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        let expressions = ["1d8 slashing", "2d6 fire", "1d4 piercing", "1d10 cold", "1d6 bludgeoning"]
        for expr in expressions {
            let original = try #require(DamageRoll(parsing: expr))
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(DamageRoll.self, from: data)
            #expect(decoded.description == original.description, "Round-trip failed for \(expr)")
            #expect(decoded.type == original.type, "Type mismatch after round-trip for \(expr)")
        }
    }

    // MARK: - DamageType defaults

    @Test("DamageType static defaults")
    func damageTypeDefaults() {
        #expect(DamageType.slashing.name == "slashing")
        #expect(DamageType.piercing.name == "piercing")
        #expect(DamageType.bludgeoning.name == "bludgeoning")
        #expect(DamageType.acid.name == "acid")
        #expect(DamageType.cold.name == "cold")
        #expect(DamageType.fire.name == "fire")
        #expect(DamageType.lightning.name == "lightning")
        #expect(DamageType.thunder.name == "thunder")
        #expect(DamageType.force.name == "force")
        #expect(DamageType.necrotic.name == "necrotic")
        #expect(DamageType.psychic.name == "psychic")
        #expect(DamageType.radiant.name == "radiant")
        #expect(DamageType.poison.name == "poison")
    }

    @Test("DamageType Hashable and description")
    func damageTypeHashableAndDescription() {
        let a = DamageType("slashing")
        let b = DamageType("slashing")
        let c = DamageType("fire")
        #expect(a == b)
        #expect(a != c)
        #expect(a.description == "slashing")
        let set = Set([a, b, c])
        #expect(set.count == 2)
    }

    // MARK: - DamageType Codable

    @Test("DamageType encodes as JSON string")
    func damageTypeEncode() throws {
        let data = try encoder.encode(DamageType.slashing)
        let string = try decoder.decode(String.self, from: data)
        #expect(string == "slashing")
    }

    @Test("DamageType decodes from JSON string")
    func damageTypeDecode() throws {
        let json = "\"necrotic\"".data(using: .utf8)!
        let dmgType = try decoder.decode(DamageType.self, from: json)
        #expect(dmgType == .necrotic)
        #expect(dmgType.name == "necrotic")
    }

    @Test("DamageType Codable round-trip")
    func damageTypeRoundTrip() throws {
        for dmgType in [DamageType.acid, .cold, .fire, .lightning, .thunder,
                        .force, .necrotic, .psychic, .radiant, .poison] {
            let data = try encoder.encode(dmgType)
            let decoded = try decoder.decode(DamageType.self, from: data)
            #expect(decoded == dmgType, "Round-trip failed for \(dmgType)")
        }
    }

    // MARK: - DamageRoll memberwise init

    @Test("DamageRoll init(dice:type:) stores properties")
    func damageRollMemberwiseInit() throws {
        let source = try #require(DamageRoll(parsing: "2d6 fire"))
        let copy = DamageRoll(dice: source.dice, type: DamageType("lightning"))
        #expect(copy.type == DamageType("lightning"))
        #expect(copy.description == "2d6 lightning")
    }
}
