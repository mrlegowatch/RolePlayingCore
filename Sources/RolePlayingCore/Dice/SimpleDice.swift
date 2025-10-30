//
//  SimpleDice.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/22/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//


/// A simple dice has a single die, and an optional number of times to roll.
public struct SimpleDice: Dice {
    public let die: Die
    public let times: Int
    
    /// Creates a SimpleDice for the specified die. Optionally specify times to roll,
    /// and whether to drop a high or low result. Defaults to rolling one time.
    public init(_ die: Die, times: Int = 1) {
        self.die = die
        self.times = times
    }
    
    /// Rolls the specified number of times, returning the array of rolls.
    internal func roll() -> [Int] {
        return die.roll(times)
    }
    
    /// Rolls the specified number of times, returning the sum of the rolls and a description.
    public func roll() -> DiceRoll {
        let lastRoll: [Int] = roll()
        
        let result = lastRoll.reduce(0, +)
        let description = rollDescription(lastRoll)
        
        return DiceRoll(result, description)
    }
    
    /// Returns the number of dice sides.
    public var sides: Int { die.rawValue }
    
    /// Returns a description, "[<times>]d<sides>"; times is left out if it is 1.
    public var description: String {
        let timesString = times == 1 ? "" : "\(times)"
        return "\(timesString)\(die)"
    }
    
    /// Returns the last roll as a sequence of added numbers in parenthesis.
    internal func rollDescription(_ lastRoll: [Int]) -> String {
        var resultString: String
        
        var rolls = lastRoll
        let last = rolls.popLast()!
        if rolls.count == 0 {
            resultString = "\(last)"
        } else {
            resultString = "("
            for roll in rolls {
                resultString += "\(roll) + "
            }
            resultString += "\(last))"
        }
        
        return resultString
    }
}
