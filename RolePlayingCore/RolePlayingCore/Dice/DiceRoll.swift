//
//  DiceRoll.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/15/18.
//  Copyright © 2018 Brian Arnold. All rights reserved.
//

/// Encapsulates a result with its intermediate values.
public struct DiceRoll: CustomStringConvertible {
    
    /// The result of the roll.
    public let result: Int
    
    /// A string representing the intermediate values of the dice roll.
    /// For example, a "3d6" might return "(4+1+5)".
    public let description: String
    
    /// Creates a roll with its accompanying description of intermediate values.
    init(_ result: Int, _ description: String) {
        self.result = result
        self.description = description
    }
    
}

