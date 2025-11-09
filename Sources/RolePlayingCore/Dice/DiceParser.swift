//
//  DiceParser.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/23/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

import Foundation

// MARK: - Parse Errors

/// Types of errors handled by this parser.
enum DiceParseError: Error, LocalizedError {
    case invalidCharacter(String)
    case invalidDieSides(Int)
    case missingMinus
    case missingSimpleDice
    case missingDieSides
    case missingExpression
    case consecutiveNumbers
    case consecutiveMathOperators
    case consecutiveDiceExpressions
    
    var errorDescription: String? {
        switch self {
        case .invalidCharacter(let char):
            return "Invalid character '\(char)' in dice expression"
        case .invalidDieSides(let sides):
            return "Invalid die with \(sides) sides"
        case .missingMinus:
            return "Drop modifier requires '-' operator"
        case .missingSimpleDice:
            return "Drop modifier can only be applied to simple dice"
        case .missingDieSides:
            return "Die specification missing number of sides"
        case .missingExpression:
            return "Math operator missing right-hand expression"
        case .consecutiveNumbers:
            return "Cannot have consecutive numbers without an operator"
        case .consecutiveMathOperators:
            return "Cannot have consecutive math operators"
        case .consecutiveDiceExpressions:
            return "Cannot have consecutive dice expressions without an operator"
        }
    }
}

// MARK: - Token


/// Types of tokens supported by this parser.
enum Token {
    case number(Int)
    case mathOperator(String)
    case die
    case drop(String)
    
    // MARK: Character Sets
    
    private static let mathOperatorCharacters = CharacterSet(charactersIn: "+-x*/")
    private static let dieCharacters = CharacterSet(charactersIn: "dD")
    private static let dropCharacters = CharacterSet(
        charactersIn: DroppingDice.Drop.allCases.map(\.rawValue).joined()
    )
    private static let percentCharacters = CharacterSet(charactersIn: "%")
    
    // MARK: Initialization
    
    init?(from scalar: UnicodeScalar) {
        switch scalar {
        case _ where Self.mathOperatorCharacters.contains(scalar):
            self = .mathOperator(String(scalar))
        case _ where Self.dieCharacters.contains(scalar):
            self = .die
        case _ where Self.dropCharacters.contains(scalar):
            self = .drop(String(scalar))
        case _ where Self.percentCharacters.contains(scalar):
            self = .number(100)
        default:
            return nil
        }
    }
    
    // MARK: Properties
    
    var isDropping: Bool {
        if case .drop = self { return true }
        return false
    }
}

// MARK: - Number Buffer

/// An internal buffer for parsing numbers from a string.
private struct NumberBuffer {
    private var buffer = ""
    
    var isEmpty: Bool { buffer.isEmpty }
    
    mutating func append(_ scalar: UnicodeScalar) {
        buffer.append(String(scalar))
    }
    
    mutating func flush() -> Int? {
        guard !buffer.isEmpty else { return nil }
        defer { buffer = "" }
        return Int(buffer)
    }
}

// MARK: - Tokenizer

/// Converts a dice-formatted string into a sequence of tokens.
/// 
/// - Parameter string: The string to tokenize (e.g., "2d6+3")
/// - Returns: An array of tokens representing the parsed string
/// - Throws: `DiceParseError.invalidCharacter` if an unknown character is encountered
func tokenize(_ string: String) throws -> [Token] {
    var tokens: [Token] = []
    var numberBuffer = NumberBuffer()
    
    for scalar in string.unicodeScalars {
        if CharacterSet.decimalDigits.contains(scalar) {
            // Numbers consume multiple characters
            numberBuffer.append(scalar)
        } else {
            // Flush any accumulated number before processing the next character
            if let value = numberBuffer.flush() {
                tokens.append(.number(value))
            }
            
            // Skip whitespace
            guard !CharacterSet.whitespacesAndNewlines.contains(scalar) else { continue }
            
            // Parse token or throw error for invalid characters
            guard let token = Token(from: scalar) else {
                throw DiceParseError.invalidCharacter(String(scalar))
            }
            
            tokens.append(token)
        }
    }
    
    // Flush any remaining number
    if let value = numberBuffer.flush() {
        tokens.append(.number(value))
    }
    
    return tokens
}

