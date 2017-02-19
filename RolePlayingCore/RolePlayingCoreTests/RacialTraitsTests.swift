//
//  RacialTraitsTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/11/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class RacialTraitsTests: XCTestCase {
    
    func testRacialTraits() {
        // Test typical traits
        do {
            let traits: [String : Any] = [
                "name": "Human",
                "plural": "Humans",
                "ability scores": ["Strength": 1, "Dexterity": 1, "Constitution": 1, "Intelligence": 1, "Wisdom": 1, "Charisma": 1],
                "minimum age": 18,
                "lifespan": 90,
                "base height": "4'8\"",
                "height modifier": "2d10",
                "base weight": 110,
                "weight modifier": "2d4",
                "speed": 30,
                "languages": ["Common"],
                "extra languages": 1]
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNotNil(racialTraits)
            XCTAssertEqual(racialTraits?.name, "Human", "name")
            XCTAssertEqual(racialTraits?.plural, "Humans", "plural")
            XCTAssertEqual(racialTraits?.abilityScoreIncrease.count, 6, "ability score increase")
            if let scores = racialTraits?.abilityScoreIncrease.values {
                for score in scores {
                    XCTAssertEqual(score, 1, "ability score increase")
                }
            }
            
            XCTAssertEqual(racialTraits?.minimumAge, 18, "minimum age")
            XCTAssertEqual(racialTraits?.lifespan, 90, "lifespan")
            XCTAssertEqualWithAccuracy(racialTraits?.baseHeight.value ?? 0, 4.666666, accuracy: 0.000001, "base height")
            
            let heightModifier = racialTraits?.heightModifier as? SimpleDice
            XCTAssertNotNil(heightModifier, "height modifier")
            XCTAssertEqual(heightModifier?.sides, 10, "height modifier")
            XCTAssertEqual(heightModifier?.times, 2, "height modifier")
            
            XCTAssertEqual(racialTraits?.baseWeight.value ?? 0, 110.0, "base height")

            let weightModifier = racialTraits?.weightModifier as? SimpleDice
            XCTAssertNotNil(weightModifier, "weight modifier")
            XCTAssertEqual(weightModifier?.sides, 4, "weight modifier")
            XCTAssertEqual(weightModifier?.times, 2, "weight modifier")

            XCTAssertEqual(racialTraits?.speed, 30, "speed")
            // TODO: XCTAssertEqual(racialTraits?.languages.count, 1, "languages")
            // TODO: XCTAssertEqual(racialTraits?.extraLanguages, 1, "extra languages")
            
            XCTAssertEqual(racialTraits?.aliases.count, 0, "aliases")
            
            XCTAssertEqual(racialTraits?.size, RacialTraits.Size.medium, "size")
            XCTAssertNil(racialTraits?.alignment, "alignment")
        }

        // Test minimum traits
        do {
            let traits: [String : Any] = [
                "name": "Giant Human",
                "plural": "Giant Humans",
                "minimum age": 18,
                "lifespan": 90,
                "base height": "7'8\"",
                "height modifier": "2d10",
                "base weight": 110,
                "speed": 30]
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNotNil(racialTraits)
            XCTAssertEqual(racialTraits?.name, "Giant Human", "name")
            XCTAssertEqual(racialTraits?.plural, "Giant Humans", "plural")
            XCTAssertEqual(racialTraits?.abilityScoreIncrease.count, 6, "ability score increase")
            if let scores = racialTraits?.abilityScoreIncrease.values {
                for score in scores {
                    XCTAssertEqual(score, 0, "ability score increase")
                }
            }
            
            XCTAssertEqual(racialTraits?.minimumAge, 18, "minimum age")
            XCTAssertEqual(racialTraits?.lifespan, 90, "lifespan")
            XCTAssertEqualWithAccuracy(racialTraits?.baseHeight.value ?? 0, 7.666666, accuracy: 0.000001, "base height")
            
            let heightModifier = racialTraits?.heightModifier as? SimpleDice
            XCTAssertNotNil(heightModifier, "height modifier")
            XCTAssertEqual(heightModifier?.sides, 10, "height modifier")
            XCTAssertEqual(heightModifier?.times, 2, "height modifier")
            
            XCTAssertEqual(racialTraits?.baseWeight.value ?? 0, 110.0, "base height")
            
            let weightModifier = racialTraits?.weightModifier as? DiceModifier
            XCTAssertEqual(weightModifier?.modifier, 0, "weight modifier")
            
            XCTAssertEqual(racialTraits?.speed, 30, "speed")
            
            XCTAssertEqual(racialTraits?.aliases.count, 0, "aliases")
            XCTAssertNil(racialTraits?.alignment, "alignment")
            
            XCTAssertEqual(racialTraits?.size, RacialTraits.Size.large, "size")
        }
        
        // Test optional traits
        do {
            let traits: [String : Any] = [
                "name": "Small Human",
                "plural": "Small Humans",
                "minimum age": 18,
                "lifespan": 90,
                "base height": "2'8\"",
                "height modifier": "2d10",
                "base weight": 110,
                "speed": 30,
                "alignment": "Lawful Neutral",
                "aliases": ["Big Human"]
                ]
            
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNotNil(racialTraits)
            
            XCTAssertEqual(racialTraits?.size, RacialTraits.Size.small, "size")

            XCTAssertNotNil(racialTraits?.alignment, "alignment should be non-nil")
            let foundAlignment = racialTraits?.alignment?.kind ?? Alignment(.neutral, .neutral).kind
            XCTAssertEqual(foundAlignment, Alignment(.lawful, .neutral).kind, "alignment kind")
            
            XCTAssertEqual(racialTraits?.aliases.count, 1, "aliases count")
        }
    }
    
    func testMissingTraits() {
        do {
            let racialTraits = RacialTraits(from: nil)
            XCTAssertNil(racialTraits)
        }

        // Test that each missing trait results in nil
        do {
            let traits: [String: Any] = [:]
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNil(racialTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Giant Human"]
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNil(racialTraits)
        }
        
        
        do {
            let traits: [String : Any] = [
                "name": "Giant Human",
                "plural": "Giant Humans"]
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNil(racialTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Giant Human",
                "plural": "Giant Humans",
                "minimum age": 18]
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNil(racialTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Giant Human",
                "plural": "Giant Humans",
                "minimum age": 18,
                "lifespan": 90]
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNil(racialTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Giant Human",
                "plural": "Giant Humans",
                "minimum age": 18,
                "lifespan": 90,
                "base height": "7'8\""]
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNil(racialTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Giant Human",
                "plural": "Giant Humans",
                "minimum age": 18,
                "lifespan": 90,
                "base height": "7'8\"",
                "height modifier": "2d10"]
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNil(racialTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Giant Human",
                "plural": "Giant Humans",
                "minimum age": 18,
                "lifespan": 90,
                "base height": "7'8\"",
                "height modifier": "2d10",
                "base weight": 110]
            let racialTraits = RacialTraits(from: traits)
            XCTAssertNil(racialTraits)
        }
    }

    func testSubraceTraits() {
        let traits: [String : Any] = [
            "name": "Human",
            "plural": "Humans",
            "minimum age": 18,
            "lifespan": 90,
            "base height": "4'8\"",
            "height modifier": "2d10",
            "base weight": 110,
            "speed": 30]
        if let racialTraits = RacialTraits(from: traits) {
            // Test half overrides
            do {
                let subTraits: [String: Any] = [
                    "name": "Subhuman",
                    "plural": "Subhumans",
                    "minimum age": 15,
                    "lifespan": 60,
                    "base height": "2'8\"",
                    "height modifier": "2d6",
                    "base weight": 45,
                    "speed": 10
                ]
                let subracialTraits = RacialTraits(from: subTraits, parent: racialTraits)
                
                XCTAssertNotNil(subracialTraits)
                XCTAssertEqual(subracialTraits.name, "Subhuman", "name")
                XCTAssertEqual(subracialTraits.plural, "Subhumans", "plural")
                XCTAssertEqual(subracialTraits.abilityScoreIncrease.count, 6, "ability score increase")
                for score in subracialTraits.abilityScoreIncrease.values {
                    XCTAssertEqual(score, 0, "ability score increase")
                }
                
                XCTAssertEqual(subracialTraits.minimumAge, 15, "minimum age")
                XCTAssertEqual(subracialTraits.lifespan, 60, "lifespan")
                XCTAssertEqualWithAccuracy(subracialTraits.baseHeight.value, 2.666666, accuracy: 0.000001, "base height")
                
                let heightModifier = subracialTraits.heightModifier as? SimpleDice
                XCTAssertNotNil(heightModifier, "height modifier")
                XCTAssertEqual(heightModifier?.sides, 6, "height modifier")
                XCTAssertEqual(heightModifier?.times, 2, "height modifier")
                
                XCTAssertEqual(subracialTraits.baseWeight.value, 45.0, "base height")
                
                let weightModifier = subracialTraits.weightModifier as? SimpleDice
                XCTAssertNil(weightModifier, "weight modifier")
                
                XCTAssertEqual(subracialTraits.speed, 10, "speed")
                // TODO: XCTAssertEqual(subracialTraits?.languages.count, 1, "languages")
                // TODO: XCTAssertEqual(subracialTraits?.extraLanguages, 1, "extra languages")
                
                XCTAssertEqual(subracialTraits.aliases.count, 0, "aliases")
                
                XCTAssertEqual(subracialTraits.size, RacialTraits.Size.small, "size")
                XCTAssertNil(subracialTraits.alignment, "alignment")

                XCTAssertEqual(subracialTraits.hitPointsBonus, 0, "hit points bonus")

            }
            
            // Test the other half overrides
            do {
                let subTraits: [String: Any] = [
                    "aliases": ["Folks"],
                    "weight modifier": "d8",
                    "ability scores": ["Strength": 2, "Dexterity": 1, "Constitution": 3, "Intelligence": 2, "Wisdom": 1, "Charisma": 1],
                    "alignment": "Neutral",
                    "darkvision": 20,
                    "hit points": 2
                ]
                let subracialTraits = RacialTraits(from: subTraits, parent: racialTraits)
                
                XCTAssertNotNil(subracialTraits)
                XCTAssertEqual(subracialTraits.name, "Human", "name")
                XCTAssertEqual(subracialTraits.plural, "Humans", "plural")
                XCTAssertEqual(subracialTraits.abilityScoreIncrease.count, 6, "ability score increase")
                for score in subracialTraits.abilityScoreIncrease.values {
                    XCTAssertNotEqual(score, 0, "ability score increase")
                }
                
                XCTAssertEqual(subracialTraits.minimumAge, 18, "minimum age")
                XCTAssertEqual(subracialTraits.lifespan, 90, "lifespan")
                XCTAssertEqualWithAccuracy(subracialTraits.baseHeight.value, 4.666666, accuracy: 0.000001, "base height")
                
                let heightModifier = subracialTraits.heightModifier as? SimpleDice
                XCTAssertNotNil(heightModifier, "height modifier")
                XCTAssertEqual(heightModifier?.sides, 10, "height modifier")
                XCTAssertEqual(heightModifier?.times, 2, "height modifier")
                
                XCTAssertEqual(subracialTraits.baseWeight.value, 110, "base height")
                
                let weightModifier = subracialTraits.weightModifier as? SimpleDice
                XCTAssertNotNil(weightModifier, "weight modifier")
                XCTAssertEqual(weightModifier?.sides, 8, "weight modifier")
                XCTAssertEqual(weightModifier?.times, 1, "weight modifier")
                
                XCTAssertEqual(subracialTraits.speed, 30, "speed")
                // TODO: XCTAssertEqual(subracialTraits?.languages.count, 1, "languages")
                // TODO: XCTAssertEqual(subracialTraits?.extraLanguages, 1, "extra languages")
                
                XCTAssertEqual(subracialTraits.aliases.count, 1, "aliases")
                
                XCTAssertEqual(subracialTraits.size, RacialTraits.Size.medium, "size")
                XCTAssertNotNil(subracialTraits.alignment, "alignment")
                let foundAlignment = subracialTraits.alignment?.kind ?? Alignment(.lawful, .good).kind
                XCTAssertEqual(foundAlignment, Alignment(.neutral, .neutral).kind, "alignment kind")

                XCTAssertEqual(subracialTraits.hitPointsBonus, 2, "hit points bonus")
            }
        }
    }
}
