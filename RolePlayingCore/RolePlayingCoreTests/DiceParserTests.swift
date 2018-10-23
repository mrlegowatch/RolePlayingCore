//
//  DiceParserTests.swift
//  RolePlayingCoreTests
//
//  Created by Brian Arnold on 7/2/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class DiceParserTests: XCTestCase {
    
    func testDiceFormatString() {
        // Test dice
        do {
            let formatString = "d12"
            print("Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((1...12).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((6.0...7.0).contains(mean), "expected mean around 6.5, got \(mean)")
            
            XCTAssertEqual(minValue, 1, "min value")
            XCTAssertEqual(maxValue, 12, "max value")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 6.5]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\"")
        }
        
        // Test times
        do {
            let formatString = "2d10"
            print("Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((2...20).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((10.0...12.0).contains(mean), "expected mean around 11.0, got \(mean)")
            
            // TODO: Because 2d10 produces a bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 3, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 19, "max value")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 11.0]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\"")
        }
        
        // Test times with capital "D"
        do {
            let formatString = "2D10"
            print("Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((2...20).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((10.0...12.0).contains(mean), "expected mean around 11.0, got \(mean)")
            
            // TODO: Because 2d10 produces a bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 3, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 19, "max value")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 11.0]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\"")
        }
        
        // Test add modifier
        do {
            let formatString = "1d20+4"
            print("Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((5...24).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((13.0...16.0).contains(mean), "expected mean around 14.5, got \(mean)")
            
            XCTAssertEqual(minValue, 5, "min value")
            XCTAssertEqual(maxValue, 24, "max value")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 14.5]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\"")
        }
        
        // Test percent
        do {
            let formatString = "d%"
            print("Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((1...100).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((45.0...56.0).contains(mean), "expected mean around 50.5, got \(mean)")
            
            /// With such a big range, we may not hit the absolute min/max for the specified sample size.
            XCTAssertLessThanOrEqual(minValue, 2, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 99, "max value")
            
            // Check that the description has the %
            if formatDice != nil {
                XCTAssertEqual("\(formatDice!.description)", "d%", "% description")
            }
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 50.5]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\"")
        }
        
        // Test multiply
        do {
            let formatString = "2d4x10"
            print("Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((20...80).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((46.0...56.0).contains(mean), "expected mean around 50.0, got \(mean)")
            
            XCTAssertEqual(minValue, 20, "min value")
            XCTAssertEqual(maxValue, 80, "max value")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 50.0]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\"")
        }
        
        // Test multiply with '*'
        do {
            let formatString = "2d4*10"
            print("Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((20...80).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((46.0...56.0).contains(mean), "expected mean around 50.0, got \(mean)")
            
            XCTAssertEqual(minValue, 20, "min value")
            XCTAssertEqual(maxValue, 80, "max value")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 50.0]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\"")
        }
        
        // Test divide
        do {
            let formatString = "d100/10"
            print("Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((0...10).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((4.0...5.0).contains(mean), "expected mean around 4.5, got \(mean)")
            
            XCTAssertGreaterThanOrEqual(minValue, 0, "min value")
            XCTAssertLessThanOrEqual(maxValue, 10, "max value")
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 4.5]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\"")
        }
        
        // Test dropping "L"
        do {
            let formatString = "4d6-L"
            print("Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((3...18).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((11.0...13.5).contains(mean), "expected mean around 12.25, got \(mean)")
            
            // TODO: Because 4x-L produces a sharp bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 5, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 16, "max value")
            
            XCTAssertEqual(formatDice?.sides, 6, "Dice sides")
            if let formatDice = formatDice {
                XCTAssertEqual("\(formatDice.description)", "4d6-L", "SimpleDice description")
            }
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 12.25]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\"")
        }
    }
    
    func testComplexDiceFormatString() {
        do {
            let formatString = "2d4+3d12-4"
            print("Complex Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            var sum = 0
            var minValue = 0
            var maxValue = 0
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((1...40).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
            }
            
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((19.0...22.0).contains(mean), "expected mean around 20.5, got \(mean)")
            
            // TODO: Because this produces a sharp bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 7, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 34, "max value")
            
            XCTAssertEqual(formatDice?.sides, 4, "Dice sides")
            if formatDice != nil {
                XCTAssertEqual("\(formatDice!.description)", "2d4+3d12-4", "SimpleDice description")
            }
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 20.5]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\"")
        }
        
        // Test with subtraction second to last, to ensure operator precedence
        do {
            let formatString = "2d4+d12-2+5"
            print("Complex Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            
            var sum = 0
            var minValue = 0
            var maxValue = 0
            var lastRoll = 0
            
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((6...23).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
                
                lastRoll = roll
            }
            
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((13.0...16.0).contains(mean), "expected mean around 14.5, got \(mean)")
            
            // TODO: Because this produces a bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 7, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 22, "max value")
            
            XCTAssertEqual(formatDice?.sides, 4, "Dice sides")
            if formatDice != nil {
                XCTAssertEqual("\(formatDice!.description)", "2d4+d12-2+5", "SimpleDice description")
            }
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 14.5]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\" = \(lastRoll)")
        }
        
        // Repeat with extra roll, dropping, spaces and returns
        do {
            let formatString = "3d4- L + d12 -\n2 + 5"
            print("Complex Format Dice \(formatString):")
            
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should be non-nil")
            
            var sum = 0
            var minValue = 0
            var maxValue = 0
            var lastRoll = 0
            
            for _ in 0 ..< sampleSize {
                let roll = formatDice?.roll().result ?? 0
                XCTAssertTrue((6...23).contains(roll), "rolling \(formatString), got \(roll)")
                sum += roll
                minValue = minValue == 0 ? roll : min(minValue, roll)
                maxValue = maxValue == 0 ? roll : max(maxValue, roll)
                
                lastRoll = roll
            }
            
            let mean = Double(sum)/Double(sampleSize)
            XCTAssertTrue((13.0...16.0).contains(mean), "expected mean around 14.5, got \(mean)")
            
            // TODO: Because this produces a bell curve, the actual min/max may be harder to get in a sample
            XCTAssertLessThanOrEqual(minValue, 7, "min value")
            XCTAssertGreaterThanOrEqual(maxValue, 22, "max value")
            
            XCTAssertEqual(formatDice?.sides, 4, "Dice sides")
            if formatDice != nil {
                XCTAssertEqual("\(formatDice!.description)", "3d4-L+d12-2+5", "SimpleDice description")
            }
            
            // Code coverage and manual inspection of test output:
            print("  mean = \(mean) [expect 14.5]")
            let result = formatDice?.roll().description ?? ""
            print("  lastRoll \"\(result)\" = \(lastRoll)")
        }
        
        // Test two constant modifiers
        do {
            let formatString = "1+3"
            let formatDice = formatString.parseDice
            XCTAssertNotNil(formatDice, "Dice from \(formatString) should not be nil")
            
            if let formatDice = formatDice {
                XCTAssertEqual(formatDice.description, "1+3", "format string")
                let lastRoll = formatDice.roll()
                XCTAssertEqual(lastRoll.description, "1 + 3", "format string")
            }
        }
    }
    
    func testDiceFormatStringNegative() {
        // Negative tests
        do {
            let badFormatString = "d7"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' unsupported dice number")
        }
        
        do {
            let badFormatString = "dhello"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' unsupported dice number")
        }
        
        do {
            let badFormatString = "2+elephants"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' unsupported character tokens")
        }
        
        // catch missing dice sides
        do {
            let badFormatString = "3d"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' missing dice sides")
            
        }
        
        // catch isDropping false code path at end of string, and missing expression
        do {
            let badFormatString = "2-"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' missing expression")
        }
        
        // catch dropping missing minus
        do {
            let badFormatString = "2d4H"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' dropping missing minus")
        }
        
        // catch dropping missing SimpleDice
        do {
            let badFormatString = "2-H"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' dropping missing SimpleDice")
        }
        
        // catch consecutive numbers
        do {
            let badFormatString = "3 4"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' consecutive numbers")
        }
        
        // catch consecutive math operators
        do {
            let badFormatString = "3++4"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' consecutive math operators")
        }
        
        // Catch consecutive dice expressions (both valid dice)
        do {
            let badFormatString = "d4d4"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' consecutive dice expressions")
        }
        
        // Catch consecutive dice 'd' characters
        do {
            let badFormatString = "dd4"
            let roll = badFormatString.parseDice
            XCTAssertNil(roll, "'\(badFormatString)' consecutive dice expressions")
        }
        
    }
    
    func testDecodingDice() {
        struct DiceContainer: Decodable {
            let dice: Dice
            
            enum CodingKeys: String, CodingKey {
                case dice
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                dice = try container.decode(Dice.self, forKey: .dice)
            }
        }
        
        // Decode a typical Dice expression
        do {
            let traits = """
            {
                "dice": "2d6+2"
            }
            """.data(using: .utf8)!
            let decoder = JSONDecoder()
            do {
                let decoded = try decoder.decode(DiceContainer.self, from: traits)
                XCTAssertNotNil(decoded.dice as? CompoundDice, "decode as compound dice")
                XCTAssertEqual(decoded.dice.sides, 6, "decode dice sides")
            }
            catch let error {
                XCTFail("decoded dice failed, error: \(error)")
            }
        }
        
        // Decode a dice modifier
        do {
            let traits = """
            {
                "dice": 5
            }
            """.data(using: .utf8)!
            let decoder = JSONDecoder()
            do {
                let decoded = try decoder.decode(DiceContainer.self, from: traits)
                XCTAssertNotNil(decoded.dice as? DiceModifier, "decode as compound dice")
                XCTAssertEqual(decoded.dice.sides, 5, "decode dice sides")
            }
            catch let error {
                XCTFail("decoded dice failed, error: \(error)")
            }
        }
        
        // Attempt to decode invalid dice
        do {
            let traits = """
            {
                "dice": "Hello Dice"
            }
            """.data(using: .utf8)!
            let decoder = JSONDecoder()
            do {
                _ = try decoder.decode(DiceContainer.self, from: traits)
                XCTFail("decode invalid dice string should have failed")
            }
            catch let error {
                print("successfully failed to decode invalid dice string, error: \(error)")
            }
        }
    }
    
    func testDecodingDiceIfPresent() {
        struct DiceContainer: Decodable {
            let dice: Dice?
            
            enum CodingKeys: String, CodingKey {
                case dice
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                dice = try container.decodeIfPresent(Dice.self, forKey: .dice)
            }
        }
        
        // Decode a typical Dice expression
        do {
            let traits = """
            {
                "dice": "2d6+2"
            }
            """.data(using: .utf8)!
            let decoder = JSONDecoder()
            do {
                let decoded = try decoder.decode(DiceContainer.self, from: traits)
                XCTAssertNotNil(decoded.dice as? CompoundDice, "decode as compound dice")
                XCTAssertEqual(decoded.dice?.sides, 6, "decode dice sides")
            }
            catch let error {
                XCTFail("decoded dice failed, error: \(error)")
            }
        }
        
        // Decode a dice modifier
        do {
            let traits = """
            {
                "dice": 5
            }
            """.data(using: .utf8)!
            let decoder = JSONDecoder()
            do {
                let decoded = try decoder.decode(DiceContainer.self, from: traits)
                XCTAssertNotNil(decoded.dice as? DiceModifier, "decode as compound dice")
                XCTAssertEqual(decoded.dice?.sides, 5, "decode dice sides")
            }
            catch let error {
                XCTFail("decoded dice failed, error: \(error)")
            }
        }
        
        // Attempt to decode invalid dice
        do {
            let traits = """
            {
                "dice": "Hello Dice"
            }
            """.data(using: .utf8)!
            let decoder = JSONDecoder()
            do {
                let decoded = try decoder.decode(DiceContainer.self, from: traits)
                XCTAssertNil(decoded.dice, "Dice should have not been parsed")
            }
            catch let error {
                XCTFail("decoded dice failed, error: \(error)")
            }
        }
    }
    
    func testEncodingDice() {
        do {
            struct DiceContainer: Encodable {
                let dice: Dice
                
                enum CodingKeys: String, CodingKey {
                    case dice
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    try container.encode("\(dice)", forKey: .dice)
                }
            }
            
            let diceContainer = DiceContainer(dice: CompoundDice(.d8, times: 3, modifier: 3, mathOperator: "-"))
            let encoder = JSONEncoder()
            do {
                let encoded = try encoder.encode(diceContainer)
                let deserialized = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: String]
                XCTAssertEqual(deserialized?["dice"], "3d8-3", "encoded dice failed to deserialize as string")
            }
            catch let error {
                XCTFail("encoded dice failed, error: \(error)")
            }
        }
    }
}
