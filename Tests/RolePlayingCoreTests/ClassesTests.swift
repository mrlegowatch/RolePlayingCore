//
//  ClassesTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/16/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Classes Tests")
struct ClassesTests {
    
    let bundle = Bundle.module
    let decoder = JSONDecoder()
    let configuration: Configuration
    
    init() throws {
        configuration = try Configuration("TestClassesConfiguration", from: .module)
    }
    
    @Test("Default classes")
    func defaultClasses() throws {
        let jsonData = try bundle.loadJSON("TestClasses")
        let classes = try decoder.decode(Classes.self, from: jsonData, configuration: configuration)
        #expect(classes.classes.count == 4, "classes count failed")
        #expect(classes.count == 4, "classes count failed")
        #expect(classes[0] != nil, "class by index failed")
        
        #expect(classes.experiencePoints?.count == 20, "array of experience points failed")
        
        // Test finding a class by name
        #expect(classes.find("Fighter") != nil, "Fighter should be non-nil")
        #expect(classes.find("Foo") == nil, "Foo should be nil")
        #expect(classes.find(nil) == nil, "nil class name should find nil")
    }
    
    @Test("Uncommon classes")
    func uncommonClasses() throws {
        let jsonData = try bundle.loadJSON("TestMoreClasses")
        let classes = try decoder.decode(Classes.self, from: jsonData, configuration: configuration)
        
        #expect(classes.classes.count == 8, "classes count failed")
    }
    
}
