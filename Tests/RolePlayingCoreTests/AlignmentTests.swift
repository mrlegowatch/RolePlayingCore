//
//  AlignmentTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/11/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Alignment Tests")
struct AlignmentTests {

    @Test("Ethics by string")
    func ethicsByString() throws {
        let lawful = try #require(Ethics(rawValue: "Lawful"), "lawful should be non-nil")
        #expect(lawful == Ethics.lawful, "lawful enum")
        #expect(lawful.value == 1.0, "lawful value")
        
        let neutral = try #require(Ethics(rawValue: "Neutral"), "neutral should be non-nil")
        #expect(neutral == Ethics.neutral, "neutral enum")
        #expect(neutral.value == 0.0, "neutral value")
        
        let chaotic = try #require(Ethics(rawValue: "Chaotic"), "chaotic should be non-nil")
        #expect(chaotic == Ethics.chaotic, "chaotic enum")
        #expect(chaotic.value == -1.0, "chaotic value")
    }
    
    @Test("Ethics by value")
    func ethicsByValue() {
        let lawful = Ethics(0.8)
        #expect(lawful == Ethics.lawful, "lawful enum")
        #expect(lawful.value == 1.0, "lawful value")
        
        let neutral = Ethics(-0.1)
        #expect(neutral == Ethics.neutral, "neutral enum")
        #expect(neutral.value == 0.0, "neutral value")
        
        let chaotic = Ethics(-0.34)
        #expect(chaotic == Ethics.chaotic, "chaotic enum")
        #expect(chaotic.value == -1.0, "chaotic value")
    }
    
    @Test("Morals by string")
    func moralsByString() throws {
        let good = try #require(Morals(rawValue: "Good"), "good should be non-nil")
        #expect(good == Morals.good, "good enum")
        #expect(good.value == 1.0, "good value")
        
        let neutral = try #require(Morals(rawValue: "Neutral"), "neutral should be non-nil")
        #expect(neutral == Morals.neutral, "neutral enum")
        #expect(neutral.value == 0.0, "neutral value")
        
        let evil = try #require(Morals(rawValue: "Evil"), "evil should be non-nil")
        #expect(evil == Morals.evil, "evil enum")
        #expect(evil.value == -1.0, "evil value")
    }
        
    @Test("Morals by value")
    func moralsByValue() {
        let good = Morals(0.334)
        #expect(good == Morals.good, "good enum")
        #expect(good.value == 1.0, "good value")
        
        let neutral = Morals(0.2)
        #expect(neutral == Morals.neutral, "neutral enum")
        #expect(neutral.value == 0.0, "neutral value")
        
        let evil = Morals(-0.9)
        #expect(evil == Morals.evil, "evil enum")
        #expect(evil.value == -1.0, "evil value")
    }
    
    @Test("Alignment by type")
    func alignmentByType() {
        let neutralGood = Alignment.Kind(.neutral, .good)
        #expect(neutralGood.description == "Neutral Good", "description")
        
        let neutralEvil = Alignment.Kind(.neutral, .evil)
        #expect(neutralEvil.description == "Neutral Evil", "description")
        
        let chaoticNeutral = Alignment.Kind(.chaotic, .neutral)
        #expect(chaoticNeutral.description == "Chaotic Neutral", "description")
        
        #expect(neutralGood == Alignment.Kind(.neutral, .good), "equatable")
        #expect(neutralGood != neutralEvil, "equatable")
        #expect(neutralEvil != chaoticNeutral, "equatable")
    }
    
    @Test("Alignment by value")
    func alignmentByValue() {
        let lawfulNeutral = Alignment(ethics: 0.7, morals: 0.0)
        #expect(lawfulNeutral.description == "Lawful Neutral", "description")
        
        let neutral = Alignment(ethics: 0.1, morals: -0.2)
        #expect(neutral.description == "Neutral", "description")
        
        let chaoticGood = Alignment(ethics: -1, morals: 1)
        #expect(chaoticGood.description == "Chaotic Good", "description")
    }
    
