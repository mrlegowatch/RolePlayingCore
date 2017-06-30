//
//  ClassesTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/16/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class ClassesTests: XCTestCase {
    
    let bundle = Bundle(for: ClassesTests.self)
    let decoder = JSONDecoder()
    
    func testDefaultClasses() {
        var classes: Classes! = nil
        do {
            let jsonData = try bundle.loadJSON("TestClasses")
            classes = try decoder.decode(Classes.self, from: jsonData)
        }
        catch {
            XCTFail("Classes threw an error: \(error)")
        }
        
        XCTAssertEqual(classes.classes.count, 4, "classes count failed")
        XCTAssertEqual(classes.count, 4, "classes count failed")
        XCTAssertNotNil(classes[0], "class by index failed")
        
        XCTAssertEqual(classes.experiencePoints?.count, 20, "array of experience points failed")
        
        // Test finding a class by name
        XCTAssertNotNil(classes.find("Fighter"), "Fighter should be non-nil")
        XCTAssertNil(classes.find("Foo"), "Foo should be nil")
        XCTAssertNil(classes.find(nil), "nil class name should find nil")
    }
    
    func testUncommonClasses() {
        var classes: Classes! = nil
        do {
            let jsonData = try bundle.loadJSON("TestMoreClasses")
            classes = try decoder.decode(Classes.self, from: jsonData)
        }
        catch let error {
            XCTFail("Classes threw an error: \(error)")
        }
        
        XCTAssertEqual(classes.classes.count, 8, "classes count failed")
    }
    
}
