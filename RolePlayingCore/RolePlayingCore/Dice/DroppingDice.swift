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
    
    /// Returns the number of dice sides.
    public var sides: Int { return dice.sides }
    
    /// Return the value of the dropped roll. Returns nil if no roll has been made.
    public var droppedRoll: Int? {
        return dropping == .lowest ? dice.lastRoll.min() : dice.lastRoll.max()
    }
    
    /// Returns the index of the dropped roll. Returns nil if no roll has been made.
    public var droppedIndex: Int? {
        guard let roll = droppedRoll else { return nil }
        return dice.lastRoll.index(of: roll)
    }
    
    /// Returns the last rolls of the dice, with the dropped roll removed.
    /// To obtain the last roll without the dropped roll removed, use dice.lastRoll.
    public var lastRoll: [Int] {
        guard dice.lastRoll.count > 0 else { return [] }
        
        var roll = dice.lastRoll // we're going to return a modified copy of the dice's lastRoll
        roll.remove(at: droppedIndex!)
        return roll
    }
    
    /// Options to drop the lowest or highest roll.
    public enum Dropping: String {
        case lowest = "-L"
        case highest = "-H"
        
        static let allValues: [Dropping] = [.lowest, .highest]
    }
    
    /// Whether to drop the lowest or highest roll.
    public let dropping: Dropping
    
    /// Creates a SimpleDice for the specified die, times to roll,
    /// and whether to drop the high or low result.
    public init(_ die: Die, times: Int, dropping: Dropping) {
        self.init(SimpleDice(die, times: times), dropping: dropping)
    }
    
    /// Wraps a SimpleDice with whether to drop the high or low result.
    public init(_ dice: SimpleDice, dropping: Dropping) {
        self.dice = dice
        self.dropping = dropping
    }
    
    /// Rolls the specified number of times, returning the sum of the rolls,
    /// minus the dropped roll. The intermediate rolls, including the dropped roll,
    /// can be inspected in dice.lastRoll.
    public func roll() -> Int {
        let _ = dice.roll()
        return self.lastRoll.reduce(0, +)
    }
    
    /// Returns a description of the dice, with "-L" or "-H" appended.
    public var description: String {
        return "\(dice)\(dropping.rawValue)"
    }
    
    /// Returns the last roll as a sequence of added numbers in parenthesis. Includes dropped rolls.
    public var lastRollDescription: String {
        guard dice.lastRoll.count > 0 else { return "" }
        return "(\(dice.lastRollDescription) - \(droppedRoll!))"
    }
    
}
