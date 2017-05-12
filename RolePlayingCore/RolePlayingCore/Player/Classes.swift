//
//  Classes.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/13/16.
//  Copyright © 2016 Brian Arnold. All rights reserved.
//

public extension Trait {
    
    public static let className = "class"
    
    public static let classes = "classes"
    
}

// A Classes bundle must include a plist file enumerating the classes,
// and individual json files for each specified  class.
// By default, the main bundle is used.
public class Classes {
    
    public var classTraits = [ClassTraits]()
    
    public var classes: [ClassTraits] { return classTraits }
    
    public var experiencePoints: [Int]?

    /// Creates an empty classes list
    public init() {
    }
    
    /// Creates classes from the specified classes file.
    public init(_ classesFile: String, in bundle: Bundle = .main) throws  {
        try load(classesFile, in: bundle)
    }
    
    /// Adds classes from the specified classes file.
    public func load(_ classesFile: String, in bundle: Bundle = .main) throws {
        let jsonObject = try bundle.loadJSON(classesFile)

        // Load experience points per level
        experiencePoints = jsonObject[Trait.experiencePoints] as? [Int]

        let classes = jsonObject[Trait.classes] as! [[String: Any]]
        for classDictionary in classes {
            add(classDictionary)
        }
    }
    
    internal func add(_ classDictionary: [String: Any]) {
        if var classTraits = ClassTraits(from: classDictionary) {
            // Give classTraits access to global classes experiencePoints if specified
            if classTraits.experiencePoints == nil {
                classTraits.experiencePoints = self.experiencePoints
            }
            self.classTraits.append(classTraits)
        }
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
