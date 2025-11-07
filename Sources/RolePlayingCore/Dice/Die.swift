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
    /// Also known as "`d%`"
    case d100 = 100
    
    /// Rolls once and returns a number between 1 and this dice type.
    public func roll<G: RandomNumberGenerator>(using generator: inout G) -> Int {
        return Int.random(in: 1...self.rawValue, using: &generator)
    }
    
    /// Rolls once and returns a number between 1 and this dice type.
    public func roll() -> Int {
        var rng = SystemRandomNumberGenerator()
        return roll(using: &rng)
    }
    
    /// Rolls the specified number of times and returns an array of numbers between 1 and this dice type.
    public func roll(_ times: Int) -> [Int] {
        return (0..<times).map { _ in roll() }
    }
}

extension Die: CustomStringConvertible {
    
    /// Returns the number of die sides with "d" prepended.
    public var description: String { rawValue == 100 ? "d%" : "d\(rawValue)" }
}
