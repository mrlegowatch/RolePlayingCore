//
//  RandomNumberGenerator.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/12/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

#if os(Linux)
    import Glibc
#endif

public protocol RandomNumberGenerator {
    
    /// Returns a random number between 0..<upperBound.
    func random(_ upperBound: Int) -> Int
    
}

/// The default random number generator uses arc4random_uniform() on macOS/iOS,
/// and random() on Linux.
public struct DefaultRandomNumberGenerator: RandomNumberGenerator {
    
    /// Creates and initializes this random number generator.
    public init() {
        #if os(Linux)
            let timeInterval = time(nil)
            Glibc.srandom(UInt32(timeInterval))
        #endif
    }
    
    /// Returns a random number between 0 ..< upperBound.
    public func random(_ upperBound: Int) -> Int {
        #if os(Linux)
            return Glibc.random() % upperBound
        #else
            return Int(arc4random_uniform(UInt32(upperBound)))
        #endif
    }
}
