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
    
    /// Rolls the dice, and returns the result.
    func roll() -> Int
    
    /// Returns the number of dice sides.
    var sides: Int { get }
    
    /// Returns the intermediate results of the last dice roll. 
    /// Returns an empty array if no roll has been made.
    var lastRoll: [Int] { get }
    
    /// Returns a string representing the intermediate results of the dice roll
    /// (e.g., a "2d6" might return "(4+1)". Returns an empty string if no roll has been made.
    var lastRollDescription: String { get }
        
}

/// An enumeration of die sizes, from d4 to d%.
public enum Die: Int, CustomStringConvertible {
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
 
    /// Returns the number of die sides with "d" prepended.
    public var description: String { return "d\(rawValue)" }
    
}

/// A dice modifier is a constant value that can take the place of a Dice instance.
public struct DiceModifier: Dice {
    
    public let modifier: Int
    
    public init(_ modifier: Int) { self.modifier = modifier }
    
    public func roll() -> Int { return modifier }
    
    public var sides: Int { return modifier }
    
    public var lastRoll: [Int] { return [modifier] }
    
    public var description: String { return "\(modifier)" }
    
    public var lastRollDescription: String { return "\(modifier)" }

}

/// A simple dice has a single die, and an optional number of times to roll.
/// Tracks the last roll (array of Ints) each time roll() is called.
public class SimpleDice: Dice {

    public let die: Die
    public let times: Int
    public private(set) var lastRoll: [Int] = []

    /// Creates a SimpleDice for the specified die. Optionally specify times to roll, 
    /// and whether to drop a high or low result. Defaults ot rolling one time.
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
        self.dice = SimpleDice(die, times: times)
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
        return "\(dice.lastRollDescription) - \(droppedRoll!)"
    }
    
}

// TODO: there is an issue with the math operators map, it can't be expanded without
// generating a compiler error (expression too complex).

/// Function signature for a math operator or function.
public typealias MathOperator = (Int, Int) -> Int

/// Mapping of strings to function signatures.
internal let mathOperators: [String: MathOperator] = ["+": (+), "-": (-), "x": (*)]

/// The character set of math operators.
internal let mathOperatorCharacters = CharacterSet(charactersIn: mathOperators.keys.reduce("", +))

/// General-purpose composition of dice rolls.
/// The two primary use cases for this type are:
/// - combining two rolls, e.g., "2d4+d6",
/// - using a modifier, e.g., "d12+2".
public struct CompoundDice: Dice {
    
    public let lhs: Dice
    public let rhs: Dice
    public let mathOperator: String
    
    /// Creates a dice that conforms to the syntax "<times>d<size><mathOperator><modifier>".
    /// All parameters except die are optional; times defaults to 1, modifier defaults to 0,
    /// and math operator defaults to "+".
    public init(_ die: Die, times: Int = 1, modifier: Int = 0, mathOperator: String = "+") {
        self.lhs = SimpleDice(die, times: times)
        self.rhs = DiceModifier(modifier)
        self.mathOperator = mathOperator
    }
    
    /// Creates a dice from two dice instances with a math operator.
    public init(lhs: Dice, rhs: Dice, mathOperator: String) {
        self.lhs = lhs
        self.rhs = rhs
        self.mathOperator = mathOperator
    }
    
    /// Rolls the specified number of times, optionally adding or multiplying a modifier,
    /// and returning the result.
    public func roll() -> Int {
        let lhsResult = lhs.roll()
        let rhsResult = rhs.roll()
        return mathOperators[mathOperator]!(lhsResult, rhsResult)
    }
    
    /// Returns the number of sides of the left hand dice.
    public var sides: Int { return lhs.sides }
    
    /// Returns a concatenation of the left hand and right hand last rolls.
    public var lastRoll: [Int] {
        guard lhs.lastRoll.count > 0 && rhs.lastRoll.count > 0 else { return [] }
        return lhs.lastRoll + rhs.lastRoll
    }
    
    /// Returns a description of the left and right hand sides with the math operator.
    public var description: String { return "\(lhs)\(mathOperator)\(rhs)" }
    
    /// Returns a intermediate results of the left and right hand sides with the math operator.
    public var lastRollDescription: String {
        guard lhs.lastRoll.count > 0 && rhs.lastRoll.count > 0 else { return "" }
        return "\(lhs.lastRollDescription) \(mathOperator) \(rhs.lastRollDescription)"
    }
    
}
