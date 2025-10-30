//
//  RandomIndexGenerator.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 8/26/21.
//  Copyright © 2021 Brian Arnold. All rights reserved.
//

import Foundation

/// This random number generator can be implemented in a deterministic way for testing purposes (RandomNumberGenerator does not guarantee this).
public protocol RandomIndexGenerator {
    
    mutating func randomIndex(upperBound: Int) -> Int
}

/// This random number generator wraps the system random number generator
public struct DefaultRandomIndexGenerator: RandomIndexGenerator {
    
    internal var generator = SystemRandomNumberGenerator()
    
    public mutating func randomIndex(upperBound: Int) -> Int {
        return Int.random(in: 0..<upperBound, using: &generator)
    }
}

/// This random number generator isn't random at all; it just returns a sequence of integers, wrapping around upperBound. This generator may be used for testing.
public struct MockIndexGenerator: RandomIndexGenerator {
    
    var index: Int = 0
    
    public init() { }
    
    public mutating func randomIndex(upperBound: Int) -> Int {
        defer { index += 1 }
        return index % upperBound
    }
}

extension Array {
    
    // Extensions that mirror randomElement, but with a RandomIndexGenerator instead of a RandomNumberGenerator
    
    public func randomElementByIndex<T>(using generator: inout T) -> Element? where T : RandomIndexGenerator {
        let index = generator.randomIndex(upperBound: self.count)
        return self[index]
    }
    
    public func randomElementByIndex() -> Element? {
        var generator = DefaultRandomIndexGenerator()
        return randomElementByIndex(using: &generator)
    }
}


