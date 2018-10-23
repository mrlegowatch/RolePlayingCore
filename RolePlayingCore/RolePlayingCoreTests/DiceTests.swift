//
//  DiceTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore



/// Use a sample size large enough to hit relatively tight ranges of
/// expected mean, min and max values below.
let sampleSize = 1024

/// Consequences of testing with the random number generator are:
///
///  - Tolerance may be wide enough in some cases that they may not catch all regressions (false positives)
///  - Once in a blue moon, tests may fail just outside of the tolerance (false negatives)
///
/// As modest countermeasure, print statements were added to the test output, so that 
/// manual inspection can be performed, to help determine what might be happenening.

class DiceTests: XCTestCase {
    
    func testCreateDie() {
        // Test raw value creation matches enums
        let d4 = Die(rawValue: 4)
        XCTAssertEqual(d4, Die.d4, "d4")
        let d6 = Die(rawValue: 6)
        XCTAssertEqual(d6, Die.d6, "d6")
        let d8 = Die(rawValue: 8)
        XCTAssertEqual(d8, Die.d8, "d8")
        let d10 = Die(rawValue: 10)
        XCTAssertEqual(d10, Die.d10, "d10")
        let d12 = Die(rawValue: 12)
        XCTAssertEqual(d12, Die.d12, "d12")
        let d20 = Die(rawValue: 20)
        XCTAssertEqual(d20, Die.d20, "d20")
        let d100 = Die(rawValue: 100)
        XCTAssertEqual(d100, Die.d100, "Dice %")
    }
    
    func testCreateDieNegative() {
        // Negative tests: bad raw values and strings
        let badDie = Die(rawValue: 7)
        XCTAssertNil(badDie, "d7 should be nil")
    }
    
    func testRollDie() {
        print("Die d4:")
        // Test rolling 1 time with d4
        let die: Die = .d4
        
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = die.roll()
            XCTAssertTrue((1...4).contains(roll), "rolling d4, got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            
        }
        let mean = Double(sum)/Double(sampleSize)
        XCTAssertTrue((2.0...3.0).contains(mean), "expected mean around 2.5, got \(mean)")
        
        XCTAssertEqual(minValue, 1, "min value")
        XCTAssertEqual(maxValue, 4, "max value")
        
        XCTAssertEqual(Die.d4.description, "d4", "d4 description")
        
        // Code coverage and manual inspection of test output:
        print("  mean = \(mean) [expect 2.5]")
    }
    
    func testDiceModifier() {
        let diceModifier = DiceModifier(7)
        let diceRoll = diceModifier.roll()
        XCTAssertEqual(diceModifier.modifier, 7, "dice modifier value")
        XCTAssertEqual(diceRoll.result, 7, "dice modifier roll")
        XCTAssertEqual(diceModifier.sides, 7, "dice modifier sides")
        XCTAssertEqual(diceModifier.description, "7", "dice modifier description")
        XCTAssertEqual(diceRoll.description, "7", "dice modifier lastRollDescription")
    }
    
    func testSimpleDice() {
        // Test d12
        do {
            print("SimpleDice d12:")
            let simpleDice = SimpleDice(.d12)
            
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = simpleDice.roll().result
                XCTAssertTrue((1...12).contains(roll), "rolling d12, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((6.0...7.0).contains(mean), "expected mean around 6.5, got \(mean)")

            // TODO: Because 2x produces a bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 1, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 12, "max value")
            
            XCTAssertEqual(simpleDice.sides, 12, "SimpleDice sides")
            XCTAssertEqual("\(simpleDice.description)", "d12", "SimpleDice description")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 6.5]")
            let lastRoll = simpleDice.roll()
            print("  lastRoll = \"\(lastRoll.description)\"")
        }
        
        // Test 2d8
        do {
            print("SimpleDice 2d8:")
            let simpleDice = SimpleDice(.d8, times: 2)
            
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = simpleDice.roll().result
                XCTAssertTrue((2...16).contains(roll), "rolling 2d8, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((7.5...9.5).contains(mean), "expected mean around 8.5, got \(mean)")
            
            // TODO: Because 2x produces a bell curve, the actual min/max may be harder to get in a sample
            XCTAssertEqual(minValue, 2, "min value")
            XCTAssertEqual(maxValue, 16, "max value")
            
            XCTAssertEqual(simpleDice.sides, 8, "SimpleDice sides")
            XCTAssertEqual("\(simpleDice.description)", "2d8", "SimpleDice description")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 8.5]")
            let lastRoll = simpleDice.roll()
            print("  lastRoll = \"\(lastRoll.description)\"")
        }
    }
    
