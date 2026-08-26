//
//  ToolTypeTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("ToolType Tests")
struct ToolTypeTests {

    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    // MARK: - Init and properties

    @Test("Init stores name correctly")
    func initAndName() {
        let tool = ToolType("custom tool")
        #expect(tool.name == "custom tool")
    }

    @Test("Description returns name")
    func description() {
        let tool = ToolType("thieves' tools")
        #expect(tool.description == "thieves' tools")
        #expect("\(tool)" == "thieves' tools")
    }

    // MARK: - Equatable and Hashable

    @Test("Equatable: same name is equal")
    func equatable() {
        let a = ToolType("artisan's tools")
        let b = ToolType("artisan's tools")
        let c = ToolType("musical instrument")
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Hashable: usable in Set")
    func hashable() {
        let a = ToolType("gaming set")
        let b = ToolType("gaming set")
        let c = ToolType("herbalism kit")
        var set = Set<ToolType>()
        set.insert(a)
        set.insert(b)
        #expect(set.count == 1, "Identical ToolTypes should deduplicate")
        set.insert(c)
        #expect(set.count == 2)
    }

    @Test("Hashable: usable as Dictionary key")
    func hashableAsDictionaryKey() {
        var dict = [ToolType: Int]()
        dict[ToolType.thieves] = 1
        dict[ToolType.navigator] = 2
        #expect(dict[ToolType.thieves] == 1)
        #expect(dict[ToolType("thieves' tools")] == 1, "Key lookup by equal value")
    }

    // MARK: - Codable

    @Test("Encodes as single JSON string")
    func encode() throws {
        let tool = ToolType("herbalism kit")
        let data = try encoder.encode(tool)
        let string = try decoder.decode(String.self, from: data)
        #expect(string == "herbalism kit")
    }

    @Test("Decodes from single JSON string")
    func decode() throws {
        let json = "\"gaming set\"".data(using: .utf8)!
        let tool = try decoder.decode(ToolType.self, from: json)
        #expect(tool.name == "gaming set")
        #expect(tool == ToolType.gaming)
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        let original = ToolType("poisoner's kit")
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(ToolType.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - Static defaults

    @Test("Static defaults have correct names")
    func staticDefaults() {
        #expect(ToolType.artisans.name == "artisan's tools")
        #expect(ToolType.musical.name == "musical instrument")
        #expect(ToolType.gaming.name == "gaming set")
        #expect(ToolType.thieves.name == "thieves' tools")
        #expect(ToolType.navigator.name == "navigator's tools")
        #expect(ToolType.herbalism.name == "herbalism kit")
        #expect(ToolType.poisoner.name == "poisoner's kit")
        #expect(ToolType.forgery.name == "forgery kit")
        #expect(ToolType.disguise.name == "disguise kit")
        #expect(ToolType.cartographer.name == "cartographer's tools")
    }

    @Test("Static defaults are distinct")
    func staticDefaultsAreDistinct() {
        let defaults: [ToolType] = [
            .artisans, .musical, .gaming, .thieves, .navigator,
            .herbalism, .poisoner, .forgery, .disguise, .cartographer
        ]
        let set = Set(defaults)
        #expect(set.count == defaults.count, "All static defaults should be unique")
    }
}
