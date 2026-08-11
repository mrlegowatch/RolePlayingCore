//
//  Item.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Foundation

/// A piece of equipment carried or worn by a player character.
public protocol Item: Sendable {
    /// The canonical singular name of the item (e.g., "Dagger").
    var name: String { get }

    /// The plural name of the item, used when resolving equipment strings (e.g., "2 Daggers").
    var plural: String { get }

    /// The market cost of one unit.
    var cost: Money { get }

    /// The weight of one unit.
    var weight: Weight { get }
}

extension Item {
    /// Default plural is formed by appending "s" to the name.
    /// Items with irregular plurals must override this.
    public var plural: String { name + "s" }
}
