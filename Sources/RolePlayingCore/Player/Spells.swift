//
//  Spells.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 8/9/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// A collection of spells, indexed by name.
public struct Spells: Sendable {
    private var allSpells: [String: Spell] = [:]
    
    /// All spells in the collection (unordered).
    public var all: [Spell] { Array(allSpells.values) }
    
    public init(_ spells: [Spell] = []) {
        add(spells)
    }
    
    mutating func add(_ spells: [Spell]) {
        let mapped = Dictionary(spells.map { ($0.name, $0) }, uniquingKeysWith: { _, last in last })
        allSpells.merge(mapped, uniquingKeysWith: { _, last in last })
    }
    
    /// Accesses a spell by name.
    public subscript(name: String) -> Spell? {
        allSpells[name]
    }
    
    /// Returns the number of spells in the collection.
    public var count: Int { allSpells.count }
    
    /// Returns all spells of the given level, sorted by name.
    public func spells(ofLevel level: Int) -> [Spell] {
        all.filter { $0.level == level }.sorted { $0.name < $1.name }
    }
}

extension Spells: Codable {

    private enum CodingKeys: String, CodingKey {
        case spells
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let spells = try container.decode([Spell].self, forKey: .spells)
        add(spells)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(all, forKey: .spells)
    }
}
