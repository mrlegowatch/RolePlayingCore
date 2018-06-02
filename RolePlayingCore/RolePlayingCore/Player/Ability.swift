//
//  Ability.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/11/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

public struct Ability {
    
    public let name: String
    
    /// Creates an ability name.
    public init(_ name: String) {
        self.name = name
    }
    
}

extension Ability: Equatable {
    
    public static func==(lhs: Ability, rhs: Ability) -> Bool {
        return lhs.name == rhs.name
    }
    
}

extension Ability: Hashable {
    
    public var hashValue: Int {
        return name.hashValue
    }
    
}

extension String {
    
    /// Returns up to the first three characters of this string uppercased.
    public var abbreviated: String {
        let index = self.index(self.startIndex, offsetBy: min(self.count, 3))
        return self[..<index].uppercased()
    }
    
}

extension Ability {
    
    /// Returns the abbreviation of this ability name.
    public var abbreviated: String {
        return name.abbreviated
    }
    
}

extension Ability: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        name = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

public struct AbilityScores {
    
    var scores: [Ability: Int]
    
    public init(_ scores: [Ability: Int]) {
        self.scores = scores
    }
    
    /// Returns the number of scores.
    public var count: Int { return scores.count }
    
    /// Returns the attributes of the scores as a lazy map collection.
    public var abilities: Dictionary<Ability, Int>.Keys { return scores.keys }
    
    /// Returns the values of the scores as a lazy map collection.
    public var values: Dictionary<Ability, Int>.Values { return scores.values }
    
    /// Accesses a score by its corresponding ability.
    ///
    /// Returns nil if the ability isn't present in the scores.
    /// The score will not be set if the value is nil, or if the ability is not already present.
    public subscript(ability: Ability) -> Int? {
        get {
            return scores[ability]
        }
        set {
            guard let newValue = newValue else { return } // value must be non-nil
            guard let _ = scores[ability] else { return } // key must already be present
            scores[ability] = newValue
        }
    }
    
}

extension AbilityScores: Codable {
    
    struct AbilityKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AbilityKey.self)
        let allKeys = container.allKeys
        
        var scores = [Ability: Int](minimumCapacity: allKeys.count)
        for key in allKeys {
            let abilityKey = Ability(key.stringValue)
            let score = try container.decode(Int.self, forKey: key)
            scores[abilityKey] = score
        }
        
        self.init(scores)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AbilityKey.self)
        
        for score in scores {
            let nameKey = AbilityKey(stringValue: score.key.name)!
            try container.encode(score.value, forKey: nameKey)
        }
    }
}

extension Int {
    
    /// Returns the corresponding score modifier for this integer score.
    public var scoreModifier: Int {
        /// Integer divide of negative number rounds towards 0. Use floor with Double to round down.
        let selfMinus10 = self - 10
        return selfMinus10 < 0 ? Int(floor(Double(selfMinus10) / 2.0)) : selfMinus10 / 2
    }
    
}

extension AbilityScores {
    
    /// Returns the ability modifiers for the scores.
    public var modifiers: AbilityScores {
        var modifiedScores = scores
        for (key, value) in scores {
            modifiedScores[key] = value.scoreModifier
        }
        return AbilityScores(modifiedScores)
    }
    
}

extension AbilityScores: Equatable {
    
    /// Returns whether the two scores match both abilities and values.
    static public func==(rhs: AbilityScores, lhs: AbilityScores) -> Bool {
        return rhs.scores == lhs.scores
    }
    
}

extension AbilityScores {
    
    /// Adds two sets of ability scores.
    ///
    /// The rhs may contain a subset of attributes from lhs.
    /// Only abilities already present in lhs will be added from rhs; the rest will be ignored.
    public static func+(lhs: AbilityScores, rhs: AbilityScores) -> AbilityScores {
        var result = lhs
        result += rhs
        return result
    }
    
    /// Adds a set of ability scores to self.
    ///
    /// Self may contain a subset of attributes from lhs.
    /// Only abilities already present in self will be added from rhs; the rest will be ignored.
    public static func+=(lhs: inout AbilityScores, rhs: AbilityScores) {
        for (key, value) in rhs.scores {
            lhs[key]? += value
        }
    }
    
    /// Subtracts two sets of ability scores.
    ///
    /// The rhs may contain a subset of attributes from lhs.
    /// Only abilities already present in lhs will be subtracted from rhs; the rest will be ignored.
    public static func-(lhs: AbilityScores, rhs: AbilityScores) -> AbilityScores {
        var result = lhs
        result -= rhs
        return result
    }
    
    /// Subtracts a set of ability scores from self.
    ///
    /// Self may contain a subset of attributes from lhs.
    /// Only abilities already present in self will be subtracted from rhs; the rest will be ignored.
    public static func-=(lhs: inout AbilityScores, rhs: AbilityScores) {
        for (key, value) in rhs.scores {
            lhs[key]? -= value
        }
    }
    
}

// MARK: Default abilities

extension Ability {
    
    /// Physical power, e.g., body, might, brawn.
    public static let strength = Ability("Strength")
    
    /// Agility, e.g., reflexes, quickness.
    public static let dexterity = Ability("Dexterity")
    
    /// Endurance, e.g., stamina, sturdiness, vitality.
    public static let constitution = Ability("Constitution")
    
    /// Reasoning and memory, e.g., intellect, mind, knowledge.
    public static let intelligence = Ability("Intelligence")
    
    /// Perception and insight, e.g., spirit, wits, psyche, sense.
    public static let wisdom = Ability("Wisdom")
    
    /// Personality, e.g., social skills, presence, charm. Sometimes also physical appearance.
    public static let charisma = Ability("Charisma")
    
    /// An array of the default abilities.
    public static let defaults: [Ability] = [.strength, .dexterity, .constitution, .intelligence, .wisdom, .charisma]
    
}

extension AbilityScores {
    
    /// Creates a set of default ability scores with values initialized to 0.
    public init(defaults: [Ability] = Ability.defaults) {
        scores = [Ability: Int](minimumCapacity: defaults.count)
        for ability in defaults {
            scores[ability] = 0
        }
    }
    
}
