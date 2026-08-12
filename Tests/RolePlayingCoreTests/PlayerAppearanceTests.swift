//
//  PlayerAppearanceTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
@testable import RolePlayingCore
import Foundation

@Suite("AppearanceTraitKey Tests")
struct AppearanceTraitKeyTests {

    @Test("Init stores rawValue")
    func initStoresRawValue() {
        let key = AppearanceTraitKey("tattoo")
        #expect(key.rawValue == "tattoo")
    }

    @Test("Standard static constants have expected rawValues")
    func standardConstants() {
        #expect(AppearanceTraitKey.hairColor.rawValue == "hair color")
        #expect(AppearanceTraitKey.eyeColor.rawValue == "eye color")
        #expect(AppearanceTraitKey.skinColor.rawValue == "skin color")
        #expect(AppearanceTraitKey.age.rawValue == "age")
        #expect(AppearanceTraitKey.birthdate.rawValue == "birthdate")
        #expect(AppearanceTraitKey.gender.rawValue == "gender")
    }

    @Test("allStandardKeys contains all six standard keys")
    func allStandardKeys() {
        let keys = AppearanceTraitKey.allStandardKeys
        #expect(keys.count == 6)
        #expect(keys.contains(.hairColor))
        #expect(keys.contains(.eyeColor))
        #expect(keys.contains(.skinColor))
        #expect(keys.contains(.age))
        #expect(keys.contains(.birthdate))
        #expect(keys.contains(.gender))
    }

    @Test("Hashable: same rawValue is equal and hashes identically")
    func hashable() {
        let a = AppearanceTraitKey("tattoo")
        let b = AppearanceTraitKey("tattoo")
        let c = AppearanceTraitKey("scar")
        #expect(a == b)
        #expect(a != c)

        var h1 = Hasher(); a.hash(into: &h1)
        var h2 = Hasher(); b.hash(into: &h2)
        #expect(h1.finalize() == h2.finalize())

        let set: Set<AppearanceTraitKey> = [a, b, c]
        #expect(set.count == 2)
    }
}

@Suite("PlayerAppearance Tests")
struct PlayerAppearanceTests {

    @Test("Default init produces empty traits")
    func defaultInit() {
        let appearance = PlayerAppearance(traits: [:])
        #expect(appearance.traits.isEmpty)
        #expect(appearance.gender == nil)
        #expect(appearance.hairColor == nil)
        #expect(appearance.eyeColor == nil)
        #expect(appearance.skinColor == nil)
        #expect(appearance.age == nil)
        #expect(appearance.birthdate == nil)
    }

    @Test("Init with gender stores gender in traits dict")
    func initWithGender() {
        let appearance = PlayerAppearance(gender: .female)
        #expect(appearance.gender == .female)
        #expect(appearance.traits["gender"] == "Female")
        #expect(appearance.traits.count == 1)
    }

    @Test("Init with nil gender produces empty traits")
    func initWithNilGender() {
        let appearance = PlayerAppearance(gender: nil)
        #expect(appearance.traits.isEmpty)
    }

    @Test("Init with explicit traits dict")
    func initWithTraits() {
        let appearance = PlayerAppearance(traits: ["hair color": "auburn", "eye color": "green"])
        #expect(appearance.hairColor == "auburn")
        #expect(appearance.eyeColor == "green")
        #expect(appearance.skinColor == nil)
    }

    @Test("Typed property setters round-trip through traits dict")
    func typedPropertySetters() {
        var appearance = PlayerAppearance(traits: [:])
        appearance.hairColor = "silver"
        appearance.eyeColor = "amber"
        appearance.skinColor = "tanned"
        appearance.age = "37"
        appearance.birthdate = "Midsummer"

        #expect(appearance.hairColor == "silver")
        #expect(appearance.eyeColor == "amber")
        #expect(appearance.skinColor == "tanned")
        #expect(appearance.age == "37")
        #expect(appearance.birthdate == "Midsummer")

        #expect(appearance.traits["hair color"] == "silver")
        #expect(appearance.traits["eye color"] == "amber")
        #expect(appearance.traits["skin color"] == "tanned")
        #expect(appearance.traits["age"] == "37")
        #expect(appearance.traits["birthdate"] == "Midsummer")
    }

