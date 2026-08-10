//
//  ToolTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Tool Tests")
struct ToolTests {

    let zeroCost = Money(value: 0, unit: UnitCurrency.baseUnit())
    let zeroWeight = Weight(value: 0, unit: .pounds)
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let gameData: GameData

    init() throws {
        gameData = try GameData("TestItemsConfiguration", from: .module)
    }

    // MARK: - Init

    @Test("Init stores all properties")
    func initAllProperties() {
        let tool = Tool(
            name: "Thieves' Tools",
            plural: "Thieves' Tools",
            cost: Money(value: 25, unit: UnitCurrency.baseUnit()),
            weight: Weight(value: 1, unit: .pounds),
            toolType: .thieves
        )
        #expect(tool.name == "Thieves' Tools")
        #expect(tool.plural == "Thieves' Tools")
        #expect(tool.cost.value == 25)
        #expect(tool.weight.value == 1)
        #expect(tool.toolType == .thieves)
    }

    @Test("Init defaults plural to name + 's'")
    func initDefaultPlural() {
        let tool = Tool(name: "Hammer", cost: zeroCost, weight: zeroWeight, toolType: .artisans)
        #expect(tool.plural == "Hammers")
    }

    @Test("Init accepts custom plural")
    func initCustomPlural() {
        let tool = Tool(name: "Thieves' Tools", plural: "Thieves' Tools", cost: zeroCost, weight: zeroWeight, toolType: .thieves)
        #expect(tool.plural == "Thieves' Tools")
    }

    // MARK: - Item conformance

    @Test("Tool conforms to Item protocol")
    func toolConformsToItem() {
        let tool: any Item = Tool(name: "Lute", cost: zeroCost, weight: zeroWeight, toolType: .musical)
        #expect(tool.name == "Lute")
        #expect(tool.plural == "Lutes")
        #expect(tool.cost.value == 0)
        #expect(tool.weight.value == 0)
    }

    // MARK: - ToolType variety

    @Test("Tool stores artisans tool type")
    func toolArtisansType() {
        let tool = Tool(name: "Smith's Tools", cost: zeroCost, weight: zeroWeight, toolType: .artisans)
        #expect(tool.toolType == .artisans)
    }

    @Test("Tool stores musical instrument type")
    func toolMusicalType() {
        let tool = Tool(name: "Lute", cost: zeroCost, weight: zeroWeight, toolType: .musical)
        #expect(tool.toolType == .musical)
    }

    @Test("Tool stores gaming set type")
    func toolGamingType() {
        let tool = Tool(name: "Dice Set", cost: zeroCost, weight: zeroWeight, toolType: .gaming)
        #expect(tool.toolType == .gaming)
    }

    @Test("Tool stores thieves' tools type")
    func toolThievesType() {
        let tool = Tool(name: "Thieves' Tools", plural: "Thieves' Tools", cost: zeroCost, weight: zeroWeight, toolType: .thieves)
        #expect(tool.toolType == .thieves)
    }

    @Test("Tool stores navigator's tools type")
    func toolNavigatorType() {
        let tool = Tool(name: "Navigator's Tools", plural: "Navigator's Tools", cost: zeroCost, weight: zeroWeight, toolType: .navigator)
        #expect(tool.toolType == .navigator)
    }

    // MARK: - Decode with optional fields

    @Test("Decode with missing plural defaults to name + 's'")
    func decodeMissingPlural() throws {
        let json = """
        {"name": "Hammer", "tool type": "artisan's tools"}
        """.data(using: .utf8)!
        let tool = try decoder.decode(Tool.self, from: json, configuration: gameData)
        #expect(tool.name == "Hammer")
        #expect(tool.plural == "Hammers")
    }

    @Test("Decode with missing weight defaults to zero pounds")
    func decodeMissingWeight() throws {
        let json = """
        {"name": "Chisel", "tool type": "artisan's tools"}
        """.data(using: .utf8)!
        let tool = try decoder.decode(Tool.self, from: json, configuration: gameData)
        #expect(tool.weight.value == 0)
        #expect(tool.weight.unit == .pounds)
    }

    // MARK: - Encode round-trip

    @Test("Encode round-trip preserves name, plural, weight, and toolType")
    func encodeRoundTrip() throws {
        let original = Tool(
            name: "Navigator's Tools",
            plural: "Navigator's Tools",
            cost: zeroCost,
            weight: Weight(value: 2, unit: .pounds),
            toolType: .navigator
        )
        let data = try encoder.encode(original, configuration: gameData)
        let decoded = try decoder.decode(Tool.self, from: data, configuration: gameData)
        #expect(decoded.name == original.name)
        #expect(decoded.plural == original.plural)
        #expect(decoded.weight.value == original.weight.value)
        #expect(decoded.toolType == original.toolType)
    }
}
