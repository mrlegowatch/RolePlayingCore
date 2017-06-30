//
//  Die.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/22/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//


/// An enumeration of die sizes, from d4 to d%.
public enum Die: Int {
    case d4 = 4
    case d6 = 6
    case d8 = 8
    case d10 = 10
    case d12 = 12
    case d20 = 20
    case d100 = 100 // AKA "d%"
    
    /// Set this at startup to use a different random number generator.
    public static var randomNumberGenerator: RandomNumberGenerator = DefaultRandomNumberGenerator()
    
    /// Uses the random number generator to return an integer from 1...upperBound.
    private func random(_ upperBound: Int) -> Int {
        return Die.randomNumberGenerator.random(upperBound) + 1
    }
    
    /// Rolls once and returns a number between 1 and this dice type.
    public func roll() -> Int {
        return random(self.rawValue)
    }
    
    /// Rolls the specified number of times and returns an array of numbers between 1 and this dice type.
    public func roll(_ times: Int) -> [Int] {
        var rolls = [Int](repeating: 0, count: times) // preallocating is much faster than appending
        
        for index in 0 ..< times {
            rolls[index] = roll()
        }
        return rolls
    }
    
}

extension Die: CustomStringConvertible {
    
    /// Returns the number of die sides with "d" prepended.
    public var description: String { return rawValue == 100 ? "d%" : "d\(rawValue)" }
    
}
