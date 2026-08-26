//
//  GearTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Gear Tests")
struct GearTests {

    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let zeroCost = Money()
    let zeroWeight = Weight(value: 0, unit: .pounds)
    let gameData: GameData

    init() throws {
        gameData = try GameData("TestItemsConfiguration", from: .module)
    }

    // MARK: - Programmatic init

    @Test("Init stores all properties with defaults")
    func initDefaults() {
        let gear = Gear(name: "Torch", cost: zeroCost, weight: zeroWeight)
        #expect(gear.name == "Torch")
        #expect(gear.plural == "Torchs")
        #expect(gear.category == .general)
        #expect(gear.description == nil)
        #expect(gear.contents == nil)
    }

    @Test("Init with all properties")
    func initAllProperties() {
        let gear = Gear(
            name: "Dungeoneer's Pack",
            plural: "Dungeoneer's Packs",
            cost: zeroCost,
            weight: zeroWeight,
            category: .pack,
            description: "Includes a backpack and other essentials.",
            contents: ["Backpack", "10 Torches"]
        )
        #expect(gear.name == "Dungeoneer's Pack")
        #expect(gear.plural == "Dungeoneer's Packs")
        #expect(gear.category == .pack)
        #expect(gear.description == "Includes a backpack and other essentials.")
        #expect(gear.contents?.count == 2)
    }

    @Test("Init custom plural does not default to name + 's'")
    func initCustomPlural() {
        let gear = Gear(name: "Torch", plural: "Torches", cost: zeroCost, weight: zeroWeight)
        #expect(gear.plural == "Torches")
    }

    @Test("Gear conforms to Item protocol")
    func gearConformsToItem() {
        let gear: any Item = Gear(name: "Candle", cost: zeroCost, weight: zeroWeight)
        #expect(gear.name == "Candle")
        #expect(gear.plural == "Candles")
    }

    // MARK: - Decode with optional fields

    @Test("Decode with missing plural defaults to name + 's'")
    func decodeMissingPlural() throws {
        let json = #"{"name": "Torch", "category": "general"}"#.data(using: .utf8)!
        let gear = try decoder.decode(Gear.self, from: json, configuration: gameData)
        #expect(gear.plural == "Torchs")
    }

    @Test("Decode with missing weight defaults to zero pounds")
    func decodeMissingWeight() throws {
        let json = #"{"name": "Torch", "category": "general"}"#.data(using: .utf8)!
        let gear = try decoder.decode(Gear.self, from: json, configuration: gameData)
        #expect(gear.weight.value == 0)
        #expect(gear.weight.unit == .pounds)
    }

    @Test("Decode with missing category defaults to .general")
    func decodeMissingCategory() throws {
        let json = #"{"name": "Torch"}"#.data(using: .utf8)!
        let gear = try decoder.decode(Gear.self, from: json, configuration: gameData)
        #expect(gear.category == .general)
    }

    @Test("Decode with contents array")
    func decodeWithContents() throws {
        let json = """
        {
            "name": "Explorer's Pack",
            "category": "pack",
            "contents": ["Backpack", "10 Torches", "Rope"]
        }
        """.data(using: .utf8)!
        let gear = try decoder.decode(Gear.self, from: json, configuration: gameData)
        #expect(gear.category == .pack)
        #expect(gear.contents?.count == 3)
        #expect(gear.contents?.contains("Backpack") == true)
    }

    // MARK: - Encode

    @Test("Encode omits default plural")
    func encodeOmitsDefaultPlural() throws {
        let gear = Gear(name: "Torch", cost: zeroCost, weight: zeroWeight)
        let data = try encoder.encode(gear, configuration: gameData)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(dict?["plural"] == nil, "Default plural should be omitted")
    }

    @Test("Encode includes non-default plural")
    func encodeIncludesCustomPlural() throws {
        let gear = Gear(name: "Torch", plural: "Torches", cost: zeroCost, weight: zeroWeight)
        let data = try encoder.encode(gear, configuration: gameData)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(dict?["plural"] as? String == "Torches")
    }

    @Test("Encode includes description when present")
    func encodeIncludesDescription() throws {
        let gear = Gear(name: "Mirror", cost: zeroCost, weight: zeroWeight, description: "A polished steel mirror.")
        let data = try encoder.encode(gear, configuration: gameData)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(dict?["description"] as? String == "A polished steel mirror.")
    }

    @Test("Encode includes contents when present")
    func encodeIncludesContents() throws {
        let gear = Gear(name: "Bundle", cost: zeroCost, weight: zeroWeight, category: .pack, contents: ["Torch", "Rope"])
        let data = try encoder.encode(gear, configuration: gameData)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let contents = dict?["contents"] as? [String]
        #expect(contents?.contains("Torch") == true)
        #expect(contents?.contains("Rope") == true)
    }

    // MARK: - Encode round-trip

    @Test("Encode round-trip preserves name, category, description, and contents")
    func encodeRoundTrip() throws {
        let original = Gear(
            name: "Rope",
            plural: "Ropes",
            cost: zeroCost,
            weight: Weight(value: 10, unit: .pounds),
            category: .general,
            description: "50 feet of hempen rope.",
            contents: nil
        )
        let data = try encoder.encode(original, configuration: gameData)
        let decoded = try decoder.decode(Gear.self, from: data, configuration: gameData)
        #expect(decoded.name == original.name)
        #expect(decoded.plural == original.plural)
        #expect(decoded.category == original.category)
        #expect(decoded.description == original.description)
        #expect(decoded.weight.value == original.weight.value)
    }
}
