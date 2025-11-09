//
//  Skill.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/26/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

/// A skill proficiency associated with an ability.
public struct Skill {
    public let name: String
    public let ability: Ability
}

extension Skill: Codable { }

extension Skill: Hashable { }

/// A collection of skills.
public struct Skills: Codable {
    
    /// A dictionary of skills indexed by name.
    private var allSkills: [String: Skill] = [:]
    
    /// An array of skills.
    public var all: [Skill] { Array(allSkills.values) }
    
    /// Returns a skills instance that can access a skill by name.
    public init(_ skills: [Skill] = []) {
        add(skills)
    }
    
    /// Adds the array of skills to the collection.
    mutating func add(_ skills: [Skill]) {
        let mappedSkills = Dictionary(skills.map { ($0.name, $0) }, uniquingKeysWith: { _, last in last })
        allSkills.merge(mappedSkills, uniquingKeysWith: { _, last in last })
    }

    /// Accesses a skill by name.
    public subscript(skillName: String) -> Skill? {
        return allSkills[skillName]
    }
    
    /// Returns the number of skills in the collection.
    public var count: Int { return allSkills.count }
    
    /// Accesses a skill by index.
    public subscript(index: Int) -> Skill? {
        return all[index]
    }
    
    // MARK: Codable conformance
    
    private enum CodingKeys: String, CodingKey {
        case skills
    }
 
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let skills = try container.decode([Skill].self, forKey: .skills)
        add(skills)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(all, forKey: .skills)
    }
}

extension Sequence where Element == String {
    
    /// Returns an array of skills from this array of skill names, using the specified skills collection.
    public func skills(from skills: Skills) throws -> [Skill] {
        try self.map { skillName in
            guard let skill = skills[skillName] else {
                throw missingTypeError("skill", skillName)
            }
            return skill
        }
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
    
    /// Returns an array of skill names corresponding to this array of skills.
    public var skillNames: [String] { self.map(\.name) }
    
    /// Appends an array of skills to this array of skills.
    public mutating func append(_ other: Self) {
        let selfSet = Set(self)
        let otherSet = Set(other)
        self = Array(selfSet.union(otherSet)) as! Self
    }
}