// MARK: - Parser State

/// The internal state of the parser when it processes tokens.
private struct DiceParserState {
    private(set) var lastNumber: Int?
    private(set) var lastDice: Dice?
    private(set) var lastMathOperator: String?
    private(set) var isParsingDie = false
    
    // MARK: Parsing Methods
    
    /// Parses a number and stores it either in `lastDice.sides` or `lastNumber`.
    ///
    /// - Parameter number: The number value to parse
    /// - Throws: `DiceParseError` if consecutive numbers or dice expressions are encountered
    mutating func parse(number: Int) throws {
        if isParsingDie {
            guard lastDice == nil else {
                throw DiceParseError.consecutiveDiceExpressions
            }
            guard let die = Die(rawValue: number) else {
                throw DiceParseError.invalidDieSides(number)
            }
            
            let times = lastNumber ?? 1
            lastDice = SimpleDice(die, times: times)
            isParsingDie = false
            lastNumber = nil
        } else {
            guard lastNumber == nil else {
                throw DiceParseError.consecutiveNumbers
            }
            lastNumber = number
        }
    }
    
    /// Initiates parsing a die expression.
    /// The die is completed when parsing dice sides as an integer.
    ///
    /// - Throws: `DiceParseError.consecutiveDiceExpressions` if already parsing a die
    mutating func parseDie() throws {
        guard !isParsingDie else {
            throw DiceParseError.consecutiveDiceExpressions
        }
        isParsingDie = true
    }
    
    /// Parses a dropping dice modifier supported by `DroppingDice`.
    /// Must be preceded by a `SimpleDice` and a '-' math operator.
    ///
    /// - Parameter drop: The drop modifier string ("L" or "H")
    /// - Throws: `DiceParseError` if preconditions are not met
    mutating func parse(drop: String) throws {
        guard let simpleDice = lastDice as? SimpleDice else {
            throw DiceParseError.missingSimpleDice
        }
        guard lastMathOperator == "-" else {
            throw DiceParseError.missingMinus
        }
        
        let diceDrop = DroppingDice.Drop(rawValue: drop)!
        lastDice = DroppingDice(simpleDice, drop: diceDrop)
        lastMathOperator = nil
    }
    
    /// Parses a math operator supported by `CompoundDice`.
    ///
    /// - Parameter math: The math operator string
    /// - Throws: `DiceParseError.consecutiveMathOperators` if another operator is pending
    mutating func parse(math: String) throws {
        guard lastMathOperator == nil else {
            throw DiceParseError.consecutiveMathOperators
        }
        lastMathOperator = math
    }
    
    /// Returns a `Dice` from either the last number (`DiceModifier`) or `lastDice`,
    /// and resets their state.
    ///
    /// - Returns: A `Dice` instance or `nil` if no pending dice exist
    mutating func flush() -> Dice? {
        if let number = lastNumber {
            lastNumber = nil
            return DiceModifier(number)
        } else if let dice = lastDice {
            lastDice = nil
            return dice
        }
        return nil
    }
    
    /// Returns combined dice from the current parsed dice and the current parse state.
    ///
    /// If there is no current parsed dice, the current parse state is returned.
    /// If there is no math operator or no right-hand side, the left-hand side is returned.
    ///
    /// - Parameter lhsDice: The left-hand side dice to combine with current state
    /// - Returns: The combined dice or the original dice if no combination is possible
    mutating func combine(_ lhsDice: Dice?) -> Dice? {
        guard let lhsDice else { return flush() }
        guard let mathOperator = lastMathOperator, let rhsDice = flush() else {
            return lhsDice
        }
        
        // Combine left-hand side, math operator, and right-hand side
        lastMathOperator = nil
        return CompoundDice(lhs: lhsDice, rhs: rhsDice, mathOperator: mathOperator)
    }
    
