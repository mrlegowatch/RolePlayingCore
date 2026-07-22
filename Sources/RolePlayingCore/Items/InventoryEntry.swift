//
//  InventoryEntry.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Foundation

/// A single slot in a character's inventory: an item definition plus how many are carried
/// and whether any are currently equipped.
public struct InventoryEntry: Sendable, Identifiable {

    /// Stable UUID — multiple stacks of the same item (from different sources) have distinct IDs.
    public let id: UUID

    /// The item definition (what it is).
    public let item: any Item

    /// How many of this item the character carries.
    public var quantity: Int

    /// Whether this item is currently equipped (worn or held).
    /// Only one non-shield armor and one shield should be equipped at a time.
    public var isEquipped: Bool

    public var totalWeight: Weight {
        Weight(value: item.weight.value * Double(quantity), unit: item.weight.unit)
    }

    public init(id: UUID = UUID(), item: any Item, quantity: Int = 1, isEquipped: Bool = false) {
        self.id = id
        self.item = item
        self.quantity = quantity
        self.isEquipped = isEquipped
    }
}
