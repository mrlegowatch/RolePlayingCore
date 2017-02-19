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
    
    func testDefaultClasses() {
        let classes = Classes(in: Bundle(for: ClassesTests.self))
        
        XCTAssertEqual(classes.classTraits.count, 4, "classTraits count failed")
        XCTAssertEqual(classes.classes.count, 4, "classes count failed")
        
        XCTAssertEqual(classes.experiencePoints?.count, 20, "array of experience points failed")
        
        // Test finding a class by name
        XCTAssertNotNil(classes.find("Fighter"), "Fighter should be non-nil")
        XCTAssertNil(classes.find("Foo"), "Foo should be nil")
        XCTAssertNil(classes.find(nil), "nil class name should find nil")
    }
    
    func testUncommonClasses() {
        var classes: Classes? = nil
        do {
            classes = try Classes("UncommonClasses", in: Bundle(for: ClassesTests.self))
        }
        catch let error {
            XCTFail("Classes threw an error: \(error)")
        }
        
        XCTAssertNotNil(classes, "Uncommon Races file failed to load")
        
        XCTAssertEqual(classes?.classTraits.count, 8, "classTraits count failed")
        XCTAssertEqual(classes?.classes.count, 8, "classes count failed")
    }
    
}
