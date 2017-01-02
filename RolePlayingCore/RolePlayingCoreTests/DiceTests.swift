//
//  DiceTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

/// Use a sample size large enough to hit relatively tight ranges of 
/// expected mean values below.
let sampleSize = 512


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
        // Test rolling 1 time with d4
        let die: Die = .d4
        
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0..<sampleSize {
            let roll = die.roll()
            XCTAssertTrue((1...4).contains(roll), "rolling a d4, got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            
        }
        let mean = Double(sum)/Double(sampleSize)
        print("  mean of d4 = \(mean) [expect 2.5]")
        XCTAssertTrue((2.0...3.0).contains(mean), "expected mean around 2.5, got \(mean)")
        
        XCTAssertEqual(minValue, 1, "min value")
        XCTAssertEqual(maxValue, 4, "max value")
        
        XCTAssertEqual(Die.d4.description, "d4", "d4 description")
    }
    
    func testDiceModifier() {
        let diceModifier = DiceModifier(7)
        
        XCTAssertEqual(diceModifier.modifier, 7, "dice modifier value")
        XCTAssertEqual(diceModifier.roll(), 7, "dice modifier roll")
        XCTAssertEqual(diceModifier.sides, 7, "dice modifier sides")
        XCTAssertEqual(diceModifier.lastRoll, [7], "dice modifier lastRoll")
        XCTAssertEqual(diceModifier.description, "7", "dice modifier description")
        XCTAssertEqual(diceModifier.result, "7", "dice modifier result")
    }
    
    func testSimpleDice() {
        // Test d12
        do {
            let simpleDice = SimpleDice(.d12)
            XCTAssertEqual(simpleDice.lastRoll.count, 0, "last roll should initially be 0 count")
            XCTAssertEqual(simpleDice.result, "", "result should initially be empty")
            
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = simpleDice.roll()
                XCTAssertTrue((1...12).contains(roll), "rolling a d12, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of d12 = \(mean) [expect 13.0]")
            XCTAssertTrue((6.0...7.0).contains(mean), "expected mean around 11.0, got \(mean)")

            // TODO: Because 2x produces a bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 1, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 12, "max value")
            
            XCTAssertEqual(simpleDice.sides, 12, "SimpleDice sides")
            XCTAssertEqual(simpleDice.lastRoll.count, 1, "SimpleDice roll count")
            XCTAssertEqual("\(simpleDice.description)", "d12", "SimpleDice description")
            
            // Code coverage and manual inspection of test output:
            print("SimpleDice d12:\n  lastRoll = \(simpleDice.lastRoll)\n  result = \"\(simpleDice.result)\"")
        }
        
        // test 2d8
        do {
            let simpleDice = SimpleDice(.d8, times: 2)
            
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = simpleDice.roll()
                XCTAssertTrue((2...16).contains(roll), "rolling a d8, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of d12 = \(mean) [expect 13.0]")
            XCTAssertTrue((7.5...9.5).contains(mean), "expected mean around 11.0, got \(mean)")
            
            // TODO: Because 2x produces a bell curve, the actual min/max may be harder to get in a sample
            XCTAssertEqual(minValue, 2, "min value")
            XCTAssertEqual(maxValue, 16, "max value")
            
            XCTAssertEqual(simpleDice.sides, 8, "SimpleDice sides")
            XCTAssertEqual(simpleDice.lastRoll.count, 2, "SimpleDice roll count")
            XCTAssertEqual("\(simpleDice.description)", "2d8", "SimpleDice description")
            
            // Code coverage and manual inspection of test output:
            print("SimpleDice d12:\n  lastRoll = \(simpleDice.lastRoll)\n  result = \"\(simpleDice.result)\"")
        }
    }
    
    func testDroppingDice() {
        // Test 4d6, dropping the lowest
        do {
            let simpleDice = DroppingDice(.d6, times: 4, dropping: .lowest)
            XCTAssertEqual(simpleDice.lastRoll.count, 0, "last roll should initially be 0 count")
            XCTAssertEqual(simpleDice.result, "", "result should initially be empty")
            XCTAssertNil(simpleDice.droppedRoll, "droppedRoll() should initially be nil")
            XCTAssertNil(simpleDice.droppedIndex, "droppedIndex() should initially be nil")

            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = simpleDice.roll()
                XCTAssertTrue((3...18).contains(roll), "rolling a d6 4 times dropping lowest, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of 4d6-L = \(mean) [expect 12.25]")
            XCTAssertTrue((11.0...13.5).contains(mean), "expected mean around 12.25, got \(mean)")
            
            // TODO: Because 4x-L produces a sharp bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 5, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 16, "max value")
            
            XCTAssertEqual(simpleDice.sides, 6, "SimpleDice sides")
            XCTAssertEqual(simpleDice.lastRoll.count, 3, "SimpleDice roll count")
            XCTAssertEqual("\(simpleDice.description)", "4d6-L", "SimpleDice description")
            
            // Code coverage and manual inspection of test output:
            print("SimpleDice 4d6-L:\n  lastRoll = \(simpleDice.dice.lastRoll)\n  result = \"\(simpleDice.result)\"")
            
            let lowest = simpleDice.dice.lastRoll.min()!
            let index = simpleDice.dice.lastRoll.index(of: lowest)
            XCTAssertEqual(lowest, simpleDice.droppedRoll, "dropped roll")
            XCTAssertEqual(index, simpleDice.droppedIndex, "dropped index")
        }
        
        // Test 2d4, dropping the highest
        do {
            let simpleDice = DroppingDice(.d4, times: 3, dropping: .highest)
            
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = simpleDice.roll()
                XCTAssertTrue((2...8).contains(roll), "rolling a d4 3 times dropping highest, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of 3d4-H = \(mean) [expect 4]")
            XCTAssertTrue((3.7...4.3).contains(mean), "expected mean around 4, got \(mean)")
            
            XCTAssertEqual(minValue, 2, "min value")
            XCTAssertEqual(maxValue, 8, "max value")
            
            XCTAssertEqual(simpleDice.sides, 4, "SimpleDice sides")
            XCTAssertEqual("\(simpleDice.description)", "3d4-H", "SimpleDice description")
            
            // Code coverage and manual inspection of test output:
            print("SimpleDice d24-H:\n  lastRoll = \(simpleDice.dice.lastRoll)\n  result = \"\(simpleDice.result)\"")

            let highest = simpleDice.dice.lastRoll.max()!
            let index = simpleDice.dice.lastRoll.index(of: highest)
            XCTAssertEqual(highest, simpleDice.droppedRoll, "dropped roll")
            XCTAssertEqual(index, simpleDice.droppedIndex, "dropped index")
        }
    }
    
    func testCompoundDice() {
        // Test 2d8+4
        do {
            let compoundDice = CompoundDice(.d8, times: 2, modifier: 4)
            XCTAssertEqual(compoundDice.lastRoll.count, 0, "lastRoll count should be 0")
            XCTAssertEqual(compoundDice.result, "", "result should be empty")

            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = compoundDice.roll()
                XCTAssertTrue((6...20).contains(roll), "rolling a d8 2 times + 4, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of 2d8+4 = \(mean) [expect 13.0]")
            XCTAssertTrue((12.0...14.0).contains(mean), "expected mean around 13.0, got \(mean)")

            XCTAssertEqual(minValue, 6, "min value")
            XCTAssertEqual(maxValue, 20, "max value")
            
            XCTAssertEqual(compoundDice.sides, 8, "CompoundDice sides")
            XCTAssertEqual(compoundDice.lastRoll.count, 3, "last roll count")

            XCTAssertEqual("\(compoundDice.description)", "2d8+4", "CompoundDice description")
        }
    
        // Test 2d8+d4
        do {
            let compoundDice = CompoundDice(lhs: SimpleDice(.d8, times: 2), rhs: SimpleDice(.d4), mathOperator: "+")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = compoundDice.roll()
                XCTAssertTrue((3...20).contains(roll), "rolling a d8 2 times + d4, got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of 2d8+d4 = \(mean) [expect 11.5]")
            XCTAssertTrue((11.0...12.0).contains(mean), "expected mean around 11.5, got \(mean)")
            
            XCTAssertLessThanOrEqual(minValue, 4, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 19, "max value")
            
            XCTAssertEqual(compoundDice.sides, 8, "CompoundDice sides")
            XCTAssertEqual("\(compoundDice.description)", "2d8+d4", "CompoundDice description")
            
            // Code coverage and manual inspection of test output:
            print("CompoundDice 2d8+d4:\n  result = \"\(compoundDice.result)\"")
        }
    }
    
    func testDiceFormatString() {
        do {
            let formatString = "d12"
            let formatDice = dice(from: formatString)
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = formatDice?.roll() ?? 0
                XCTAssertTrue((1...12).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of \(formatString) = \(mean) [expect 6.5]")
            XCTAssertTrue((6.0...7.0).contains(mean), "expected mean around 6.5, got \(mean)")
            
            XCTAssertEqual(minValue, 1, "min value")
            XCTAssertEqual(maxValue, 12, "max value")
        }
        
        do {
            let formatString = "2d10"
            let formatDice = dice(from: formatString)
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = formatDice?.roll() ?? 0
                XCTAssertTrue((2...20).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of \(formatString) = \(mean) [expect 11.0]")
            XCTAssertTrue((10.0...12.0).contains(mean), "expected mean around 11.0, got \(mean)")
            
            // TODO: Because 2d10 produces a bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 3, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 19, "max value")
        }
        
        do {
            let formatString = "1d20+4"
            let formatDice = dice(from: formatString)
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = formatDice?.roll() ?? 0
                XCTAssertTrue((5...24).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of \(formatString) = \(mean) [expect 14.5]")
            XCTAssertTrue((13.0...16.0).contains(mean), "expected mean around 14.5, got \(mean)")
            
            XCTAssertEqual(minValue, 5, "min value")
            XCTAssertEqual(maxValue, 24, "max value")
        }
        
        do {
            let formatString = "d%"
            let formatDice = dice(from: formatString)
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = formatDice?.roll() ?? 0
                XCTAssertTrue((1...100).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of \(formatString) = \(mean) [expect 51.0]")
            XCTAssertTrue((45.0...56.0).contains(mean), "expected mean around 51.0, got \(mean)")
            
            /// With such a big range, we may not hit the absolute min/max for the specified sample size.
            XCTAssertLessThanOrEqual(minValue, 2, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 99, "max value")
        }
        
        do {
            let formatString = "2d4x10"
            let formatDice = dice(from: formatString)
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = formatDice?.roll() ?? 0
                XCTAssertTrue((20...80).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of \(formatString) = \(mean) [expect 50.0]")
            XCTAssertTrue((46.0...56.0).contains(mean), "expected mean around 51.0, got \(mean)")
            
            XCTAssertEqual(minValue, 20, "min value")
            XCTAssertEqual(maxValue, 80, "max value")
        }

        do {
            let formatString = "4d6-L"
            let formatDice = dice(from: formatString)
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = formatDice?.roll() ?? 0
                XCTAssertTrue((3...18).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }

            let mean = Double(sum)/Double(sampleSize)
            print("  mean of \(formatString) = \(mean) [expect 12.25]")
            XCTAssertTrue((11.0...13.5).contains(mean), "expected mean around 12.25, got \(mean)")
            
            // TODO: Because 4x-L produces a sharp bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 5, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 16, "max value")
            
            XCTAssertEqual(formatDice?.sides, 6, "SimpleDice sides")
            if formatDice != nil {
                XCTAssertEqual("\(formatDice!.description)", "4d6-L", "SimpleDice description")
            }
            
            // Code coverage and manual inspection of test output:
            print("SimpleDice \(formatString):\n  result = \"\(formatDice?.result)\"")
        }
        
        do {
            let formatString = "1+3"
            let formatDice = dice(from: formatString)
            XCTAssertEqual(formatDice?.description, "1+3", "format string")
            
            XCTAssertEqual(formatDice?.result, "1 + 3", "format string")
        }
    }
    

    // TODO: complex dice formats, such as those shown below, are not yet supported.
    // dice() does not yet compose math expressions that can be evaluated from left to right.
    func testComplexDiceFormatString() {
        do {
            let formatString = "2d4+3d12-4"
            let formatDice = dice(from: formatString)
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0..<sampleSize {
                let roll = formatDice?.roll() ?? 0
                XCTAssertTrue((1...40).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of \(formatString) = \(mean) [expect 20.5]")
            XCTAssertTrue((19.0...22.0).contains(mean), "expected mean around 20.5, got \(mean)")
            
            // TODO: Because this produces a sharp bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 7, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 34, "max value")
            
            XCTAssertEqual(formatDice?.sides, 4, "SimpleDice sides")
            if formatDice != nil {
                XCTAssertEqual("\(formatDice!.description)", "2d4+3d12-4", "SimpleDice description")
            }
            
            // Code coverage and manual inspection of test output:
            let result = formatDice?.result ?? ""
            print("SimpleDice \(formatString):\n  result = \"\(result)\"")
        }
 
        // TODO: the parser can't yet handle regular expressions.
        do {
            let formatString = "2d4+d12-2+5"
            let formatDice = dice(from: formatString)
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            /* TODO: this format produces a wrong answer
            var sum = 0
            var minValue = 0
            var maxValue = 0
            var lastRoll = 0
            
            for _ in 0..<sampleSize {
                let roll = formatDice?.roll() ?? 0
                XCTAssertTrue((6...23).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
                
                lastRoll = roll
            }
            
            let mean = Double(sum)/Double(sampleSize)
            print("  mean of \(formatString) = \(mean) [expect 20.5]")
            XCTAssertTrue((13.0...16.0).contains(mean), "expected mean around 20.5, got \(mean)")
            
            // TODO: Because this produces a bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 7, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 22, "max value")
            */
            XCTAssertEqual(formatDice?.sides, 4, "SimpleDice sides")
            if formatDice != nil {
                XCTAssertEqual("\(formatDice!.description)", "2d4+d12-2+5", "SimpleDice description")
            }
            
            /*
            let result = formatDice?.result ?? ""
            print("SimpleDice \(formatString):\n  result \"\(result)\" = \(lastRoll)")
             */
        }

    }
    
    func testDiceFormatStringNegative() {
        // Negative tests
        do {
            let badFormatString = "d7"
            let roll = dice(from: badFormatString)
            XCTAssertNil(roll, "'\(badFormatString)' unsupported dice number")
        }

        do {
            let badFormatString = "dhello"
            let roll = dice(from: badFormatString)
            XCTAssertNil(roll, "'\(badFormatString)' unsupported dice number")
        }
        
        do {
            let badFormatString = "2+elephants"
            let roll = dice(from: badFormatString)
            XCTAssertNil(roll, "'\(badFormatString)' unsupported dice number")
        }
    }
}
