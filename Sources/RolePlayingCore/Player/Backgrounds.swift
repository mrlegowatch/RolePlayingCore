//
//  Backgrounds.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/26/25.
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import Foundation

/// A collection of backgrounds.
public struct Backgrounds: DisplayOrdered, Sendable {
    /// A dictionary of background traits indexed by name.
    private var allBackgrounds: [String: BackgroundTraits] = [:]
    
    /// An array of background traits.
    public var all: [BackgroundTraits] { Array(allBackgrounds.values) }
    
    /// An array of background traits sorted by name.
    public var allSorted: [BackgroundTraits] { all.sorted { $0.name < $1.name } }
    
    /// The preferred display order for backgrounds; empty means no preference (alphabetical fallback).
    public var displayOrder: [String] = []
    
    /// Returns an instance of a collection of background traits.
    public init(_ backgrounds: [BackgroundTraits] = []) {
        add(backgrounds)
    }
    
    /// Adds the array of background traits to the collection.
    mutating func add(_ backgrounds: [BackgroundTraits]) {
        let mappedBackgrounds = Dictionary(backgrounds.map { ($0.name, $0) }, uniquingKeysWith: { _, last in last })
        allBackgrounds.merge(mappedBackgrounds, uniquingKeysWith: { _, last in last })
    }
    
    /// Adds a Backgrounds collection, merging traits and preserving display order if specified.
    mutating func add(_ backgrounds: Backgrounds) {
        if !backgrounds.displayOrder.isEmpty { displayOrder = backgrounds.displayOrder }
        add(backgrounds.all)
    }
    
    /// Accesses a background traits instance by name.
    public subscript(backgroundName: String) -> BackgroundTraits? {
        return allBackgrounds[backgroundName]
    }
    
    /// Returns the number of background traits in the collection.
    public var count: Int { allBackgrounds.count }
    
    /// Accesses a background traits instance by index.
    public subscript(index: Int) -> BackgroundTraits? {
        guard index >= 0 && index < count else { return nil }
        return all[index]
    }
    
    /// Returns a random background traits instance using the specified random index generator.
    public func randomElementByIndex<G: RandomIndexGenerator>(using generator: inout G) -> BackgroundTraits {
        return all.randomElementByIndex(using: &generator)!
    }
}

extension Backgrounds: CodableWithConfiguration {
    
    private enum CodingKeys: String, CodingKey {
        case backgrounds
        case displayOrder = "display order"
    }

    public init(from decoder: Decoder, configuration: GameData) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let backgrounds = try values.decode([BackgroundTraits].self, forKey: .backgrounds, configuration: configuration)
        add(backgrounds)
        displayOrder = try values.decodeIfPresent([String].self, forKey: .displayOrder) ?? []
    }

    public func encode(to encoder: Encoder, configuration: GameData) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(all, forKey: .backgrounds, configuration: configuration)
        if !displayOrder.isEmpty {
            try container.encode(displayOrder, forKey: .displayOrder)
        }
    }
}
