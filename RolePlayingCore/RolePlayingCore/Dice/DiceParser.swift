//
//  DiceParser.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/23/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation


// TODO: the initial implementation performed naïve sub-string searches, and was very limited.
// This implementation uses a lightweight tokenizer and parser, and is a lot more robust.
// A smaller implementation might leverage NSRegularExpression, but I'm still learning how to use that.

/// Types of errors handled by this parser.
internal enum DiceParseError: Error, CustomDebugStringConvertible {
    case invalidCharacter(String)
    case invalidDieSides(Int)
    case missingMinus
    case missingSimpleDice
    case missingDieSides
    case missingExpression
    case consecutiveNumbers
    case consecutiveMathOperators
    case consecutiveDiceExpressions
    
    var debugDescription: String {
        return "Error parsing dice: \(self)"
    }
}

/// Types of tokens supported by this parser.
internal enum Token {
    case number(Int)
    case mathOperator(String)
    case die
    case drop(String)
    
    static let mathOperatorCharacters = CharacterSet(charactersIn: CompoundDice.mathOperators.keys.reduce("", +))
    static let dieCharacters = CharacterSet(charactersIn: "dD")
    static let dropCharacters = CharacterSet(charactersIn: DroppingDice.Drop.allValues.map({ $0.rawValue }).reduce("", +))
    static let percentCharacters = CharacterSet(charactersIn: "%")
    
    init?(from scalar: UnicodeScalar) {
        if Token.mathOperatorCharacters.contains(scalar) {
            self = .mathOperator(String(scalar))
        } else if Token.dieCharacters.contains(scalar) {
            self = .die
        } else if Token.dropCharacters.contains(scalar) {
            self = .drop(String(scalar))
        } else if Token.percentCharacters.contains(scalar) {
            self = .number(100)
        } else {
            return nil
        }
    }
    
    var isDropping: Bool {
        // TODO: is this the most compact way to compare an enum?
        guard case .drop(_) = self else { return false }
        return true
    }
}

/// An internal buffer for parsing numbers from a string.
private struct NumberBuffer {
    private var buffer: String = ""
    
    mutating func append(_ scalar: UnicodeScalar) {
        buffer.append(Character(scalar))
    }
    
    mutating func flush() -> Int? {
        guard !buffer.isEmpty else { return nil }
        defer { buffer = "" }
        return Int(buffer)
    }
    
    mutating func reset() {
        buffer = ""
    }
}

/// Converts a dice-formatted string into a sequence of tokens.
/// If an unknown character is encountered, an empty array is returned.
internal func tokenize(_ string: String) throws -> [Token] {
    var tokens = [Token]()
    var numberBuffer = NumberBuffer()
    
    for scalar in string.unicodeScalars {
        // Numbers consume multiple characters
        if CharacterSet.decimalDigits.contains(scalar) {
            numberBuffer.append(scalar)
        } else {
            // Flush the current number before parsing the next character
            if let value = numberBuffer.flush() {
                tokens.append(.number(value))
            }
            
            // Skip spaces and newlines
            if CharacterSet.whitespacesAndNewlines.contains(scalar) {
                continue
            }
            
            if let token = Token(from: scalar) {
                tokens.append(token)
            } else {
                throw DiceParseError.invalidCharacter(String(scalar))
            }
        }
    }
    
    if let value = numberBuffer.flush() {
        tokens.append(.number(value))
    }
    
    return tokens
}

/// Look-ahead at the next token and return whether it's `.drop`.
private func isDropping(_ tokens: [Token], after index: Int) -> Bool {
    guard index + 1 < tokens.count else { return false }
    let nextToken = tokens[index + 1]
    return nextToken.isDropping
}

/// The internal state of the parser when it processes tokens.
private struct DiceParserState {
    var lastNumber: Int? = nil
    var lastDice: Dice? = nil
    var lastMathOperator: String? = nil
    var isParsingDie = false
    
    /// Parses a number and stores it either in lastDice sides or lastNumber
    mutating func parse(number: Int) throws {
        if isParsingDie {
            guard lastDice == nil else { throw DiceParseError.consecutiveDiceExpressions }
            guard let die = Die(rawValue: number) else { throw DiceParseError.invalidDieSides(number) }
            let times = lastNumber ?? 1
            lastDice = SimpleDice(die, times: times)
            isParsingDie = false
            lastNumber = nil
        } else {
            guard lastNumber == nil else { throw DiceParseError.consecutiveNumbers }
            lastNumber = number
        }
    }
    
    /// Initiates parsing a die expression; finishes when parsing dice sides as an integer.
    mutating func parseDie() throws {
        guard !isParsingDie else { throw DiceParseError.consecutiveDiceExpressions }
        isParsingDie = true
    }
    
    /// Parses a dropping dice supported by DroppingDice. 
    /// Must be preceded by a SimpleDice and a '-' math operator.
    mutating func parse(drop: String) throws {
        guard let simpleDice = lastDice as? SimpleDice else { throw DiceParseError.missingSimpleDice }
        guard lastMathOperator == "-" else { throw DiceParseError.missingMinus }
        
        let diceDrop = DroppingDice.Drop(rawValue: drop)!
        lastDice = DroppingDice(simpleDice, drop: diceDrop)
        lastMathOperator = nil
    }
    
