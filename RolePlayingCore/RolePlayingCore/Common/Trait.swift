//
//  Trait.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/11/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

public struct Trait {
    
    public static let name = "name"
    
    public static let plural = "plural"
    
    public static let aliases = "aliases"
    
    public static let description = "description"
    
    public static let alignment = "alignment"
    
    public static let hitPoints = "hit points"

    public static let hitDice = "hit dice"
    
    static internal func logMissing(_ name: String) {
        print("Missing required trait: \"\(name)\"")
    }

}

/// A protocol for creating an instance from dictionary traits,
/// and encoding properties as dictionary traits.
public protocol TraitCoder {
    
    init?(from traits: Any?)
    
    func encodeTraits() -> Any?
    
}
