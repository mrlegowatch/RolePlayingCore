//
//  AlignmentTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/11/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

import XCTest

import RolePlayingCore

class AlignmentTests: XCTestCase {

    func testEthics() {
        // Test the literal values
        do {
            XCTAssertEqual(Ethics.lawful.rawValue, "Lawful", "lawful string")
            XCTAssertEqual(Ethics.neutral.rawValue, "Neutral", "neutral string")
            XCTAssertEqual(Ethics.chaotic.rawValue, "Chaotic", "chaotic string")
            
            XCTAssertEqual(Ethics.lawful.value, 1.0, "lawful value")
            XCTAssertEqual(Ethics.neutral.value, 0.0, "neutral value")
            XCTAssertEqual(Ethics.chaotic.value, -1.0, "chaotic value")
        }
        
        // Test creation by raw value
        do {
            let lawful = Ethics(rawValue: "Lawful")
            XCTAssertNotNil(lawful, "lawful should be non-nil")
            XCTAssertEqual(lawful, Ethics.lawful, "lawful enum")
            XCTAssertEqual(lawful?.value, 1.0, "lawful value")
            
            let neutral = Ethics(rawValue: "Neutral")
            XCTAssertNotNil(neutral, "neutral should be non-nil")
            XCTAssertEqual(neutral, Ethics.neutral, "neutral enum")
            XCTAssertEqual(neutral?.value, 0.0, "neutral value")
            
            let chaotic = Ethics(rawValue: "Chaotic")
            XCTAssertNotNil(chaotic, "chaotic should be non-nil")
            XCTAssertEqual(chaotic, Ethics.chaotic, "chaotic enum")
            XCTAssertEqual(chaotic?.value, -1.0, "chaotic value")
        }
        
        // Test creation by Double value
        do {
            let lawful = Ethics(0.8)
            XCTAssertNotNil(lawful, "lawful should be non-nil")
            XCTAssertEqual(lawful, Ethics.lawful, "lawful enum")
            XCTAssertEqual(lawful.value, 1.0, "lawful value")
            
            let neutral = Ethics(-0.1)
            XCTAssertNotNil(neutral, "neutral should be non-nil")
            XCTAssertEqual(neutral, Ethics.neutral, "neutral enum")
            XCTAssertEqual(neutral.value, 0.0, "neutral value")
            
            let chaotic = Ethics(-0.34)
            XCTAssertNotNil(chaotic, "chaotic should be non-nil")
            XCTAssertEqual(chaotic, Ethics.chaotic, "chaotic enum")
            XCTAssertEqual(chaotic.value, -1.0, "chaotic value")
        }
    }
    
    func testMorals() {
        // Test the literal values
        do {
            XCTAssertEqual(Morals.good.rawValue, "Good", "good string")
            XCTAssertEqual(Morals.neutral.rawValue, "Neutral", "neutral string")
            XCTAssertEqual(Morals.evil.rawValue, "Evil", "evil string")
            
            XCTAssertEqual(Morals.good.value, 1.0, "good value")
            XCTAssertEqual(Morals.neutral.value, 0.0, "neutral value")
            XCTAssertEqual(Morals.evil.value, -1.0, "evil value")
        }
        
        // Test creation by raw value
        do {
            let good = Morals(rawValue: "Good")
            XCTAssertNotNil(good, "good should be non-nil")
            XCTAssertEqual(good, Morals.good, "good enum")
            XCTAssertEqual(good?.value, 1.0, "good value")
            
            let neutral = Morals(rawValue: "Neutral")
            XCTAssertNotNil(neutral, "neutral should be non-nil")
            XCTAssertEqual(neutral, Morals.neutral, "neutral enum")
            XCTAssertEqual(neutral?.value, 0.0, "neutral value")
            
            let evil = Morals(rawValue: "Evil")
            XCTAssertNotNil(evil, "evil should be non-nil")
            XCTAssertEqual(evil, Morals.evil, "evil enum")
            XCTAssertEqual(evil?.value, -1.0, "evil value")
        }
        
        // Test creation by Double value
        do {
            let good = Morals(0.334)
            XCTAssertNotNil(good, "good should be non-nil")
            XCTAssertEqual(good, Morals.good, "good enum")
            XCTAssertEqual(good.value, 1.0, "good value")
            
            let neutral = Morals(0.2)
            XCTAssertNotNil(neutral, "neutral should be non-nil")
            XCTAssertEqual(neutral, Morals.neutral, "neutral enum")
            XCTAssertEqual(neutral.value, 0.0, "neutral value")
            
            let evil = Morals(-0.9)
            XCTAssertNotNil(evil, "evil should be non-nil")
            XCTAssertEqual(evil, Morals.evil, "evil enum")
            XCTAssertEqual(evil.value, -1.0, "evil value")
        }

    }
    
