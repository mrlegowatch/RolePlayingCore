//
//  CharacterGeneratorTests.swift
//  RolePlayingCoreTests
//
//  Created by Brian Arnold on 7/9/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Character Generator Tests")
struct CharacterGeneratorTests {
    
    let bundle = Bundle.module
    
    let sampleSize = 256
    
    @Test("Character generation")
    func characterGenerator() async throws {
        let configuration = try Configuration("TestCharacterGenerator", from: bundle)
        let characterGenerator = try CharacterGenerator(configuration, from: bundle)
        
        for _ in 0..<sampleSize {
            _ = characterGenerator.makeCharacter()
            // TODO: implement a predictable Random implementation and consider testing for expected types, names and properties. Such a test could be too sensitive to order of calls.
        }
    }
    
    @Test("Character generator invalid configuration")
    func invalidConfiguration() async throws {
        let configuration = try Configuration("TestConfiguration", from: bundle)
        
        #expect(throws: Error.self) {
            try CharacterGenerator(configuration, from: bundle)
        }
    }
}
