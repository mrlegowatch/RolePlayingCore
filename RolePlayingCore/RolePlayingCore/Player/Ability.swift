//
//  Ability.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/11/16.
//  Copyright © 2016-2017 Brian Arnold. All rights reserved.
//

extension String {
    
    /// Returns up to the first three characters of this string uppercased.
    public var abbreviated: String {
        let index = self.index(self.startIndex, offsetBy: min(self.characters.count, 3))
        return self.substring(to: index).uppercased()
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

/// An ability name.
public struct Ability {
    
    /// The raw name for the ability.
    public let name: String
    
    /// Creates an ability name.
    public init(_ name: String) {
        self.name = name
    }
    
    /// Returns the abbreviation of this ability name.
    public var abbreviated: String {
        return name.abbreviated
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

extension Ability {
    
    /// A mapping of abilities to scores.
    public struct Scores {
        
        /// The raw mapping of abilities to scores.
        internal var rawValue: [Ability: Int]
        
        /// Returns the number of scores.
        public var count: Int { return rawValue.count }
        
        /// Returns the attributes of the scores as a lazy map collection.
        public var abilities: LazyMapCollection<Dictionary<Ability, Int>, Ability> { return rawValue.keys }
        
        /// Returns the values of the scores as a lazy map collection.
        public var values: LazyMapCollection<Dictionary<Ability, Int>, Int> { return rawValue.values }

        /// Creates scores with specified values.
        public init(values: [Ability: Int]) {
            self.rawValue = values
        }
        
        /// For each named dictionary trait, sets the corresponding score.
        public init(from traits: [String: Int]) {
            rawValue = Dictionary<Ability, Int>(minimumCapacity: traits.count)
            for (key, value) in traits {
                let ability = Ability(key)
                rawValue[ability] = value
            }
        }
        
        /// Accesses a score by its corresponding ability.
        ///
        /// Returns nil if the ability isn't present in the scores.
        /// The score will not be set if the value is nil, or if the ability is not already present.
        public subscript(ability: Ability) -> Int? {
            get {
                return rawValue[ability]
            }
            set {
                guard let newValue = newValue else { return } // value must be non-nil
                guard let _ = rawValue[ability] else { return } // key must already be present
                rawValue[ability] = newValue
            }
        }
        
        /// Returns the ability modifiers for the scores.
        public var modifiers: Scores {
            var modifierValues = rawValue
            for (key, value) in rawValue {
                modifierValues[key] = value.scoreModifier
            }
            return Scores(values: modifierValues)
        }
        
    }
    
}

extension Ability.Scores: Equatable {
    
    /// Returns whether the two scores match both abilities and values.
    static public func==(rhs: Ability.Scores, lhs: Ability.Scores) -> Bool {
        return rhs.rawValue == lhs.rawValue
    }
    
}

/// Adds two sets of ability scores. 
///
/// The rhs may contain a subset of attributes from lhs.
/// Only abilities already present in lhs will be added from rhs; the rest will be ignored.
public func+(lhs: Ability.Scores, rhs: Ability.Scores) -> Ability.Scores {
    var result = lhs
    for (key, value) in rhs.rawValue {
        result[key]? += value
    }
    return result
}

// MARK: Default abilities

extension Ability {
    
    /// Physical strength, e.g., body, might, brawn.
    public static let strength = Ability("Strength")
    
    /// Agility, e.g., reflexes, quickness.
    public static let dexterity = Ability("Dexterity")
    
    /// Sturdiness, e.g., stamina, endurance, vitality.
    public static let constitution = Ability("Constitution")
    
    /// Problem-solving ability, e.g., intellect, mind, knowledge.
    public static let intelligence = Ability("Intelligence")
    
    /// Common sense and/or spirituality, e.g., spirit, wits, psyche, sense.
    public static let wisdom = Ability("Wisdom")
    
    /// Social skills, e.g., presence, charm. Sometimes also physical appearance.
    public static let charisma = Ability("Charisma")
    
    /// An array of the default abilities.
    public static let defaults: [Ability] = [.strength, .dexterity, .constitution, .intelligence, .wisdom, .charisma]
    
}

extension Ability.Scores {
    
    /// Creates a set of default ability scores with values initialized to 0.
    public init(defaults: [Ability] = Ability.defaults) {
        rawValue = Dictionary<Ability, Int>(minimumCapacity: defaults.count)
        for ability in defaults {
            rawValue[ability] = 0
        }
    }
}
