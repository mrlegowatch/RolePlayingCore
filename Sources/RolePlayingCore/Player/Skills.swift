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
    
    public var skills = [Skill]()
    
    private enum CodingKeys: String, CodingKey {
        case skills
    }
    
    public func find(_ skillName: String?) -> Skill? {
        return skills.first(where: { $0.name == skillName })
    }
    
    public var count: Int { return skills.count }
    
    public subscript(index: Int) -> Skill? {
        get {
            return skills[index]
        }
    }
}

extension Sequence where Element == String {
    
    /// Returns an array of skills from this array of skill names, using the skills argument.
    public func skills(from skills: Skills) throws -> [Skill] {
        try self.map { skillName in
            guard let skill = skills.find(skillName) else {
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
    
    public var skillNames: [String] { self.map(\.name) }
    
    public mutating func append(_ other: Self) {
        let selfSet = Set(self)
        let otherSet = Set(other)
        self = Array(selfSet.union(otherSet)) as! Self
    }
}