    /// Parses a math operator supported by CompoundDice.
    mutating func parse(math: String) throws {
        guard lastMathOperator == nil else { throw DiceParseError.consecutiveMathOperators }
        lastMathOperator = math
    }
    
    // Returns a Dice from either the last number (DiceModifier) or lastDice, and resets their state.
    mutating func flush() -> Dice? {
        let returnDice: Dice?
        
        if let number = lastNumber {
            returnDice = DiceModifier(number)
            lastNumber = nil
        } else if let dice = lastDice {
            returnDice = dice
            lastDice = nil
        } else {
            returnDice = nil
        }
        
        return returnDice
    }
    
    /// Returns combined dice from the current parsed dice passed in as lhs,
    /// and the current parse state as rhs. 
    ///
    /// If there is no current parsed dice, the current parse state is returned. 
    /// If there is no math operator or no rhs, lhs is returned.
    mutating func combine(_ lhsDice: Dice?) -> Dice? {
        guard let lhsDice = lhsDice else { return flush() }
        guard let mathOperator = lastMathOperator, let rhsDice = flush() else { return lhsDice }
        
        // If we have a left hand side, a math operator and a right hand side, combine them.
        let returnDice = CompoundDice(lhs: lhsDice, rhs: rhsDice, mathOperator: mathOperator)
        lastMathOperator = nil
        
        return returnDice
    }
    
    // Checks for invalid or incomplete state at the end of parsing.
    func finishParsing() throws {
        if isParsingDie {
            throw DiceParseError.missingDieSides
        } else if lastMathOperator != nil {
            throw DiceParseError.missingExpression
        }
    }
}

/// Converts an array of tokens into Dice.
internal func parse(_ tokens: [Token]) throws -> Dice? {
    var parsedDice: Dice? = nil
    
    var state = DiceParserState()
    for (index, token) in tokens.enumerated() {
        switch token {
        case .number(let value):
            try state.parse(number: value)
        case .die:
            try state.parseDie()
        case .drop(let drop):
            try state.parse(drop: drop)
        case .mathOperator(let math):
            if !isDropping(tokens, after: index) {
                parsedDice = state.combine(parsedDice)
            }
            try state.parse(math: math)
        }
    }
    parsedDice = state.combine(parsedDice)
    try state.finishParsing()
    
    return parsedDice
}

public extension String {
    
    /// Creates a Dice instance from a string formatted as:
    /// > `[<times>]d<sides>[<mathOperator><modifier>|-<dropping>]*`
    /// - Supported dice sides are 4, 6, 8, 10, 12, 20 and %.
    /// - times, modifier and dropping (-L for lowest, -H for highest) are optional.
    ///
    /// - parameter from: A string, for example: "d8", "2d12+2", "4d6-L", "1", "2d4+3d12-4".
    /// - returns: Dice representing the parsed string. Returns `nil` if the string
    ///   could not be interpreted; for example, if there are extraneous
    ///   characters, or an unsupported dice such as d7 is specified.
    public var parseDice: Dice? {
        var dice: Dice? = nil
        
        do {
            let tokens = try tokenize(self)
            dice = try parse(tokens)
        }
        catch let error {
            print("Error parsing dice: \(error.localizedDescription)")
        }
        
        return dice
    }
    
}

// TODO: this works around the fact that we can't explicitly make the Dice protocol Decodable.
// We first decode to String or Int, then create a derived Dice type from those.
//
// Containers can still match to the type (note Dice.protocol in the function declarations).
public extension KeyedDecodingContainer  {
    
    /// Decodes either an integer or a formatted string into a Dice.
    /// See `String.parseDice` for supported string formats.
    ///
    /// - throws `DecodingError.dataCorrupted` if the dice is not present or could not be decoded.
    public func decode(_ type: Dice.Protocol, forKey key: K) throws -> Dice {
        let dice: Dice?
        
        if let number = try? self.decode(Int.self, forKey: key) {
            dice = DiceModifier(number)
        } else {
            dice = try self.decode(String.self, forKey: key).parseDice
        }
        
        // Throw if we were unsuccessful parsing.
        guard dice != nil else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Missing string or number for Dice value")
            throw DecodingError.dataCorrupted(context)
        }
        
        return dice!
    }
    
    /// Decodes either an integer or a formatted string into a Dice, if present.
    /// See `String.parseDice` for supported string formats.
    ///
    /// - throws `DecodingError.dataCorrupted` if the dice could not be decoded.
    public func decodeIfPresent(_ type: Dice.Protocol, forKey key: K) throws -> Dice? {
        let dice: Dice?
        
        if let number = try? self.decode(Int.self, forKey: key) {
            dice = DiceModifier(number)
        } else if let string = try self.decodeIfPresent(String.self, forKey: key) {
            dice = string.parseDice
        } else {
            dice = nil
        }
        
        return dice
    }
    
}
