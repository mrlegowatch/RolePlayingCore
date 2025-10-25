//
//  DroppingDice.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/22/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//


/// A dropping dice is an extension of SimpleDice that drops the highest or lowest roll.
/// This is done through composition, instead of subclassing.
public struct DroppingDice: Dice {
    
    public let dice: SimpleDice
    
    /// Options to drop the lowest or highest roll.
    public enum Drop: String, CaseIterable {
        case lowest = "L"
        case highest = "H"
    }
    
    /// Whether to drop the lowest or highest roll.
    public let drop: Drop
    
    /// Creates a SimpleDice for the specified die, times to roll,
    /// and whether to drop the high or low result.
    public init(_ die: Die, times: Int, drop: Drop) {
        let dice = SimpleDice(die, times: times)
        self.init(dice, drop: drop)
    }
    
    /// Wraps a SimpleDice with whether to drop the high or low result.
    public init(_ dice: SimpleDice, drop: Drop) {
        self.dice = dice
        self.drop = drop
    }

    /// Returns the number of dice sides.
    public var sides: Int { return dice.sides }
    
    /// Rolls the specified number of times, returning the sum of the rolls,
    /// minus the dropped roll. The intermediate rolls, including the dropped roll,
    /// can be inspected in dice.lastRoll.
    public func roll() -> DiceRoll {
        let lastRoll: [Int] = dice.roll()
        let droppedRoll = (drop == .lowest) ? lastRoll.min() : lastRoll.max()
        
        let result = lastRoll.reduce(0, +) - droppedRoll!
        let description = "(\(dice.rollDescription(lastRoll)) - \(droppedRoll!))"
        
        return DiceRoll(result, description)
    }
    
    /// Returns a description of the dice, with "-L" or "-H" appended.
    public var description: String {
        return "\(dice)-\(drop.rawValue)"
    }
    
}
