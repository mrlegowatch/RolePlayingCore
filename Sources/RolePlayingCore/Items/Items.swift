//
//  Items.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Foundation

/// A registry of all items, indexed by name and plural name for fast lookup.
///
/// JSON format uses grouped top-level keys so each type decodes directly:
/// ```json
/// {
///   "weapons": [...],
///   "armors": [...],
///   "gear": [...],
///   "tools": [...]
/// }
/// ```
public struct Items: Sendable {
    private var byName: [String: any Item] = [:]
    private var byPlural: [String: any Item] = [:]
    
    public var all: [any Item] { Array(byName.values) }
    public var weapons: [Weapon] { all.compactMap { $0 as? Weapon } }
    public var armors: [Armor] { all.compactMap { $0 as? Armor } }
    public var gear: [Gear] { all.compactMap { $0 as? Gear } }
    public var tools: [Tool] { all.compactMap { $0 as? Tool } }
    
    public var count: Int { byName.count }
    
    public init() { }
    
    public mutating func add(_ item: any Item) {
        byName[item.name] = item
        byPlural[item.plural] = item
    }
    
    public mutating func add(_ items: [any Item]) {
        items.forEach { add($0) }
    }
    
    public mutating func add(_ other: Items) {
        add(other.all)
    }
    
    /// Returns the item matching the given name (exact match first, then plural).
    public subscript(name: String) -> (any Item)? {
        byName[name] ?? byPlural[name]
    }
}

extension Items: CodableWithConfiguration {

    private enum CodingKeys: String, CodingKey {
        case weapons
        case armors
        case gear
        case tools
    }

    public init(from decoder: Decoder, configuration: GameData) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)

        if let weapons = try root.decodeIfPresent([Weapon].self, forKey: .weapons, configuration: configuration) {
            add(weapons)
        }
        if let armors = try root.decodeIfPresent([Armor].self, forKey: .armors, configuration: configuration) {
            add(armors)
        }
        if let gear = try root.decodeIfPresent([Gear].self, forKey: .gear, configuration: configuration) {
            add(gear)
        }
        if let tools = try root.decodeIfPresent([Tool].self, forKey: .tools, configuration: configuration) {
            add(tools)
        }
    }

    public func encode(to encoder: Encoder, configuration: GameData) throws {
        var root = encoder.container(keyedBy: CodingKeys.self)
        
        try root.encode(weapons, forKey: .weapons, configuration: configuration)
        try root.encode(armors, forKey: .armors, configuration: configuration)
        try root.encode(gear, forKey: .gear, configuration: configuration)
        try root.encode(tools, forKey: .tools, configuration: configuration)
    }
}
