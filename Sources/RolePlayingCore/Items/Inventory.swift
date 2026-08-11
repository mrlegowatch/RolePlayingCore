//
//  Inventory.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 8/11/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Foundation

/// A character's carried wealth and all items they are holding.
public struct Inventory: Sendable {
    /// All items carried by this character. Equipped state is tracked per entry.
    public var entries: [InventoryEntry]

    /// Carried wealth.
    public var money: Money

    public init(entries: [InventoryEntry] = [], money: Money) {
        self.entries = entries
        self.money = money
    }

    // MARK: - Equipment queries

    /// The worn armor piece, if any (excludes shields).
    public var equippedArmor: Armor? {
        entries.first(where: { $0.isEquipped && ($0.item as? Armor)?.category != .shield })?.item as? Armor
    }

    /// The held shield, if any.
    public var equippedShield: Armor? {
        entries.first(where: { $0.isEquipped && ($0.item as? Armor)?.category == .shield })?.item as? Armor
    }

    // MARK: - Mutations

    /// Adds `quantity` of `item` to inventory.
    ///
    /// If an entry for this item already exists (matched by name) its quantity is increased;
    /// otherwise a new entry is appended. Calls with `quantity` ≤ 0 are ignored.
    public mutating func add(_ item: any Item, quantity: Int = 1) {
        guard quantity > 0 else { return }
        if let index = entries.firstIndex(where: { $0.item.name == item.name }) {
            entries[index].quantity += quantity
        } else {
            entries.append(InventoryEntry(item: item, quantity: quantity))
        }
    }

    /// Removes the inventory entry with the given ID. Ignored if no matching entry exists.
    public mutating func remove(id: UUID) {
        entries.removeAll { $0.id == id }
    }

    /// Equips the inventory entry with the given ID.
    ///
    /// When equipping a non-shield armor, any other equipped non-shield armor is automatically
    /// unequipped first. When equipping a shield, any other equipped shield is unequipped first.
    /// Non-armor items are equipped without exclusivity enforcement.
    /// Ignored if no entry with the given ID exists.
    public mutating func equip(id: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        if let armor = entries[index].item as? Armor {
            if armor.category == .shield {
                for i in entries.indices where entries[i].isEquipped {
                    if (entries[i].item as? Armor)?.category == .shield {
                        entries[i].isEquipped = false
                    }
                }
            } else {
                for i in entries.indices where entries[i].isEquipped {
                    if let a = entries[i].item as? Armor, a.category != .shield {
                        entries[i].isEquipped = false
                    }
                }
            }
        }
        entries[index].isEquipped = true
    }

    /// Unequips the inventory entry with the given ID. Ignored if no matching entry exists.
    public mutating func unequip(id: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index].isEquipped = false
    }

    /// Sets the quantity of the inventory entry with the given ID.
    ///
    /// If `quantity` is 0 or less, the entry is removed from inventory.
    /// Ignored if no entry with the given ID exists.
    public mutating func adjustQuantity(_ quantity: Int, for id: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        if quantity <= 0 {
            entries.remove(at: index)
        } else {
            entries[index].quantity = quantity
        }
    }
}

extension Inventory: CodableWithConfiguration {
    
    private enum CodingKeys: String, CodingKey {
        case money
        case entries = "items"
    }

    public init(from decoder: Decoder, configuration: GameData) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let money = try container.decode(Money.self, forKey: .money, configuration: configuration.currencies)
        let entries = try container.decodeIfPresent([InventoryEntry].self, forKey: .entries, configuration: configuration.items) ?? []
        self.init(entries: entries, money: money)
    }

    public func encode(to encoder: Encoder, configuration: GameData) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(money, forKey: .money, configuration: configuration.currencies)
        if !entries.isEmpty {
            try container.encode(entries, forKey: .entries, configuration: configuration.items)
        }
    }
}