    @Test("Changing alignment")
    func changingAlignment() {
        // Test changing alignment
        var alignment = Alignment(.neutral, .evil)
        #expect(alignment.ethics == 0, "ethics value")
        #expect(alignment.morals == -1, "morals value")
        #expect(alignment.kind.ethics == Ethics.neutral, "ethics enumeration")
        #expect(alignment.kind.morals == Morals.evil, "morals enumeration")

        
        alignment.morals += 0.8
        #expect(abs(alignment.morals - (-0.2)) < 0.00001, "morals value")
        #expect(alignment.kind.ethics == Ethics.neutral, "ethics enumeration")
        #expect(alignment.kind.morals == Morals.neutral, "morals enumeration")

        // Try to exceed 1.0 and confirm the ethics value did not change
        alignment.ethics += 5.4
        #expect(alignment.ethics == 0, "ethics value")
        #expect(alignment.kind.ethics == Ethics.neutral, "ethics enumeration")
        #expect(alignment.kind.morals == Morals.neutral, "morals enumeration")

        alignment.morals += 0.8
        #expect(abs(alignment.morals - 0.6) < 0.00001, "morals value")
        #expect(alignment.kind.ethics == Ethics.neutral, "ethics enumeration")
        #expect(alignment.kind.morals == Morals.good, "morals enumeration")

        // Try to exceed 1.0 and confirm that morals value did not change
        alignment.morals += 0.8
        #expect(abs(alignment.morals - 0.6) < 0.00001, "morals value")
        #expect(alignment.kind.ethics == Ethics.neutral, "ethics enumeration")
        #expect(alignment.kind.morals == Morals.good, "morals enumeration")
    }
    
    @Test("Alignment parsing")
    func alignmentParsing() throws {
        // Test initializing from valid string
        let neutralGood = try #require("Neutral Good".parseAlignment, "alignment should be non-nil")
        #expect(neutralGood.0 == Ethics.neutral, "ethics enumeration")
        #expect(neutralGood.1 == Morals.good, "morals enumeration")
        
        let neutral = try #require("Neutral".parseAlignment, "alignment should be non-nil")
        #expect(neutral.0 == Ethics.neutral, "ethics enumeration")
        #expect(neutral.1 == Morals.neutral, "morals enumeration")
    
        // Test initializing from partial valid string
        let chaotic = try #require("Chaotic".parseAlignment, "alignment should be non-nil")
        #expect(chaotic.0 == Ethics.chaotic, "ethics enumeration")
        #expect(chaotic.1 == Morals.neutral, "morals enumeration")
        
        let good = try #require("Good".parseAlignment, "alignment should be non-nil")
        #expect(good.0 == Ethics.neutral, "ethics enumeration")
        #expect(good.1 == Morals.good, "morals enumeration")
    
        // Test initializing from bad string
        let tooManyWords = "Neutral Neutral Neutral".parseAlignment
        #expect(tooManyWords == nil, "too many words should be nil")
        
        let mismatchedWords = "Foo Bar".parseAlignment
        #expect(mismatchedWords == nil, "mismatched words should be nil")
        
        let wrongWord = "Cat".parseAlignment
        #expect(wrongWord == nil, "wrong word should be nil")
    }
    
