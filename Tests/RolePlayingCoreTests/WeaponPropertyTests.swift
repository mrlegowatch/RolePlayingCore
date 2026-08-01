//
//  WeaponPropertyTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("WeaponProperty Tests")
struct WeaponPropertyTests {

    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    // MARK: - Init and properties

    @Test("Init stores name")
    func initAndName() {
        let prop = WeaponProperty("custom property")
        #expect(prop.name == "custom property")
    }

    @Test("Description returns name")
    func description() {
        let prop = WeaponProperty("finesse")
        #expect(prop.description == "finesse")
        #expect("\(prop)" == "finesse")
    }

    // MARK: - Equatable and Hashable

    @Test("Equal when names match")
    func equatable() {
        let a = WeaponProperty("finesse")
        let b = WeaponProperty("finesse")
        let c = WeaponProperty("heavy")
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Usable in Set — deduplicates equal values")
    func hashableInSet() {
        let set = Set([WeaponProperty.finesse, WeaponProperty.light, WeaponProperty("finesse")])
        #expect(set.count == 2)
    }

    @Test("Usable as Dictionary key")
    func hashableAsDictionaryKey() {
        var dict = [WeaponProperty: String]()
        dict[.thrown] = "can be thrown"
        #expect(dict[WeaponProperty("thrown")] == "can be thrown")
    }

    // MARK: - Codable

    @Test("Encodes as single JSON string")
    func encode() throws {
        let prop = WeaponProperty("versatile")
        let data = try encoder.encode(prop)
        let string = try decoder.decode(String.self, from: data)
        #expect(string == "versatile")
    }

    @Test("Decodes from single JSON string")
    func decode() throws {
        let json = "\"two-handed\"".data(using: .utf8)!
        let prop = try decoder.decode(WeaponProperty.self, from: json)
        #expect(prop.name == "two-handed")
        #expect(prop == .twoHanded)
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        for prop in [WeaponProperty.ammunition, .finesse, .heavy, .light, .loading,
                     .reach, .thrown, .twoHanded, .versatile, .special] {
            let data = try encoder.encode(prop)
            let decoded = try decoder.decode(WeaponProperty.self, from: data)
            #expect(decoded == prop, "Round-trip failed for \(prop)")
        }
    }

    // MARK: - Static defaults

    @Test("Static defaults have correct names")
    func staticDefaults() {
        #expect(WeaponProperty.ammunition.name == "ammunition")
        #expect(WeaponProperty.finesse.name == "finesse")
        #expect(WeaponProperty.heavy.name == "heavy")
        #expect(WeaponProperty.light.name == "light")
        #expect(WeaponProperty.loading.name == "loading")
        #expect(WeaponProperty.reach.name == "reach")
        #expect(WeaponProperty.thrown.name == "thrown")
        #expect(WeaponProperty.twoHanded.name == "two-handed")
        #expect(WeaponProperty.versatile.name == "versatile")
        #expect(WeaponProperty.special.name == "special")
    }

    @Test("All static defaults are distinct")
    func staticDefaultsAreDistinct() {
        let defaults: [WeaponProperty] = [
            .ammunition, .finesse, .heavy, .light, .loading,
            .reach, .thrown, .twoHanded, .versatile, .special
        ]
        #expect(Set(defaults).count == defaults.count)
    }
}
