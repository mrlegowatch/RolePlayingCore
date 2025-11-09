//
//  CreatureType.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 11/8/25.
//

public struct CreatureType: Sendable {
    public let name: String
    public let isDefault: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case isDefault = "is default"
    }
    
    init(_ name: String, isDefault: Bool? = nil) {
        self.name = name
        self.isDefault = isDefault
    }
}

extension CreatureType: Codable { }

extension CreatureType: Hashable { }

public struct CreatureTypes: Codable, Sendable {
    
    private var allCreatureTypes: [String: CreatureType] = [:]
    
    public var all: [CreatureType] { Array(allCreatureTypes.values) }
    
    public var defaultCreatureType: CreatureType {
        all.first(where: { $0.isDefault != nil && $0.isDefault! })! //?? CreatureType("Humanoid")
    }
    
    public init (_ creatureTypes: [CreatureType] = []) {
        add(creatureTypes)
    }
    
    mutating func add(_ creatureTypes: [CreatureType]) {
        let mappedCreatureTypes = Dictionary(creatureTypes.map { ($0.name, $0) }, uniquingKeysWith: { _, last in last })
        allCreatureTypes.merge(mappedCreatureTypes, uniquingKeysWith: { _, last in last })
    }

    // MARK: Codable conformance
    
    private enum CodingKeys: String, CodingKey {
        case creatureTypes = "creature types"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let creatureTypes = try values.decode([CreatureType].self, forKey: .creatureTypes)
        add(creatureTypes)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(all, forKey: .creatureTypes)
    }
}
