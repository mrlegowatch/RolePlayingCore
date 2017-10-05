//
//  UnitHeightTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class UnitHeightTests: XCTestCase {
    
    let decoder = JSONDecoder()

    func testHeights() {

        do {
            let howTall = "5".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 5.0, "height should be 3.0")
        }

        do {
            let howTall = "3.0".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 3.0, "height should be 3.0")
        }
  
        do {
            let howTall = "4 ft 3 in".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 4.0 + 3.0/12.0, "height should be 4.25")
        }

        do {
            let howTall = "73in".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            let howTallValue = howTall?.value ?? 0.0
            XCTAssertEqual(howTallValue, 6.0 + 1.0/12.0, accuracy: 0.0001, "height should be 6.08")
        }

        do {
            let howTall = "5'4\"".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 5.0 + 4.0/12.0, "height should be 5.33")
        }
        
        do {
            let howTall = "130 cm".parseHeight?.converted(to: .meters)
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 1.3, "height should be 1.3")
        }
        
        do {
            let howTall = "2.1m".parseHeight
            XCTAssertNotNil(howTall, "height should be non-nil")
            XCTAssertEqual(howTall?.value, 2.1, "height should be 2.1")
        }

        
    }
    
    func testInvalidHeights() {
        do {
            let howTall = "3 hello".parseHeight
            XCTAssertNil(howTall, "height should be nil")
        }

    }
    
    func testEncodingHeight() {
        struct HeightContainer: Encodable {
            let height: Height
            
            enum CodingKeys: String, CodingKey {
                case height
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode("\(height)", forKey: .height)
            }
        }
        let heightContainer = HeightContainer(height: Height(value: 3.2, unit: .meters))
        
        // Do a round-trip through serialization, then deserialization to confirm that it became a string
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(heightContainer)
            let deserialized = try JSONSerialization.jsonObject(with: encoded, options: .allowFragments)
            print("deserialized = \n\(deserialized)")
            let container = deserialized as? [String: Any]
            let height = container?["height"] as? String
            XCTAssertEqual(height, "3.2 m", "Encoded height did not become a string")
        }
        catch let error {
            XCTFail("Encoding heights threw an error: \(error)")
        }
    }
    
    func testDecodingHeight() {
        struct HeightContainer: Decodable {
            let height: Height
        }
        
        // Test decoding from string height
        do {
            let traits = """
            {
                "height": "4ft 3in"
            }
            """.data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(HeightContainer.self, from: traits)
                
                XCTAssertEqual(decoded.height.value, 4.25, "Decoded height should be 4 ft 3 in")
            } catch let error {
                XCTFail("Decoding heights threw an error: \(error)")
            }
        }
        
        
        // Test decoding from double height
        do {
            let traits = """
            {
                "height": 6.5
            }
            """.data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(HeightContainer.self, from: traits)
                
                XCTAssertEqual(decoded.height.value, 6.5, "Decoded height should be 4 ft 3 in")
            } catch let error {
                XCTFail("Decoding height threw an error: \(error)")
            }
        }
        
        // Test failure to decode
        // Test decoding from double height
        do {
            let traits = """
            {
                "height": "abcdefg"
            }
            """.data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                _ = try decoder.decode(HeightContainer.self, from: traits)
                XCTFail("Decoding height should have thrown an error")
                
            } catch let error {
                print("Decoding invalid height successfully threw an error: \(error)")
            }
        }
        
    }
    
    func testDecodingHeightIfPresent() {
        struct HeightContainer: Decodable {
            let height: Height? // The ? will trigger decodeIfPresent in the decoder
        }
        
        // Test decoding from string height
        do {
            let traits = """
            {
                "height": "4ft 3in"
            }
            """.data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(HeightContainer.self, from: traits)
                
                XCTAssertEqual(decoded.height?.value, 4.25, "Decoded height should be 4 ft 3 in")
            } catch let error {
                XCTFail("Decoding heights threw an error: \(error)")
            }
        }
        
        
        // Test decoding from double height
        do {
            let traits = """
            {
                "height": 6.5
            }
            """.data(using: .utf8)!
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(HeightContainer.self, from: traits)
                
                XCTAssertEqual(decoded.height?.value, 6.5, "Decoded height should be 4 ft 3 in")
            } catch let error {
                XCTFail("Decoding height threw an error: \(error)")
            }
        }
    }

}



