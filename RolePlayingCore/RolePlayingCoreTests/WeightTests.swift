//
//  UnitWeightTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore

@Suite("Weight Parsing and Serialization Tests")
struct UnitWeightTests {
    
    @Test("Parse various weight formats")
    func weights() async throws {
        do {
            let howHeavy = "70".parseWeight
            #expect(howHeavy != nil, "weight should be non-nil")
            #expect(howHeavy?.value == 70, "weight should be 70")
        }

        do {
            let howHeavy = "3.0".parseWeight
            #expect(howHeavy != nil, "weight should be non-nil")
            #expect(howHeavy?.value == 3.0, "weight should be 3.0")
        }

        do {
            let howHeavy = "45lb".parseWeight
            #expect(howHeavy != nil, "weight should be non-nil")
            #expect(howHeavy?.value == 45, "weight should be 45")
        }

        do {
            let howHeavy = "174 kg".parseWeight
            #expect(howHeavy != nil, "weight should be non-nil")
            #expect(howHeavy?.value == 174, "weight should be 174")
        }
    }
    
    @Test("Parse invalid weight strings")
    func invalidWeights() async throws {
        let howHeavy = "99 hello".parseWeight
        #expect(howHeavy == nil, "weight should be nil")
    }
    
    @Test("Encode weight to JSON")
    func encodingWeight() async throws {
        struct WeightContainer: Encodable {
            let weight: Weight
            
            enum CodingKeys: String, CodingKey {
                case weight
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode("\(weight)", forKey: .weight)
            }
        }
        let weightContainer = WeightContainer(weight: Weight(value: 2.9, unit: .kilograms))
        
        // Do a round-trip through serialization, then deserialization to confirm that it became a string
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(weightContainer)
        let deserialized = try JSONSerialization.jsonObject(with: encoded, options: .allowFragments)
        print("deserialized = \n\(deserialized)")
        let container = deserialized as? [String: Any]
        let weight = container?["weight"] as? String
        #expect(weight == "2.9 kg", "Encoded weight did not become a string")
    }
    
    @Test("Decode weight from JSON")
    func decodingWeight() async throws {
        struct WeightContainer: Decodable {
            let weight: Weight
        }
        
        do {
            let traits = """
            {
                "weight": "147 lb"
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(WeightContainer.self, from: traits)
            
            #expect(decoded.weight.value == 147, "Decoded weight should be 147 lb")
        }
        
        do {
            let traits = """
            {
                "weight": 17
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(WeightContainer.self, from: traits)
            
            #expect(decoded.weight.value == 17, "Decoded weight should be 17 lb")
        }
        
        do {
            let traits = """
            {
                "weight": "abcdefg"
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            #expect(throws: (any Error).self) {
                _ = try decoder.decode(WeightContainer.self, from: traits)
            }
        }
    }
    
    @Test("Decode optional weight from JSON")
    func decodingWeightIfPresent() async throws {
        struct WeightContainer: Decodable {
            let weight: Weight? // The ? will trigger decodeIfPresent in the decoder
        }
        
        do {
            let traits = """
            {
                "weight": "220 lb"
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(WeightContainer.self, from: traits)
            
            #expect(decoded.weight?.value == 220.0, "Decoded weight should be 220 lb")
        }
        
        do {
            let traits = """
            {
                "weight": 6.5
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(WeightContainer.self, from: traits)
            
            #expect(decoded.weight?.value == 6.5, "Decoded weight should be 6.5")
        }
    }
}