    /// Checks for invalid or incomplete state at the end of parsing.
    ///
    /// - Throws: `DiceParseError` if the parser is in an incomplete state
    func validate() throws {
        if isParsingDie {
            throw DiceParseError.missingDieSides
        } else if lastMathOperator != nil {
            throw DiceParseError.missingExpression
        }
    }
}

// MARK: - Parser

/// Look-ahead at the next token and return whether it's a `.drop` token.
private func isNextTokenDropping(_ tokens: [Token], after index: Int) -> Bool {
    guard index + 1 < tokens.count else { return false }
    return tokens[index + 1].isDropping
}

/// Converts an array of tokens into a `Dice` object.
///
/// - Parameter tokens: The tokens to parse
/// - Returns: A `Dice` instance representing the parsed expression, or `nil` if empty
/// - Throws: `DiceParseError` if the token sequence is invalid
func parse(_ tokens: [Token]) throws -> Dice? {
    var parsedDice: Dice?
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
            // Only combine if the next token isn't a drop modifier
            if !isNextTokenDropping(tokens, after: index) {
                parsedDice = state.combine(parsedDice)
            }
            try state.parse(math: math)
        }
    }
    
    parsedDice = state.combine(parsedDice)
    try state.validate()
    
    return parsedDice
}

// MARK: - String Extension

public extension String {
    
    /// Creates a `Dice` instance from a dice notation string.
    ///
    /// Supported format: `[<times>]d<sides>[<mathOperator><modifier>|-<dropping>]*`
    ///
    /// Examples:
    /// - `"d8"` → Simple 8-sided die
    /// - `"2d12+2"` → Two 12-sided dice plus 2
    /// - `"4d6-L"` → Four 6-sided dice, drop lowest
    /// - `"1"` → Constant modifier of 1
    /// - `"2d4+3d12-4"` → Compound expression
    ///
    /// Supported dice sides: 4, 6, 8, 10, 12, 20, and % (100)
    ///
    /// - Returns: A `Dice` instance, or `nil` if the string cannot be parsed
    var parseDice: Dice? {
        do {
            let tokens = try tokenize(self)
            return try parse(tokens)
        } catch {
            print("Error parsing dice: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Decoding Extensions

public extension KeyedDecodingContainer {
    
    /// Decodes either an integer or a dice notation string into a `Dice`.
    ///
    /// - Parameters:
    ///   - type: The `Dice.Protocol` metatype
    ///   - key: The coding key for the value
    /// - Returns: A decoded `Dice` instance
    /// - Throws: `DecodingError.dataCorrupted` if the value cannot be decoded as dice
    func decode(_ type: Dice.Protocol, forKey key: K) throws -> Dice {
        // Try decoding as an integer first (for constant modifiers)
        if let number = try? decode(Int.self, forKey: key) {
            return DiceModifier(number)
        }
        
        // Try decoding as a string and parsing as dice notation
        if let string = try? decode(String.self, forKey: key),
           let dice = string.parseDice {
            return dice
        }
        
        // Throw if neither approach succeeded
        let context = DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "Could not decode Dice from string or number"
        )
        throw DecodingError.dataCorrupted(context)
    }
    
    /// Decodes either an integer or a dice notation string into a `Dice`, if present.
    ///
    /// - Parameters:
    ///   - type: The `Dice.Protocol` metatype
    ///   - key: The coding key for the value
    /// - Returns: A decoded `Dice` instance, or `nil` if the key is not present
    /// - Throws: `DecodingError.dataCorrupted` if the value is present but cannot be decoded
    func decodeIfPresent(_ type: Dice.Protocol, forKey key: K) throws -> Dice? {
        // Return nil if the key doesn't exist
        guard contains(key) else { return nil }
        
        // Try decoding as an integer first
        if let number = try? decode(Int.self, forKey: key) {
            return DiceModifier(number)
        }
        
        // Try decoding as a string and parsing as dice notation
        if let string = try? decode(String.self, forKey: key) {
            return string.parseDice
        }
        
        return nil
    }
}