    @Test("Typed property setter clears key when set to nil")
    func typedPropertyNilClearsKey() {
        var appearance = PlayerAppearance(traits: [:])
        appearance.hairColor = "silver"
        appearance.hairColor = nil
        #expect(appearance.traits["hair color"] == nil)
        #expect(appearance.hairColor == nil)
    }

    @Test("Gender setter updates traits dict, nil clears key")
    func genderSetter() {
        var appearance = PlayerAppearance(traits: [:])
        appearance.gender = .male
        #expect(appearance.traits["gender"] == "Male")
        appearance.gender = .female
        #expect(appearance.traits["gender"] == "Female")
        appearance.gender = nil
        #expect(appearance.traits["gender"] == nil)
    }

    @Test("Unrecognized gender rawValue in traits returns nil")
    func genderUnrecognizedRawValue() {
        let appearance = PlayerAppearance(traits: ["gender": "Unknown"])
        #expect(appearance.gender == nil)
    }

    @Test("Custom AppearanceTraitKey subscript stores and retrieves")
    func customKeySubscript() {
        let tattooKey = AppearanceTraitKey("tattoo")
        var appearance = PlayerAppearance(traits: [:])
        appearance[tattooKey] = "dragon on left arm"
        #expect(appearance[tattooKey] == "dragon on left arm")
        #expect(appearance.traits["tattoo"] == "dragon on left arm")
        appearance[tattooKey] = nil
        #expect(appearance[tattooKey] == nil)
        #expect(appearance.traits["tattoo"] == nil)
    }

    @Test("Equatable: same traits are equal, different traits are not")
    func equatable() {
        let a = PlayerAppearance(traits: ["hair color": "black"])
        let b = PlayerAppearance(traits: ["hair color": "black"])
        let c = PlayerAppearance(traits: ["hair color": "red"])
        let d = PlayerAppearance(traits: [:])
        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }

    @Test("Hashable: equal appearances produce equal hash and can be stored in Set")
    func hashable() {
        let a = PlayerAppearance(traits: ["hair color": "black"])
        let b = PlayerAppearance(traits: ["hair color": "black"])
        let c = PlayerAppearance(traits: ["hair color": "red"])
        let set: Set<PlayerAppearance> = [a, b, c]
        #expect(set.count == 2)
    }

    @Test("Codable round-trip preserves all traits including custom keys")
    func codableRoundTrip() throws {
        var appearance = PlayerAppearance(traits: [:])
        appearance.hairColor = "silver"
        appearance.gender = .female
        appearance[AppearanceTraitKey("tattoo")] = "dragon"

        let encoder = JSONEncoder()
        let data = try encoder.encode(appearance)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PlayerAppearance.self, from: data)

        #expect(decoded == appearance)
        #expect(decoded.hairColor == "silver")
        #expect(decoded.gender == .female)
        #expect(decoded[AppearanceTraitKey("tattoo")] == "dragon")
    }

    @Test("Codable encodes as flat string-to-string JSON object")
    func codableEncodesFlatDict() throws {
        let appearance = PlayerAppearance(traits: ["eye color": "blue", "age": "25"])
        let encoder = JSONEncoder()
        let data = try encoder.encode(appearance)
        let dict = try #require(JSONSerialization.jsonObject(with: data) as? [String: String])
        #expect(dict["eye color"] == "blue")
        #expect(dict["age"] == "25")
        #expect(dict.count == 2)
    }

    @Test("Gender is CaseIterable with female and male cases")
    func genderCaseIterable() {
        #expect(PlayerAppearance.Gender.allCases.count == 2)
        #expect(PlayerAppearance.Gender.allCases.contains(.female))
        #expect(PlayerAppearance.Gender.allCases.contains(.male))
    }

    @Test("Gender rawValues and init from rawValue")
    func genderRawValues() {
        #expect(PlayerAppearance.Gender.female.rawValue == "Female")
        #expect(PlayerAppearance.Gender.male.rawValue == "Male")
        #expect(PlayerAppearance.Gender(rawValue: "Female") == .female)
        #expect(PlayerAppearance.Gender(rawValue: "Male") == .male)
        #expect(PlayerAppearance.Gender(rawValue: "Nonbinary") == nil)
    }
}
