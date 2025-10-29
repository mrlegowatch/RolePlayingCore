//
//  UnitHeightTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore

@Suite("Height Parsing and Serialization Tests")
struct UnitHeightTests {

    @Test("Parse various height formats")
    func heights() async throws {
        do {
            let howTall = "5".parseHeight
            #expect(howTall != nil, "height should be non-nil")
            #expect(howTall?.value == 5.0, "height should be 5.0")
        }

        do {
            let howTall = "3.0".parseHeight
            #expect(howTall != nil, "height should be non-nil")
            #expect(howTall?.value == 3.0, "height should be 3.0")
        }
  
        do {
            let howTall = "4 ft 3 in".parseHeight
            #expect(howTall != nil, "height should be non-nil")
            #expect(howTall?.value == 4.0 + 3.0/12.0, "height should be 4.25")
        }

        do {
            let howTall = "73in".parseHeight
            #expect(howTall != nil, "height should be non-nil")
            let howTallValue = howTall?.value ?? 0.0
            #expect(abs(howTallValue - (6.0 + 1.0/12.0)) < 0.0001, "height should be 6.08")
        }

        do {
            let howTall = "5'4\"".parseHeight
            #expect(howTall != nil, "height should be non-nil")
            #expect(howTall?.value == 5.0 + 4.0/12.0, "height should be 5.33")
        }
        
        do {
            let howTall = "130 cm".parseHeight?.converted(to: .meters)
            #expect(howTall != nil, "height should be non-nil")
            #expect(howTall?.value == 1.3, "height should be 1.3")
        }
        
        do {
            let howTall = "2.1m".parseHeight
            #expect(howTall != nil, "height should be non-nil")
            #expect(howTall?.value == 2.1, "height should be 2.1")
        }
    }
    
    @Test("Parse invalid height strings")
    func invalidHeights() async throws {
        let howTall = "3 hello".parseHeight
        #expect(howTall == nil, "height should be nil")
    }
    
    @Test("Encode height to JSON")
    func encodingHeight() async throws {
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
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(heightContainer)
        let deserialized = try JSONSerialization.jsonObject(with: encoded, options: .allowFragments)
        print("deserialized = \n\(deserialized)")
        let container = deserialized as? [String: Any]
        let height = container?["height"] as? String
        #expect(height == "3.2 m", "Encoded height did not become a string")
    }
    
    @Test("Decode height from JSON")
    func decodingHeight() async throws {
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
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(HeightContainer.self, from: traits)
            
            #expect(decoded.height.value == 4.25, "Decoded height should be 4 ft 3 in")
        }
        
        // Test decoding from double height
        do {
            let traits = """
            {
                "height": 6.5
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(HeightContainer.self, from: traits)
            
            #expect(decoded.height.value == 6.5, "Decoded height should be 6.5")
        }
        
        // Test failure to decode
        do {
            let traits = """
            {
                "height": "abcdefg"
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            #expect(throws: (any Error).self) {
                _ = try decoder.decode(HeightContainer.self, from: traits)
            }
        }
    }
    
    @Test("Decode optional height from JSON")
    func decodingHeightIfPresent() async throws {
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
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(HeightContainer.self, from: traits)
            
            #expect(decoded.height?.value == 4.25, "Decoded height should be 4 ft 3 in")
        }
        
        // Test decoding from double height
        do {
            let traits = """
            {
                "height": 6.5
            }
            """.data(using: .utf8)!
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(HeightContainer.self, from: traits)
            
            #expect(decoded.height?.value == 6.5, "Decoded height should be 6.5")
        }
    }
}



