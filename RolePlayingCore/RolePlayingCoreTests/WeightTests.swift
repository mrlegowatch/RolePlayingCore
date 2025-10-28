//
//  UnitWeightTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class UnitWeightTests: XCTestCase {
    
    func testWeights() {
        do {
            let howHeavy = "70".parseWeight
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 70, "weight should be 3.0")
        }

        do {
            let howHeavy = "3.0".parseWeight
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 3.0, "weight should be 3.0")
        }

        do {
            let howHeavy = "45lb".parseWeight
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 45, "weight should be 45")
        }

        do {
            let howHeavy = "174 kg".parseWeight
            XCTAssertNotNil(howHeavy, "weight should be non-nil")
            XCTAssertEqual(howHeavy?.value, 174, "weight should be 174")
        }
    }
    
    func testInvalidWeights() {
        do {
            let howHeavy = "99 hello".parseWeight
            XCTAssertNil(howHeavy, "weight should be nil")
        }
    }
    
    func testEncodingWeight() {
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
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(weightContainer)
            let deserialized = try JSONSerialization.jsonObject(with: encoded, options: .allowFragments)
            print("deserialized = \n\(deserialized)")
            let container = deserialized as? [String: Any]
            let weight = container?["weight"] as? String
            XCTAssertEqual(weight, "2.9 kg", "Encoded weight did not become a string")
        }
        catch let error {
            XCTFail("Encoding weight threw an error: \(error)")
        }
    }
    
    func testDecodingHeight() {
        struct WeightContainer: Decodable {
            let weight: Weight
        }
        
        do {
            let traits = """
            {
                "weight": "147 lb"
            }
            """.data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(WeightContainer.self, from: traits)
                
                XCTAssertEqual(decoded.weight.value, 147, "Decoded weight should be 147 lb")
            } catch let error {
                XCTFail("Decoding weight threw an error: \(error)")
            }
        }
        
        do {
            let traits = """
            {
                "weight": 17
            }
            """.data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(WeightContainer.self, from: traits)
                
                XCTAssertEqual(decoded.weight.value, 17, "Decoded weight should be 17 lb")
            } catch let error {
                XCTFail("Decoding weight threw an error: \(error)")
            }
        }
        
        do {
            let traits = """
            {
                "weight": "abcdefg"
            }
            """.data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                _ = try decoder.decode(WeightContainer.self, from: traits)
                XCTFail("Decoding weight should have thrown an error")
                
            } catch let error {
                print("Decoding invalid weight successfully threw an error: \(error)")
            }
        }
    }
    
    func testDecodingWeightIfPresent() {
        struct WeightContainer: Decodable {
            let weight: Weight? // The ? will trigger decodeIfPresent in the decoder
        }
        
        do {
            let traits = """
            {
                "weight": "220 lb"
            }
            """.data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(WeightContainer.self, from: traits)
                
                XCTAssertEqual(decoded.weight?.value, 220.0, "Decoded weight should be 220 lb")
            } catch let error {
                XCTFail("Decoding weight threw an error: \(error)")
            }
        }
        
        do {
            let traits = """
            {
                "weight": 6.5
            }
            """.data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(WeightContainer.self, from: traits)
                
                XCTAssertEqual(decoded.weight?.value, 6.5, "Decoded weight should be 4 ft 3 in")
            } catch let error {
                XCTFail("Decoding weight threw an error: \(error)")
            }
        }
    }
}