    func testAlignmentType() {
        // Test creation by raw value
        do {
            let neutralGood = Alignment.Kind(.neutral, .good)
            XCTAssertEqual(neutralGood.description, "Neutral Good", "description")
            
            let neutralEvil = Alignment.Kind(.neutral, .evil)
            XCTAssertEqual(neutralEvil.description, "Neutral Evil", "description")
            
            let chaoticNeutral = Alignment.Kind(.chaotic, .neutral)
            XCTAssertEqual(chaoticNeutral.description, "Chaotic Neutral", "description")
            
            XCTAssertEqual(neutralGood, Alignment.Kind(.neutral, .good), "equatable")
            XCTAssertNotEqual(neutralGood, neutralEvil, "equatable")
            XCTAssertNotEqual(neutralEvil, chaoticNeutral, "equatable")
        }
        
        // Test creation by Double value
        do {
            let lawfulNeutral = Alignment(ethics: 0.7, morals: 0.0)
            XCTAssertEqual(lawfulNeutral.description, "Lawful Neutral", "description")
            
            let neutral = Alignment(ethics: 0.1, morals: -0.2)
            XCTAssertEqual(neutral.description, "Neutral", "description")
            
            let chaoticGood = Alignment(ethics: -1, morals: 1)
            XCTAssertEqual(chaoticGood.description, "Chaotic Good", "description")
        }
    }
    
    func testAlignment() {
        // Test creation by raw value
        do {
            let lawfulGood = Alignment(.lawful, .good)
            XCTAssertEqual(lawfulGood.description, "Lawful Good", "description")

            let neutralGood = Alignment(.neutral, .good)
            XCTAssertEqual(neutralGood.description, "Neutral Good", "description")

            let chaoticNeutral = Alignment(.chaotic, .neutral)
            XCTAssertEqual(chaoticNeutral.description, "Chaotic Neutral", "description")
            
            XCTAssertEqual(lawfulGood, Alignment(.lawful, .good), "equatable")
            XCTAssertNotEqual(lawfulGood, neutralGood, "equatable")
            XCTAssertNotEqual(neutralGood, chaoticNeutral, "equatable")
        }
        
        // Test creation by Double value
        do {
            let lawfulNeutral = Alignment(ethics: 0.9, morals: 0.0)
            XCTAssertEqual(lawfulNeutral.description, "Lawful Neutral", "description")
            
            let neutral = Alignment(ethics: 0.1, morals: -0.1)
            XCTAssertEqual(neutral.description, "Neutral", "description")
            
            let chaoticEvil = Alignment(ethics: -1, morals: -1)
            XCTAssertEqual(chaoticEvil.description, "Chaotic Evil", "description")
        }
        
        // Test changing alignment
        do {
            var alignment = Alignment(.neutral, .evil)
            XCTAssertEqual(alignment.ethics, 0, "ethics value")
            XCTAssertEqual(alignment.morals, -1, "morals value")
            XCTAssertEqual(alignment.kind.ethics, Ethics.neutral, "ethics enumeration")
            XCTAssertEqual(alignment.kind.morals, Morals.evil, "morals enumeration")

            
            alignment.morals += 0.8
            XCTAssertEqualWithAccuracy(alignment.morals, -0.2, accuracy: 0.00001, "morals value")
            XCTAssertEqual(alignment.kind.ethics, Ethics.neutral, "ethics enumeration")
            XCTAssertEqual(alignment.kind.morals, Morals.neutral, "morals enumeration")

            // Try to exceed 1.0 and confirm the ethics value did not change
            alignment.ethics += 5.4
            XCTAssertEqual(alignment.ethics, 0, "ethics value")
            XCTAssertEqual(alignment.kind.ethics, Ethics.neutral, "ethics enumeration")
            XCTAssertEqual(alignment.kind.morals, Morals.neutral, "morals enumeration")

            alignment.morals += 0.8
            XCTAssertEqualWithAccuracy(alignment.morals, 0.6, accuracy: 0.00001, "morals value")
            XCTAssertEqual(alignment.kind.ethics, Ethics.neutral, "ethics enumeration")
            XCTAssertEqual(alignment.kind.morals, Morals.good, "morals enumeration")

            // Try to exceed 1.0 and confirm that morals value did not change
            alignment.morals += 0.8
            XCTAssertEqualWithAccuracy(alignment.morals, 0.6, accuracy: 0.00001, "morals value")
            XCTAssertEqual(alignment.kind.ethics, Ethics.neutral, "ethics enumeration")
            XCTAssertEqual(alignment.kind.morals, Morals.good, "morals enumeration")
}
    }
    
