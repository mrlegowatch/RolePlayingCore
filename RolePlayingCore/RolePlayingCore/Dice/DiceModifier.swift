//
//  DiceModifier.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/22/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//


/// A dice modifier is a constant value that can take the place of a Dice instance.
public struct DiceModifier: Dice {
    
    public let modifier: Int
    
    public init(_ modifier: Int) {
        self.modifier = modifier
    }
    
    public func roll() -> DiceRoll {
        return DiceRoll(modifier, "\(modifier)")
    }
    
    public var sides: Int { return modifier }
    
    public var description: String { return "\(modifier)" }
        
}
