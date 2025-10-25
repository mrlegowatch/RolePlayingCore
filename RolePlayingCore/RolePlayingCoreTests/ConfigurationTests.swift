//
//  ConfigurationTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class ConfigurationTests: XCTestCase {
    
    func testDefaultConfiguration() {
        do {
            let bundle = Bundle(for: ConfigurationTests.self)            
            let configuration = try Configuration("TestConfiguration", from: bundle)
            
            // Print an ability score summary for edification
            print("Ability Score Summary:")
            let abilities = Ability.defaults
            for ability in abilities {
                var importantFor = [String]()
                var speciesIncreases = [String]()
                
                for classTraits in configuration.classes.classes {
                    if classTraits.primaryAbility.contains(ability) {
                        importantFor.append(classTraits.name)
                    }
                }
                
                for speciesTraits in configuration.species.species {
                    if let increase = speciesTraits.abilityScoreIncrease[ability], increase != 0 {
                        
                        speciesIncreases.append("\(speciesTraits.name) (+\(increase))")
                    }
                }
                
                // TODO: make into assertions. For now, visually compare results.
                print(ability.name)
                let important = importantFor.count == 0 ? ["Everyone"] : importantFor
                print("Important for: \(important)")
                print("Species increases: \(speciesIncreases)")
            }
            
            
        }
        catch let error {
            XCTFail("Configuration threw an error: \(error)")
        }
    }
    
    func testInvalidConfiguration() {
        do {
            let bundle = Bundle(for: ConfigurationTests.self)
            
            _ = try Configuration("InvalidConfiguration", from: bundle)
            XCTFail("Invalid configuration should have thrown an error")
        }
        catch let error {
            print("Invalid configuration correctly threw an error: \(error)")
        }
    }
    
}