    @Test("Alignment dictionary decoding")
    func alignmentDictionaryDecoding() throws {
        let decoder = JSONDecoder()
        
        // Test initializing from dictionary of doubles
        do {
            let lawfulNeutralTraits = """
                {
                    "ethics": 1,
                    "morals": 0.2
                }
                """.data(using: .utf8)!
            let lawfulNeutral = try? decoder.decode(Alignment.self, from: lawfulNeutralTraits)
            let unwrappedLawfulNeutral = try #require(lawfulNeutral, "alignment should be non-nil")
            #expect(unwrappedLawfulNeutral.kind.ethics == Ethics.lawful, "ethics enumeration")
            #expect(unwrappedLawfulNeutral.kind.morals == Morals.neutral, "morals enumeration")
        }
        
        // Test initializing from dictionary of strings
        do {
            let chaoticNeutralTraits = """
                {
                    "ethics": "Chaotic",
                    "morals": "Neutral"
                }
                """.data(using: .utf8)!
            let chaoticNeutral = try? decoder.decode(Alignment.self, from: chaoticNeutralTraits)
            let unwrappedChaoticNeutral = try #require(chaoticNeutral, "alignment should be non-nil")
            #expect(unwrappedChaoticNeutral.kind.ethics == Ethics.chaotic, "ethics enumeration")
            #expect(unwrappedChaoticNeutral.kind.morals == Morals.neutral, "morals enumeration")
        }
        
        // Test initializing from bad dictionary keys
        do {
            let badTraitKeys = """
                {
                    "Howdy": "Lawful",
                    "Doody": "Evil"
                }
                """.data(using: .utf8)!
            let badTrait = try? decoder.decode(Alignment.self, from: badTraitKeys)
            #expect(badTrait == nil, "bad trait keys should be nil")
        }
        
        // Test initializing from bad dictionary values
        do {
            let notStringTraits = """
                {
                    "ethics": ["Chaotic"],
                    "morals": ["Neutral"]
                }
                """.data(using: .utf8)!
            let notString = try? decoder.decode(Alignment.self, from: notStringTraits)
            #expect(notString == nil, "non-string traits should be nil")

            let notValidTraits = """
                {
                    "ethics": "Choatic",
                    "morals": "Eliv"
                }
                """.data(using: .utf8)!
            let notValid = try? decoder.decode(Alignment.self, from: notValidTraits)
            #expect(notValid == nil, "non-valid traits should be nil")
        }
    }
    
    @Test("Alignment string decoding")
    func alignmentStringDecoding() throws {
        let decoder = JSONDecoder()
        
        struct AlignmentContainer: Decodable {
            let alignment: Alignment
        }
        
        // Test string values
        let stringTrait = """
            {
                "alignment": "Chaotic Evil"
            }
            """.data(using: .utf8)!
        
        let decoded = try decoder.decode(AlignmentContainer.self, from: stringTrait)
        #expect("\(decoded.alignment)" == "Chaotic Evil", "decoded string should be round-trip")
        
        let notValidTrait = """
            {
                "alignment": "Hello"
            }
            """.data(using: .utf8)!
        
        // Expect this to throw an error
        #expect(throws: Error.self) {
            try decoder.decode(AlignmentContainer.self, from: notValidTrait)
        }
    }
    
    @Test("Alignment encoding")
    func alignmentEncoding() throws {
        let encoder = JSONEncoder()
        
        struct AlignmentContainer: Encodable {
            let alignment: Alignment
        }
        let container = AlignmentContainer(alignment: Alignment(.chaotic, .good))
        let encoded = try encoder.encode(container)
        let deserialized = try JSONSerialization.jsonObject(with: encoded, options: [])
        
        let dictionary = try #require(deserialized as? [String: Any], "deserialized should be a dictionary")
        let alignmentDict = try #require(dictionary["alignment"] as? [String: Double], "player traits round trip alignment")
        #expect(alignmentDict["ethics"] == -1, "player traits round trip alignment ethics")
        #expect(alignmentDict["morals"] == 1, "player traits round trip alignment morals")
    }
    
    @Test("Stringified encoding")
    func stringifiedEncoding() throws {
        let encoder = JSONEncoder()

        struct AlignmentContainer: Encodable {
            let alignment: Alignment
            
            enum CodingKeys: String, CodingKey {
                case alignment
            }
            
            // Stringify alignment
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode("\(alignment)", forKey: .alignment)
            }
        }
        
        let container = AlignmentContainer(alignment: Alignment(.chaotic, .good))
        let encoded = try encoder.encode(container)
        let deserialized = try #require(try? JSONSerialization.jsonObject(with: encoded, options: []), "player traits round trip")
        
        let dictionary = try #require(deserialized as? [String: String], "should be string dictionary")
        let alignment = try #require(dictionary["alignment"], "alignment should exist")
        #expect(alignment == "Chaotic Good", "player traits round trip alignment")
    }
}
