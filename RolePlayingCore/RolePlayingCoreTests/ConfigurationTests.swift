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
    
    func testRolePlayingCore() {
        var configuration: Configuration? = nil
        do {
            configuration = try Configuration("TestConfiguration", in: Bundle(for: ConfigurationTests.self))
        }
        catch let error {
            XCTFail("Configuration threw an error: \(error)")
        }
        
        XCTAssertNotNil(configuration, "configuration should be non-nil")
        
        
    }
    
}
