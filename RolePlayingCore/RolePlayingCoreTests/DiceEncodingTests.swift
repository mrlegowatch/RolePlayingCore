//
//  DiceEncodingTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/29/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore

@Suite("Dice Encoding Tests")
struct DiceEncodingTests {
    
    @Test("Encoding dice")
    func encodingDice() throws {
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
        let encoded = try encoder.encode(diceContainer)
        let deserialized = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: String]
        #expect(deserialized?["dice"] == "3d8-3", "encoded dice failed to deserialize as string")
    }
    
    @Test("Decoding dice - typical expression")
    func decodingDiceTypicalExpression() throws {
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
        
        let traits = """
        {
            "dice": "2d6+2"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DiceContainer.self, from: traits)
        #expect(decoded.dice is CompoundDice, "decode as compound dice")
        #expect(decoded.dice.sides == 6, "decode dice sides")
    }
    
    @Test("Decoding dice - dice modifier")
    func decodingDiceDiceModifier() throws {
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
        
        let traits = """
        {
            "dice": 5
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DiceContainer.self, from: traits)
        #expect(decoded.dice is DiceModifier, "decode as dice modifier")
        #expect(decoded.dice.sides == 5, "decode dice sides")
    }
    
    @Test("Decoding dice - invalid dice string")
    func decodingDiceInvalidString() throws {
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
        
        let traits = """
        {
            "dice": "Hello Dice"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        #expect(throws: Error.self) {
            _ = try decoder.decode(DiceContainer.self, from: traits)
        }
    }
    
    @Test("Decoding dice if present - typical expression")
    func decodingDiceIfPresentTypicalExpression() throws {
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
        
        let traits = """
        {
            "dice": "2d6+2"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DiceContainer.self, from: traits)
        #expect(decoded.dice is CompoundDice, "decode as compound dice")
        #expect(decoded.dice?.sides == 6, "decode dice sides")
    }
    
    @Test("Decoding dice if present - dice modifier")
    func decodingDiceIfPresentDiceModifier() throws {
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
        
        let traits = """
        {
            "dice": 5
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DiceContainer.self, from: traits)
        #expect(decoded.dice is DiceModifier, "decode as dice modifier")
        #expect(decoded.dice?.sides == 5, "decode dice sides")
    }
    
    @Test("Decoding dice if present - invalid dice string")
    func decodingDiceIfPresentInvalidString() throws {
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
        
        let traits = """
        {
            "dice": "Hello Dice"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DiceContainer.self, from: traits)
        #expect(decoded.dice == nil, "Dice should have not been parsed")
    }
}
