//
//  ServiceErrorTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore

@Suite("Service Error Tests")
struct ServiceErrorTests {
    
    @Test("Verify ServiceError contains expected information")
    func serviceError() async throws {
        do {
            throw RuntimeError("Gah!")
        } catch {
            #expect(error is ServiceError, "should be a service error")
            let description = "\(error)"
            #expect(description.contains("Runtime error"), "should be a runtime error")
            #expect(description.contains("Gah!"), "should contain the message")
            #expect(description.contains("serviceError"), "should have throw function name in it")
            #expect(description.contains("ServiceErrorTests"), "should have throw file name in it")
        }
    }
}
