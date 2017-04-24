//
//  Dice.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//


/// A representation of one or more dice of different sides and combinations.
/// Implementations must conform to the CustomStringConvertible protocol.
public protocol Dice: CustomStringConvertible {
    
    /// Rolls the dice, and returns the result.
    func roll() -> Int
    
    /// Returns the number of dice sides.
    var sides: Int { get }
    
    /// Returns the intermediate results of the last dice roll. 
    /// Returns an empty array if no roll has been made.
    var lastRoll: [Int] { get }
    
    /// Returns a string representing the intermediate results of the dice roll
    /// (e.g., a "2d6" might return "(4+1)". Returns an empty string if no roll has been made.
    var lastRollDescription: String { get }
        
}
