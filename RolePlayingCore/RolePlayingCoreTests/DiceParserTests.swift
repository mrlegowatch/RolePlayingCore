//
//  DiceParserTests.swift
//  RolePlayingCoreTests
//
//  Created by Brian Arnold on 7/2/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore

@Suite("Dice Parser Tests")
struct DiceParserTests {
    
    @Test("Dice format string")
    func diceFormatString() {
        let formatString = "d12"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((1...12).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        let mean = Double(sum)/Double(sampleSize)
        #expect((6.0...7.0).contains(mean), "expected mean around 6.5, got \(mean)")
        
        #expect(minValue == 1, "min value")
        #expect(maxValue == 12, "max value")
    }
    
    @Test("Dice times string")
    func diceTimesString() {
        let formatString = "2d10"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((2...20).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        let mean = Double(sum)/Double(sampleSize)
        #expect((10.0...12.0).contains(mean), "expected mean around 11.0, got \(mean)")
        
        // TODO: Because 2d10 produces a bell curve, the actual min/max may be harder to get in a sample
        #expect(minValue <= 3, "min value")
        #expect(maxValue >= 19, "max value")
    }
    
    @Test("Dice times capitalized")
    func diceTimesCapitalized() {
        let formatString = "2D10"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((2...20).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        let mean = Double(sum)/Double(sampleSize)
        #expect((10.0...12.0).contains(mean), "expected mean around 11.0, got \(mean)")
        
        // TODO: Because 2d10 produces a bell curve, the actual min/max may be harder to get in a sample
        #expect(minValue <= 3, "min value")
        #expect(maxValue >= 19, "max value")
    }
    
    @Test("Dice add modifier")
    func diceAddModifier() {
        let formatString = "1d20+4"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((5...24).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        let mean = Double(sum)/Double(sampleSize)
        #expect((13.0...16.0).contains(mean), "expected mean around 14.5, got \(mean)")
        
        #expect(minValue == 5, "min value")
        #expect(maxValue == 24, "max value")
    }
        
    @Test("Dice percent")
    func dicePercent() {
        let formatString = "d%"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((1...100).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        let mean = Double(sum)/Double(sampleSize)
        #expect((45.0...56.0).contains(mean), "expected mean around 50.5, got \(mean)")
        
        /// With such a big range, we may not hit the absolute min/max for the specified sample size.
        #expect(minValue <= 2, "min value")
        #expect(maxValue >= 99, "max value")
        
        // Check that the description has the %
        if formatDice != nil {
            #expect(formatDice!.description == "d%", "% description")
        }
    }
        
    @Test("Multiply with X")
    func multiplyWithX() {
        let formatString = "2d4x10"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((20...80).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        let mean = Double(sum)/Double(sampleSize)
        #expect((46.0...56.0).contains(mean), "expected mean around 50.0, got \(mean)")
        
        #expect(minValue == 20, "min value")
        #expect(maxValue == 80, "max value")
    }
        
    @Test("Multiply with asterisk")
    func multiplyWithAsterisk() {
        let formatString = "2d4*10"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((20...80).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        let mean = Double(sum)/Double(sampleSize)
        #expect((46.0...56.0).contains(mean), "expected mean around 50.0, got \(mean)")
        
        #expect(minValue == 20, "min value")
        #expect(maxValue == 80, "max value")
    }
        
    @Test("Divide")
    func divide() {
        let formatString = "d100/10"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((0...10).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        let mean = Double(sum)/Double(sampleSize)
        #expect((4.0...5.0).contains(mean), "expected mean around 4.5, got \(mean)")
        
        #expect(minValue >= 0, "min value")
        #expect(maxValue <= 10, "max value")
    }
        
    @Test("Dropping lowest")
    func droppingLowest() {
        let formatString = "4d6-L"
        
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((3...18).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        
        let mean = Double(sum)/Double(sampleSize)
        #expect((11.0...13.5).contains(mean), "expected mean around 12.25, got \(mean)")
        
        // TODO: Because 4x-L produces a sharp bell curve, the actual min/max may be harder to get in a sample
        #expect(minValue <= 5, "min value")
        #expect(maxValue >= 16, "max value")
        
        #expect(formatDice?.sides == 6, "Dice sides")
        if let formatDice = formatDice {
            #expect(formatDice.description == "4d6-L", "SimpleDice description")
        }
    }
    
    @Test("Complex dice format string")
    func complexDiceFormatString() {
        let formatString = "2d4+3d12-4"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((1...40).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        
        let mean = Double(sum)/Double(sampleSize)
        #expect((19.0...22.0).contains(mean), "expected mean around 20.5, got \(mean)")
        
        // TODO: Because this produces a sharp bell curve, the actual min/max may be harder to get in a sample
        #expect(minValue <= 7, "min value")
        #expect(maxValue >= 34, "max value")
        
        #expect(formatDice?.sides == 4, "Dice sides")
        if formatDice != nil {
            #expect(formatDice!.description == "2d4+3d12-4", "SimpleDice description")
        }
    }
    
    @Test("Complex dice operator precedence")
    func complexDiceOperatorPrecedence() {
        let formatString = "2d4+d12-2+5"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((6...23).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        
        let mean = Double(sum)/Double(sampleSize)
        #expect((13.0...16.0).contains(mean), "expected mean around 14.5, got \(mean)")
        
        // TODO: Because this produces a bell curve, the actual min/max may be harder to get in a sample
        #expect(minValue <= 7, "min value")
        #expect(maxValue >= 22, "max value")
        
        #expect(formatDice?.sides == 4, "Dice sides")
        if formatDice != nil {
            #expect(formatDice!.description == "2d4+d12-2+5", "SimpleDice description")
        }
    }
        
    @Test("Complex dice extra roll dropping with whitespace")
    func complexDiceExtraRollDroppingWithWhitespace() {
        let formatString = "3d4- L + d12 -\n2 + 5"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should be non-nil")
        
        var sum = 0
        var minValue = 0
        var maxValue = 0
        for _ in 0 ..< sampleSize {
            let roll = formatDice?.roll().result ?? 0
            #expect((6...23).contains(roll), "rolling \(formatString), got \(roll)")
            sum += roll
            minValue = minValue == 0 ? roll : min(minValue, roll)
            maxValue = maxValue == 0 ? roll : max(maxValue, roll)
        }
        
        let mean = Double(sum)/Double(sampleSize)
        #expect((13.0...16.0).contains(mean), "expected mean around 14.5, got \(mean)")
        
        // TODO: Because this produces a bell curve, the actual min/max may be harder to get in a sample
        #expect(minValue <= 7, "min value")
        #expect(maxValue >= 22, "max value")
        
        #expect(formatDice?.sides == 4, "Dice sides")
        if formatDice != nil {
            #expect(formatDice!.description == "3d4-L+d12-2+5", "SimpleDice description")
        }
    }
        
    @Test("Constant modifiers")
    func constantModifiers() {
        let formatString = "1+3"
        let formatDice = formatString.parseDice
        #expect(formatDice != nil, "Dice from \(formatString) should not be nil")
        
        if let formatDice = formatDice {
            #expect(formatDice.description == "1+3", "format string")
            let lastRoll = formatDice.roll()
            #expect(lastRoll.description == "1 + 3", "format string")
        }
    }
    
    @Test("Invalid dice format strings", arguments: [
        ("d7", "unsupported dice number"),
        ("dhello", "unsupported dice number"),
        ("2+elephants", "unsupported character tokens"),
        ("3d", "missing dice sides"),
        ("2-", "missing expression"),
        ("2d4H", "dropping missing minus"),
        ("2-H", "dropping missing SimpleDice"),
        ("3 4", "consecutive numbers"),
        ("3++4", "consecutive math operators"),
        ("d4d4", "consecutive dice expressions"),
        ("dd4", "consecutive dice 'd' characters")
    ])
    func invalidDiceFormatStrings(badFormatString: String, reason: String) {
        let roll = badFormatString.parseDice
        #expect(roll == nil, "'\(badFormatString)' \(reason)")
    }
}