    func testDroppingDice() {
        // Test 4d6, dropping the lowest
        do {
            print("SimpleDice 4d6-L:")
            let simpleDice = DroppingDice(.d6, times: 4, drop: .lowest)

            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = simpleDice.roll().result
                XCTAssertTrue((3...18).contains(roll), "rolling 4d6-L, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((11.0...13.5).contains(mean), "expected mean around 12.25, got \(mean)")
            
            // TODO: Because 4x-L produces a sharp bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 5, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 16, "max value")
            
            XCTAssertEqual(simpleDice.sides, 6, "SimpleDice sides")
            XCTAssertEqual("\(simpleDice.description)", "4d6-L", "SimpleDice description")

            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 12.25]")
            let lastRoll = simpleDice.roll()
            print("  lastRoll = \"\(lastRoll.description)\"")
            
            // TODO: verify that it is actually dropping the lowest score.
        }
        
        // Test 3d4, dropping the highest
        do {
            print("SimpleDice 3d4-H:")
            let simpleDice = DroppingDice(.d4, times: 3, drop: .highest)
            
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = simpleDice.roll().result
                XCTAssertTrue((2...8).contains(roll), "rolling 3d4-H, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((3.7...4.3).contains(mean), "expected mean around 4, got \(mean)")
            
            XCTAssertEqual(minValue, 2, "min value")
            XCTAssertEqual(maxValue, 8, "max value")
            
            XCTAssertEqual(simpleDice.sides, 4, "SimpleDice sides")
            XCTAssertEqual("\(simpleDice.description)", "3d4-H", "SimpleDice description")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 4]")
            let lastRoll = simpleDice.roll()
            print("  lastRoll = \"\(lastRoll.description)\"")

            // TODO: verify that it is actually dropping the highest score.

        }
    }
    
    func testCompoundDice() {
        // Test 2d8+4
        do {
            print("CompoundDice 2d8+4:")

            let compoundDice = CompoundDice(.d8, times: 2, modifier: 4)

            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = compoundDice.roll().result
                XCTAssertTrue((6...20).contains(roll), "rolling 2d8+4, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((12.0...14.0).contains(mean), "expected mean around 13.0, got \(mean)")

            XCTAssertEqual(minValue, 6, "min value")
            XCTAssertEqual(maxValue, 20, "max value")
            
            XCTAssertEqual(compoundDice.sides, 8, "CompoundDice sides")

            XCTAssertEqual("\(compoundDice.description)", "2d8+4", "CompoundDice description")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 13.0]")
            let lastRoll = compoundDice.roll()
            print("  lastRoll = \"\(lastRoll.description)\"")
        }
    
        // Test 2d8+d4
        do {
            print("CompoundDice 2d8+d4:")
            let compoundDice = CompoundDice(lhs: SimpleDice(.d8, times: 2), rhs: SimpleDice(.d4), mathOperator: "+")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = compoundDice.roll().result
                XCTAssertTrue((3...20).contains(roll), "rolling 2d8+d4, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((11.0...12.0).contains(mean), "expected mean around 11.5, got \(mean)")
            
            XCTAssertLessThanOrEqual(minValue, 4, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 19, "max value")
            
            XCTAssertEqual(compoundDice.sides, 8, "CompoundDice sides")
            XCTAssertEqual("\(compoundDice.description)", "2d8+d4", "CompoundDice description")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 11.5]")
            let lastRoll = compoundDice.roll()
            print("  lastRoll = \"\(lastRoll.description)\"")
        }
    }

}

