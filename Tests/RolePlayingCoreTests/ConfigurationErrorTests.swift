//
//  ConfigurationErrorTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore

@Suite("Configuration Error Tests")
struct ConfigurationErrorTests {
    
    @Test("Verify ConfigurationError contains expected information")
    func configurationError() async throws {
        do {
            throw missingFileError("Foo.json", "MyBundle")
        } catch {
            #expect(error is ConfigurationError, "should be a configuration error")
            let description = "\(error)"
            #expect(description.contains("Configuration error"), "should be a configuration error")
            #expect(description.contains("Foo.json"), "should contain the message")
            #expect(description.contains("configurationError"), "should have throw function name in it")
            #expect(description.contains("ConfigurationErrorTests"), "should have throw file name in it")
        }
    }
}
