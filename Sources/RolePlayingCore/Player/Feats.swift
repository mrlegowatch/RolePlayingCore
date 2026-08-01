//
//  Feats.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/22/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// A collection of feats.
public struct Feats: Codable, Sendable {

    /// A dictionary of feats indexed by name.
    private var allFeats: [String: FeatTraits] = [:]

    /// An array of feats.
    public var all: [FeatTraits] { Array(allFeats.values) }

    /// Returns a feats instance that can access a feat by name.
    public init(_ feats: [FeatTraits] = []) {
        add(feats)
    }

    /// Adds the array of feats to the collection.
    mutating func add(_ feats: [FeatTraits]) {
        let mapped = Dictionary(feats.map { ($0.name, $0) }, uniquingKeysWith: { _, last in last })
        allFeats.merge(mapped, uniquingKeysWith: { _, last in last })
    }

    /// Accesses a feat by name.
    public subscript(name: String) -> FeatTraits? {
        return allFeats[name]
    }

    /// Returns the number of feats in the collection.
    public var count: Int { return allFeats.count }

    // MARK: Codable conformance

    private enum CodingKeys: String, CodingKey {
        case feats
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let feats = try container.decode([FeatTraits].self, forKey: .feats)
        add(feats)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(all, forKey: .feats)
    }
}
