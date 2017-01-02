//
//  DiceParser.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/23/16.
//  Copyright © 2016 Brian Arnold. All rights reserved.
//

// TODO: This avoids using a full parser or regexp for now; it is only ~100 lines, and
// it supports ~95% of use cases for specifying compound dice rolls of most things,
// including different dice, modifiers, and dropping the highest or lowest of multiple rolls.
//
// This is not intended to be used for general parsing of nested compound dice rolls, however;
// it is expected that a game rules engine would likely be combining simpler dice
// rolls and modifiers directly, which may provide the following key benefits:
//
//  - maintains separation of concerns (each owner of a dice roll is responsible for its role)
//  - allows for caching and introspection of intermediate rolls

// Extensions for parsing a dice-formatted string.
private extension String {
    
    /// Returns the number before the "d" if present, otherwise returns nil.
    func parseDiceTimes(before dRange: Range<String.Index>) -> Int? {
        guard dRange.lowerBound != self.startIndex, let times = Int(self.substring(to: dRange.lowerBound)) else { return nil }
        return times
    }
    
    /// Returns the substring range as an Int, or 100 if the string is "%".
    /// Returns nil if the string can't be converted into a number.
    func parseDiceSides(in diceRange: Range<String.Index>) -> Int? {
        let sidesString = self.substring(with: diceRange)
        return sidesString == "%" ? 100 : Int(sidesString)
    }
    
    /// If a supported math operator is in the string, and if the operand
    /// of the string can be converted to a Dice, returns the operand, the math
    /// operator, and the lower bound index before the operator.
    func parseDiceMath() -> (Dice?, String, String.Index) {
        guard let range = self.rangeOfCharacter(from: mathOperatorCharacters), let operand = dice(from: self.substring(from: range.upperBound)) else { return (nil, "+", self.endIndex) }
        return (operand, self[range], range.lowerBound)
    }
    
    /// If a supported math operator is in the string, and if the operand
    /// of the string can be converted to a Dice modifier, returns the operand, the math
    /// operator, and the lower bound index before the operator.
    func parseDiceModifier() -> (Dice?, String, String.Index) {
        guard let range = self.rangeOfCharacter(from: mathOperatorCharacters), let operand = modifier(from: self.substring(from: range.upperBound)) else { return (nil, "+", self.endIndex) }
        return (operand, self[range], range.lowerBound)
    }

    /// If a dropping suffix is present in the string as a suffix, returns the corresponding
    /// Dropping enumeration. Returns nil if neither is present.
    func parseDiceDropping() -> (DroppingDice.Dropping?, String.Index) {
        var parsed: DroppingDice.Dropping?
        var operatorIndex = self.endIndex
        
        for dropping in DroppingDice.Dropping.allValues {
            if let range = self.range(of: dropping.rawValue), range.upperBound == self.endIndex {
                parsed = dropping
                operatorIndex = range.lowerBound
                break
            }
        }
        
        return (parsed, operatorIndex)
    }
    
}

// Returns a DiceModifier if the string can be converted to Int, otherwise attempts to parse
// the string as a sequence of Int with math operators. Returns nil if it runs into trouble.
private func modifier(from string: String) -> Dice? {
    var dice: Dice?

    // Is it just a number modifier?
    if let modifier = Int(string) {
        dice = DiceModifier(modifier)
    } else {
        // Try a math operator.
        let (modifier, mathOperator, endIndex) = string.parseDiceModifier()
        if modifier != nil, let leftNumber = Int(string.substring(with: string.startIndex..<endIndex)) {
            dice = CompoundDice(lhs: DiceModifier(leftNumber), rhs: modifier!, mathOperator: mathOperator)
        }
    }
    return dice
}

/// Creates a Dice instance from a string formatted as "<times>d<sides>[<mathOperator><modifier>|<dropping>]*".
/// Supported dice sides are 4, 6, 8, 10, 12, 20 and %. Times and modifier are optional.
/// Dropping (-L for lowest, -H for highest) is optional, and must go last in the string.
/// Examples include: "d8", "2d12+2", "4d6-L", "1", "2d4+3d12-4".
/// Returns nil if the string could not be interpreted, for example, if there are extraneous
/// characters or an unsupported dice number such as d7 is specified.
public func dice(from string: String) -> Dice? {
    var dice: Dice?
    
    // The most common case is a string with a "d" for dice.
    if let dRange = string.range(of: "d") {
        // If "d" doesn't start at the beginning, interpret the prefix before "d" as number of times.
        let times = string.parseDiceTimes(before: dRange) ?? 1
        
        // If there is a "-L" or "-H" suffix, interpret the suffix as dropping.
        var (dropping, endIndex) = string.parseDiceDropping()
        
        // If not dropping, try a math operator.
        var operand: Dice?
        var mathOperator: String = "+"
        if dropping == nil {
            (operand, mathOperator, endIndex) = string.parseDiceMath()
        }
        
        // Interpret the dice number after the "d" and before the math operator, if supplied.
        let diceRange = dRange.upperBound..<endIndex
        guard let sides = string.parseDiceSides(in: diceRange) else { return nil }
        guard let die = Die(rawValue: sides) else { return nil }
        if operand == nil {
            if dropping == nil {
                dice = SimpleDice(die, times: times)
            } else {
                dice = DroppingDice(die, times: times, dropping: dropping!)
            }
        } else {
            dice = CompoundDice(lhs: SimpleDice(die, times: times), rhs: operand!, mathOperator: mathOperator)
        }
    } else {
        dice = modifier(from: string)
    }
    
    return dice
}
