//
//  ServiceErrorTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class ServiceErrorTests: XCTestCase {
    
    func testServiceError() {
        do {
            throw RuntimeError("Gah!")
        }
        catch let error {
            XCTAssertTrue(error is ServiceError, "should be a service error")
            let description = "\(error)"
            XCTAssertTrue(description.contains("Runtime error"), "should be a runtime error")
            XCTAssertTrue(description.contains("Gah!"), "should contain the message")
            XCTAssertTrue(description.contains("testServiceError"), "should have throw function name in it")
            XCTAssertTrue(description.contains("ServiceErrorTests"), "should have throw file name in it")
        }
    }
}
