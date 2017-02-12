//
//  Alignment.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/11/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

/// A measure of order, obedience, following rules vs. disorder, disobedience.
public enum Ethics: String {
    
    case lawful = "Lawful"
    case neutral = "Neutral"
    case chaotic = "Chaotic"
    
    /// Creates an enumeration based on a value from -1 to 1 where:
    /// - -1 to -1/3 is chaotic
    /// - -1/3 to 1/3 is neutral
    /// - 1/3 to 1 is lawful
    public init(_ ethics: Double) {
        self = ethics > 1.0/3.0 ? .lawful : ethics < -1.0/3.0 ? .chaotic : .neutral
    }
    
    /// Returns a corresponding value for:
    /// - lawful: 1
    /// - neutral: 0
    /// - chaotic: -1
    public var value: Double {
        return self == .lawful ? 1.0 : self == .chaotic ? -1.0 : 0.0
    }

}

extension Ethics: CustomStringConvertible {
    
    /// Returns the raw string value.
    public var description: String {
        return self.rawValue
    }
    
}

/// A measure of goodness vs. evil.
public enum Morals: String {
    
    case good = "Good"
    case neutral = "Neutral"
    case evil = "Evil"
    
    /// Creates an enumeration based on a value from -1 to 1 where:
    /// - -1 to -1/3 is evil
    /// - -1/3 to 1/3 is neutral
    /// - 1/3 to 1 is good
    public init(_ morals: Double) {
        self = morals > 1.0/3.0 ? .good : morals < -1.0/3.0 ? .evil : .neutral
    }
    
    /// Returns a corresponding value for:
    /// - good: 1
    /// - neutral: 0
    /// - evil: -1
    public var value: Double {
        return self == .good ? 1.0 : self == .evil ? -1.0 : 0.0
    }
    
}

extension Morals: CustomStringConvertible {
    
    /// Returns the raw string value.
    public var description: String {
        return self.rawValue
    }
    
}

extension Trait {
    
    static let ethics = "ethics"
    
    static let morals = "morals"
    
}

/// A combined measure of ethics and morals.
public struct Alignment {

    /// A combination of ethics and morals enumerations.
    public struct Kind {
        
        public let ethics: Ethics
        
        public let morals: Morals
        
        /// Creates an alignment kind based on ethics and morals values ranging from -1 to 1.
        public init(ethics: Double, morals: Double) {
            self.ethics = Ethics(ethics)
            self.morals = Morals(morals)
        }
        
        /// Creates an alignment kind based on ethics and morals enumerations.
        public init(_ ethics: Ethics, _ morals: Morals) {
            self.ethics = ethics
            self.morals = morals
        }
        
    }

    internal let valueRange = -1.0...1.0
    
    /// Accesses the ethics value in the range from -1 to 1.
    public var ethics: Double {
        get {
            return ethicsValue
        }
        set {
            guard valueRange.contains(newValue) else { return }
            ethicsValue = newValue
        }
    }
    
    /// Accesses the morals value in the range from -1 to 1.
    public var morals: Double {
        get {
            return moralsValue
        }
        set {
            guard valueRange.contains(newValue) else { return }
            moralsValue = newValue
        }
    }

    internal var ethicsValue: Double = 0
    
    internal var moralsValue: Double = 0

    /// Returns the alignment type that corresponds to the ethics and morals values.
    public var kind: Kind {
        return Kind(ethics: ethics, morals: morals)
    }
    
    /// Creates an alignment based on ethics and morals enumerations.
    public init(_ ethics: Ethics, _ morals: Morals) {
        self.ethics = ethics.value
        self.morals = morals.value
    }

    /// Creates an alignment based on ethics and morals values in the range from -1 to 1.
    public init(ethics: Double, morals: Double) {
        self.ethics = ethics
        self.morals = morals
    }

    /// Creates an alignment from a string. The string must match an alignment type
    /// description string, otherwise nil is returned.
    public init?(from string: String) {
        let words = string.components(separatedBy: " ")
        guard words.count == 1 || words.count == 2 else { return nil }
        if words.count == 1 && words[0] == "Neutral" {
            self.init(.neutral, .neutral)
        } else {
            guard let ethics = Ethics(rawValue: words[0]), let morals = Morals(rawValue: words[1]) else { return nil }
            self.init(ethics, morals)
       }
    }
    
    /// Creates an alignment from dictionary traits. The dictionary must contain "ethics" and "morals"
    /// keys, and the values must be either Double or strings matching ethics and morals enumerations,
    /// otherwise nil is returned.
    public init?(from traits: [String: Any]) {
        guard let ethicsTrait = traits[Trait.ethics], let moralsTrait = traits[Trait.morals] else { return nil }
        if let ethics = ethicsTrait as? Double, let morals = moralsTrait as? Double {
            self.init(ethics: ethics, morals: morals)
        } else {
            guard let ethicsString = ethicsTrait as? String, let moralsString = moralsTrait as? String else { return nil }
            guard let ethics = Ethics(rawValue: ethicsString), let morals = Morals(rawValue: moralsString) else { return nil }
            self.init(ethics, morals)
        }
    }
    
}

extension Alignment.Kind: CustomStringConvertible {
    
    /// Returns a combined string for ethics and morals, e.g., "Lawful Good", "Chaotic Evil" etc..
    /// Returns "Neutral" if both ethics and morals are neutral.
    public var description: String {
        return ethics == .neutral && morals == .neutral ? "Neutral" : "\(ethics) \(morals)"
    }
    
}

extension Alignment.Kind: Equatable {
    
    /// Compares ethics and morals enumerations and returns whether they are equal.
    public static func==(lhs: Alignment.Kind, rhs: Alignment.Kind) -> Bool {
        return lhs.ethics == rhs.ethics && lhs.morals == rhs.morals
    }
    
}

extension Alignment: CustomStringConvertible {
    
    /// Returns a descriptive string, e.g., "Lawful Neutral", "Neutral Good", etc.
    public var description: String {
        return kind.description
    }
    
}

extension Alignment: Equatable {
    
    /// Returns whether the alignment kinds match; exact ethics and morals values are not compared.
    public static func==(lhs: Alignment, rhs: Alignment) -> Bool {
        return lhs.kind == rhs.kind
    }
    
}
