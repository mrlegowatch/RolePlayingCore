//
//  CompoundDice.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/22/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation


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
        let dice = SimpleDice(die, times: times)
        let modifier = DiceModifier(modifier)
        self.init(lhs: dice, rhs: modifier, mathOperator: mathOperator)
    }
    
    /// Creates a dice from two dice instances with a math operator.
    public init(lhs: Dice, rhs: Dice, mathOperator: String) {
        self.lhs = lhs
        self.rhs = rhs
        self.mathOperator = mathOperator
    }

    /// Function signature for a math operator or function.
    internal typealias MathOperator = (Int, Int) -> Int
    
    /// Mapping of strings to function signatures.
    internal static let mathOperators: [String: MathOperator] = ["+": (+), "-": (-), "x": (*), "*": (*), "/": (/)]

    /// Rolls the specified number of times, optionally adding or multiplying a modifier,
    /// and returning the result.
    public func roll() -> Int {
        let lhsResult = lhs.roll()
        let rhsResult = rhs.roll()
        return CompoundDice.mathOperators[mathOperator]!(lhsResult, rhsResult)
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
