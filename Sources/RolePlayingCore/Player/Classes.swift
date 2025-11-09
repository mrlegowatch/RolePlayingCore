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
    
    /// A dictionary of class traits indexed by name.
    private var allClasses: [String: ClassTraits] = [:]
    
    /// An array of class traits.
    public var all: [ClassTraits] { Array(allClasses.values) }
    
    /// An optional table of the minimum experience points required to reach the next level.
    public var experiencePoints: [Int]?
    
    /// Returns an instance of a collection of background traits., optionally with a shared experience points table.
    public init(_ classes: [ClassTraits] = [], experiencePoints: [Int]? = nil) {
        add(classes, experiencePoints)
    }
    
    /// Adds the array of class traits to the collection, and optionally updates all experience points with a shared experience points table.
    mutating func add(_ classes: [ClassTraits], _ experiencePoints: [Int]? = nil) {
        let mappedClasses = Dictionary(classes.map { ($0.name, $0) }, uniquingKeysWith: { _, last in last })
        allClasses.merge(mappedClasses, uniquingKeysWith: { _, last in last })
        
        if let experiencePoints {
            self.experiencePoints = experiencePoints
            for name in allClasses.keys {
                self.allClasses[name]?.experiencePoints = experiencePoints
            }
        }
    }
    
    /// Adds the collection of class traits to the collection, and if present, optionally updates all experience points with a shared experience points table.
    mutating func add(_ classes: Classes) {
        add(classes.all, classes.experiencePoints)
    }
    
    /// Accesses a class traits instance by name.
    public subscript(className: String) -> ClassTraits? {
        return allClasses[className]
    }
    
    /// Returns the number of class traits in the collection.
    public var count: Int { allClasses.count }
    
    /// Accesses a class traits instance by index.
    public subscript(index: Int) -> ClassTraits? {
        guard index >= 0 && index < count else { return nil }
        return all[index]
    }
    
    // MARK: CodableWithConfiguration conformance
    
    private enum CodingKeys: String, CodingKey {
        case classes
        case experiencePoints = "experience points"
    }

    public init(from decoder: Decoder, configuration: Configuration) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let classes = try values.decode([ClassTraits].self, forKey: .classes, configuration: configuration)
        add(classes)
        self.experiencePoints = try values.decodeIfPresent([Int].self, forKey: .experiencePoints)
    }
    
    public func encode(to encoder: Encoder, configuration: Configuration) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(all, forKey: .classes, configuration: configuration)
        try container.encodeIfPresent(experiencePoints, forKey: .experiencePoints)
    }
}
