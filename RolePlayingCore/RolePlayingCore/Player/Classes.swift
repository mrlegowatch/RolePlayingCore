//
//  Classes.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/13/16.
//  Copyright © 2016 Brian Arnold. All rights reserved.
//

// A set of class traits
public struct Classes: Codable {
    
    public var classes = [ClassTraits]()
    public var experiencePoints: [Int]?
    
    private enum CodingKeys: String, CodingKey {
        case classes
        case experiencePoints = "experience points"
    }
    
    public func find(_ className: String?) -> ClassTraits? {
        return classes.first(where: { $0.name == className })
    }
    
    public var count: Int { return classes.count }
    
    public subscript(index: Int) -> ClassTraits? {
        get {
            return classes[index]
        }
    }
}
