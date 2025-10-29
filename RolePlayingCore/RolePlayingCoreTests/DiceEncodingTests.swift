//
//  DiceEncodingTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/29/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class DiceEncodingTests: XCTestCase {
    
    func testEncodingDice() {
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
            catch {
                // Successfully errored
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
}
