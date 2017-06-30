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
            let bundle = Bundle(for: ConfigurationTests.self)
            
            // TODO: we want to do this, but can't yet forward the bundle to the nested loadJSON calls
            //configuration = try jsonDecoder.decode(Configuration.self, from: jsonData)
            //let jsonData = try bundle.loadJSON("TestConfiguration")
            //let jsonDecoder = JSONDecoder()
            configuration = Configuration(bundle)
        }
        //catch let error {
        //    XCTFail("Configuration threw an error: \(error)")
        //}
        
        XCTAssertNotNil(configuration, "configuration should be non-nil")
        
        
    }
    
}
