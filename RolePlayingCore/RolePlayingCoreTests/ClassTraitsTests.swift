//
//  ClassTraitsTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/13/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class ClassTraitsTests: XCTestCase {
    
    func testClassTraits() {
        // Test minimum required traits
        do {
            let traits: [String : Any] = [
                "name": "Fighter",
                "plural": "Fighters",
                "hit dice": "d10",
                "primary ability": ["Strength"],
                "alternate primary ability": ["Dexterity"],
                "saving throws": ["Strength", "Constitution"],
                "starting wealth": "5d4x10"]
            let classTraits = ClassTraits(from: traits)
            XCTAssertNotNil(classTraits)
            XCTAssertEqual(classTraits?.name, "Fighter", "name")
            XCTAssertEqual(classTraits?.plural, "Fighters", "plural")
            let hitDice = classTraits?.hitDice as? SimpleDice
            XCTAssertNotNil(hitDice, "hit dice")
            XCTAssertEqual(hitDice?.sides, 10, "hit dice sides")
            XCTAssertEqual(hitDice?.times, 1, "hit dice times")

            let primaryAbility: [Ability] = classTraits?.primaryAbility ?? []
            XCTAssertEqual(primaryAbility, [Ability("Strength")], "primary ability")
            
            let savingThrows: [Ability] = classTraits?.savingThrows ?? []
            XCTAssertEqual(savingThrows, [Ability("Strength"), Ability("Constitution")], "saving throws")

            let startingWealth = classTraits?.startingWealth as? CompoundDice
            XCTAssertNotNil(startingWealth, "starting wealth")
            
            XCTAssertNil(classTraits?.experiencePoints, "experience points")
        }
        
        // Test traits with optional experience points
        do {
            let traits: [String : Any] = [
                "name": "Fighter",
                "plural": "Fighters",
                "hit dice": "d10",
                "primary ability": ["Strength"],
                "alternate primary ability": ["Dexterity"],
                "saving throws": ["Strength", "Constitution"],
                "starting wealth": "5d4x10",
                "experience points": [300, 900, 2700]]
            let classTraits = ClassTraits(from: traits)
            XCTAssertNotNil(classTraits)
        
            let experiencePoints: [Int] = classTraits?.experiencePoints ?? []
            XCTAssertEqual(experiencePoints, [300, 900, 2700], "experience points")
        }
    }

    func testMissingTraits() {
        do {
            let classTraits = ClassTraits(from: nil)
            XCTAssertNil(classTraits)
        }
        // Test that each missing trait results in nil
        do {
            let traits: [String: Any] = [:]
            let classTraits = ClassTraits(from: traits)
            XCTAssertNil(classTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Fighter"]
            let classTraits = ClassTraits(from: traits)
            XCTAssertNil(classTraits)
        }
        
        
        do {
            let traits: [String : Any] = [
                "name": "Fighter",
                "plural": "Fighters"]
            let classTraits = ClassTraits(from: traits)
            XCTAssertNil(classTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Fighter",
                "plural": "Fighters",
                "hit dice": "d10"]
            let classTraits = ClassTraits(from: traits)
            XCTAssertNil(classTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Fighter",
                "plural": "Fighters",
                "hit dice": "d10",
                "primary ability": ["Strength"]]
            let classTraits = ClassTraits(from: traits)
            XCTAssertNil(classTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Fighter",
                "plural": "Fighters",
                "hit dice": "d10",
                "primary ability": ["Strength"],
                "alternate primary ability": ["Dexterity"]]
            let classTraits = ClassTraits(from: traits)
            XCTAssertNil(classTraits)
        }
        
        do {
            let traits: [String : Any] = [
                "name": "Fighter",
                "plural": "Fighters",
                "hit dice": "d10",
                "primary ability": ["Strength"],
                "alternate primary ability": ["Dexterity"],
                "saving throws": ["Strength", "Constitution"]]
            let classTraits = ClassTraits(from: traits)
            XCTAssertNil(classTraits)
        }
    }

}
