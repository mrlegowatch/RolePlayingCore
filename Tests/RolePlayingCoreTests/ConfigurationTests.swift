//
//  ConfigurationTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Configuration Tests")
struct ConfigurationTests {
    
    let bundle = Bundle.module
    
    @Test("Default configuration loads successfully")
    func defaultConfiguration() async throws {
        let configuration = try Configuration("TestConfiguration", from: bundle)
        
        // Print an ability score summary for edification
        print("Ability Score Summary:")
        let abilities = Ability.defaults
        for ability in abilities {
            var importantFor = [String]()
            
            for classTraits in configuration.classes.classes {
                if classTraits.primaryAbility.contains(ability) {
                    importantFor.append(classTraits.name)
                }
            }
            
            // TODO: make into assertions. For now, visually compare results.
            print(ability.name)
            let important = importantFor.count == 0 ? ["Everyone"] : importantFor
            print("Important for: \(important)")
        }
    }
    
    @Test("Invalid configuration throws error")
    func invalidConfiguration() async throws {
        #expect(throws: (any Error).self) {
            _ = try Configuration("InvalidConfiguration", from: bundle)
        }
    }
}
