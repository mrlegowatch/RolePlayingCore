//
//  DisplayOrdered.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 8/10/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// A type that can be identified by a string name.
public protocol Named {
    var name: String { get }
}

/// A collection that exposes a preferred display order for its elements.
///
/// When `displayOrder` is empty, `allByDisplayOrder` falls back to alphabetical
/// ordering by name. Elements whose names are not listed in `displayOrder` sort
/// after all listed elements, then alphabetically among themselves.
public protocol DisplayOrdered {
    associatedtype Element: Named
    var all: [Element] { get }
    var displayOrder: [String] { get }
}

extension DisplayOrdered {
    /// All elements sorted by the collection's display order with alphabetical fallback.
    public var allByDisplayOrder: [Element] {
        let order = displayOrder
        return all.sorted { a, b in
            let ai = order.firstIndex(of: a.name) ?? order.count
            let bi = order.firstIndex(of: b.name) ?? order.count
            return ai == bi ? a.name < b.name : ai < bi
        }
    }
}
