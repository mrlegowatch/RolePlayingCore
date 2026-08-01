//
//  WeaponCategoryTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("WeaponCategory Tests")
struct WeaponCategoryTests {

    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    // MARK: - Init and properties

    @Test("Init stores name")
    func initAndName() {
        let category = WeaponCategory("exotic")
        #expect(category.name == "exotic")
    }

    @Test("Description returns name")
    func description() {
        let category = WeaponCategory("simple")
        #expect(category.description == "simple")
        #expect("\(category)" == "simple")
    }

    // MARK: - Equatable and Hashable

    @Test("Equal when names match")
    func equatable() {
        let a = WeaponCategory("simple")
        let b = WeaponCategory("simple")
        let c = WeaponCategory("martial")
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Usable in Set — deduplicates equal values")
    func hashableInSet() {
        let set = Set([WeaponCategory.simple, WeaponCategory.martial, WeaponCategory("simple")])
        #expect(set.count == 2)
    }

    @Test("Usable as Dictionary key")
    func hashableAsDictionaryKey() {
        var dict = [WeaponCategory: [String]]()
        dict[.simple] = ["Club", "Dagger"]
        dict[.martial] = ["Longsword", "Battleaxe"]
        #expect(dict[WeaponCategory("simple")]?.contains("Dagger") == true)
    }

    // MARK: - Codable

    @Test("Encodes as single JSON string")
    func encode() throws {
        let category = WeaponCategory("martial")
        let data = try encoder.encode(category)
        let string = try decoder.decode(String.self, from: data)
        #expect(string == "martial")
    }

    @Test("Decodes from single JSON string")
    func decode() throws {
        let json = "\"simple\"".data(using: .utf8)!
        let category = try decoder.decode(WeaponCategory.self, from: json)
        #expect(category.name == "simple")
        #expect(category == .simple)
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        for category in [WeaponCategory.simple, .martial] {
            let data = try encoder.encode(category)
            let decoded = try decoder.decode(WeaponCategory.self, from: data)
            #expect(decoded == category, "Round-trip failed for \(category)")
        }
    }

    // MARK: - Static defaults

    @Test("Static defaults have correct names")
    func staticDefaults() {
        #expect(WeaponCategory.simple.name == "simple")
        #expect(WeaponCategory.martial.name == "martial")
    }

    @Test("Simple and martial are distinct")
    func staticDefaultsAreDistinct() {
        #expect(WeaponCategory.simple != WeaponCategory.martial)
    }
}
