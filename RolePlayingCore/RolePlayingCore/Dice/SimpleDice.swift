//
//  SimpleDice.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/22/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//


/// A simple dice has a single die, and an optional number of times to roll.
/// Tracks the last roll (array of Ints) each time roll() is called.
public class SimpleDice: Dice {
    
    public let die: Die
    public let times: Int
    public private(set) var lastRoll: [Int] = []
    
    /// Creates a SimpleDice for the specified die. Optionally specify times to roll,
    /// and whether to drop a high or low result. Defaults to rolling one time.
    public init(_ die: Die, times: Int = 1) {
        self.die = die
        self.times = times
    }
    
    /// Rolls the specified number of times, returning the sum of the rolls.
    /// The intermediate rolls can be inspected in lastRoll.
    public func roll() -> Int {
        lastRoll = die.roll(times)
        return lastRoll.reduce(0, +)
    }
    
    /// Returns the number of dice sides.
    public var sides: Int { return die.rawValue }
    
    /// Returns a description, "[<times>]d<sides>"; times is left out if it is 1.
    public var description: String {
        let timesString = times == 1 ? "" : "\(times)"
        return "\(timesString)\(die)"
    }
    
    /// Returns the last roll as a sequence of added numbers in parenthesis.
    public var lastRollDescription: String {
        guard self.lastRoll.count > 0 else { return "" }
        var resultString: String
        
        var rolls = self.lastRoll
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
