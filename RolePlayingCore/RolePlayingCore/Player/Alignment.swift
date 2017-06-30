//
//  Alignment.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/11/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

/// A measure of order, obedience, and following rules vs. disorder, and disobedience.
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

extension String {
    
    /// Parses a string for alignment (ethics and morals) substrings.
    /// Interprets true "Neutral", and ethics or morals with a neutral counterpart.
    public var parseAlignment: (Ethics, Morals)? {
        let words = self.components(separatedBy: " ")
        switch words.count {
        case 1:
            let word = words[0]
            if let ethics = Ethics(rawValue: word) {
                return (ethics, .neutral)
            } else if let morals = Morals(rawValue: word) {
                return (.neutral, morals)
            } else {
                return nil
            }
        case 2:
            guard let ethics = Ethics(rawValue: words[0]),
                let morals = Morals(rawValue: words[1]) else { return nil }
            return (ethics, morals)
        default:
            return nil
        }
    }
    
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

extension Ethics: Codable { }

extension Morals: Codable { }

extension Alignment: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        case ethics
        case morals
    }
    
    /// Creates an alignment
    public init(from decoder: Decoder) throws {
        // If the value can be decoded is a string, try to parse it for "<ethics> <morals>".
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            guard let (ethics, morals) = string.parseAlignment else {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Missing alignment string values")
                throw DecodingError.dataCorrupted(context)
            }
            self.init(ethics, morals)
        } else {
            // The value must decode into either two doubles or two strings with the coding keys.
            let values = try decoder.container(keyedBy: CodingKeys.self)
            if let ethicsValue = try? values.decodeIfPresent(Double.self, forKey: .ethics),
                let moralsValue = try? values.decodeIfPresent(Double.self, forKey: .morals),
                ethicsValue != nil && moralsValue != nil {
                self.init(ethics: ethicsValue!, morals: moralsValue!)
            } else {
                let ethics = try values.decode(Ethics.self, forKey: .ethics)
                let morals = try values.decode(Morals.self, forKey: .morals)
                self.init(ethics, morals)
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        // TODO: allow for encoding as either enums or doubles.
        var container = encoder.singleValueContainer()
        try container.encode("\(self)")
    }

}
