//
//  Skill.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/26/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

public struct Skill {
    public let name: String
    public let ability: Ability
}

extension Skill: Codable { }

extension Skill: Hashable { }

extension Skill {
    public static let acrobatics = Skill(name: "Acrobatics", ability: .dexterity)
    public static let animalHandling = Skill(name: "Animal Handling", ability: .wisdom)
    public static let arcana = Skill(name: "Arcana", ability: .intelligence)
    public static let athletics = Skill(name: "Athletics", ability: .strength)
    public static let deception = Skill(name: "Deception", ability: .charisma)
    public static let history = Skill(name: "History", ability: .intelligence)
    public static let insight = Skill(name: "Insight", ability: .wisdom)
    public static let intimidation = Skill(name: "Intimidation", ability: .charisma)
    public static let investigation = Skill(name: "Investigation", ability: .intelligence)
    public static let medicine = Skill(name: "Medicine", ability: .wisdom)
    public static let nature = Skill(name: "Nature", ability: .intelligence)
    public static let perception = Skill(name: "Perception", ability: .wisdom)
    public static let performance = Skill(name: "Performance", ability: .charisma)
    public static let persuasion = Skill(name: "Persuasion", ability: .charisma)
    public static let religion = Skill(name: "Religion", ability: .intelligence)
    public static let sleightOfHand = Skill(name: "Sleight of Hand", ability: .dexterity)
    public static let stealth = Skill(name: "Stealth", ability: .dexterity)
    public static let survival = Skill(name: "Survival", ability: .wisdom)
    
    public static var all: [Skill] {
        [
            .acrobatics, .animalHandling, .arcana, .athletics, .deception, .history, .insight, .intimidation, .investigation, .medicine, .nature, .perception, .performance, .persuasion, .religion, .sleightOfHand, .stealth, .survival
        ]
    }
    
    public static func skills(from names: [String]) -> [Skill] {
        // Use the full set of skills if the names are empty.
        guard names.count > 0 else { return all }
        return all.filter { names.contains($0.name) }
    }
}

extension Sequence where Element == Skill {

    /// Returns a random array of skills with the specified skill count.
    public func randomSkills(count: Int) -> [Element] {
        var selected: [Element] = []
        var remaining: [Element] = Array(self)
        
        for _ in 0..<count where !remaining.isEmpty {
            let index = Int.random(in: 0..<remaining.count)
            selected.append(remaining.remove(at: index))
        }
        
        return selected
    }
    
    public var skillNames: [String] { self.map(\.name) }
    
    public mutating func append(_ other: Self) {
        let selfSet = Set(self)
        let otherSet = Set(other)
        self = Array(selfSet.union(otherSet)) as! Self
    }
}
