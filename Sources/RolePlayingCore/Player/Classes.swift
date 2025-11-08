//
//  Classes.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/13/16.
//  Copyright © 2016 Brian Arnold. All rights reserved.
//

import Foundation

/// A collection of class traits.
public struct Classes: CodableWithConfiguration {
    
    public var classes: [ClassTraits]
    public var experiencePoints: [Int]?
    
    public init(_ classes: [ClassTraits] = []) {
        self.classes = classes
    }
    
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
    
    // MARK: CodableWithConfiguration conformance
    
    public init(from decoder: Decoder, configuration: Configuration) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.classes = try values.decode([ClassTraits].self, forKey: .classes, configuration: configuration)
        self.experiencePoints = try values.decodeIfPresent([Int].self, forKey: .experiencePoints)
    }
    
    public func encode(to encoder: Encoder, configuration: Configuration) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(classes, forKey: .classes, configuration: configuration)
        try container.encodeIfPresent(experiencePoints, forKey: .experiencePoints)
    }
}