    func testAlignmentParsing() {
        let decoder = JSONDecoder()
        
        // Test initializing from valid string
        do {
            let neutralGood = "Neutral Good".parseAlignment
            XCTAssertNotNil(neutralGood, "alignment should be non-nil")
            XCTAssertEqual(neutralGood?.0, Ethics.neutral, "ethics enumeration")
            XCTAssertEqual(neutralGood?.1, Morals.good, "morals enumeration")
            
            let neutral = "Neutral".parseAlignment
            XCTAssertNotNil(neutral, "alignment should be non-nil")
            XCTAssertEqual(neutral?.0, Ethics.neutral, "ethics enumeration")
            XCTAssertEqual(neutral?.1, Morals.neutral, "morals enumeration")
        }
        
        // Test initializing from partial valid string
        do {
            let chaotic = "Chaotic".parseAlignment
            XCTAssertNotNil(chaotic, "alignment should be non-nil")
            XCTAssertEqual(chaotic?.0, Ethics.chaotic, "ethics enumeration")
            XCTAssertEqual(chaotic?.1, Morals.neutral, "morals enumeration")
            
            let good = "Good".parseAlignment
            XCTAssertNotNil(good, "alignment should be non-nil")
            XCTAssertEqual(good?.0, Ethics.neutral, "ethics enumeration")
            XCTAssertEqual(good?.1, Morals.good, "morals enumeration")
        }
        
        // Test initializing from bad string
        do {
            let tooManyWords = "Neutral Neutral Neutral".parseAlignment
            XCTAssertNil(tooManyWords, "too many words should be nil")
            
            let mismatchedWords = "Foo Bar".parseAlignment
            XCTAssertNil(mismatchedWords, "mismatched words should be nil")
        }
        
        // Test initializing from dictionary of doubles
        do {
            let lawfulNeutralTraits = """
                {
                    "ethics": 1,
                    "morals": 0.2
                }
                """.data(using: .utf8)!
            let lawfulNeutral = try? decoder.decode(Alignment.self, from: lawfulNeutralTraits)
            XCTAssertNotNil(lawfulNeutral, "alignment should be non-nil")
            XCTAssertEqual(lawfulNeutral?.kind.ethics, Ethics.lawful, "ethics enumeration")
            XCTAssertEqual(lawfulNeutral?.kind.morals, Morals.neutral, "morals enumeration")

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
            XCTAssertNotNil(chaoticNeutral, "alignment should be non-nil")
            XCTAssertEqual(chaoticNeutral?.kind.ethics, Ethics.chaotic, "ethics enumeration")
            XCTAssertEqual(chaoticNeutral?.kind.morals, Morals.neutral, "morals enumeration")
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
            XCTAssertNil(badTrait, "bad trait keys should be nil")
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
            XCTAssertNil(notString, "non-string traits should be nil")

            let notValidTraits = """
                {
                    "ethics": "Choatic",
                    "morals": "Eliv"
                }
                """.data(using: .utf8)!
            let notValid = try? decoder.decode(Alignment.self, from: notValidTraits)
            XCTAssertNil(notValid, "non-valid traits should be nil")
        }
        
    }
    
}
