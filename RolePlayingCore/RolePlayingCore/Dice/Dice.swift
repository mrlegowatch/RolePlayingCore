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
    
    /// Rolls the dice, and returns the result in a DiceRoll.
    func roll() -> DiceRoll
    
    /// Returns the number of dice sides.
    var sides: Int { get }
}
