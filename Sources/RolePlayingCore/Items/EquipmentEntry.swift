//
//  EquipmentEntry.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// A single entry within a starting equipment option.
public enum EquipmentEntry: Sendable {
    /// A resolved item from the registry, with a quantity.
    case item(any Item, quantity: Int)
    /// A currency amount (e.g., "8 GP").
    case money(Money)
    /// A free-form string that did not resolve to a known item or money amount
    /// (e.g., "Any Tool", "Arcane Focus (quarterstaff)").
    case note(String)
}

extension EquipmentEntry: CustomStringConvertible {
    
    /// For an item, indicates the number of items and uses plural. For money, uses money formatting.
    public var description: String {
        switch self {
        case .item(let item, 1):
            return item.name
        case .item(let item, let quantity):
            return "\(quantity) \(item.plural)"
        case .money(let money):
            return money.description
        case .note(let note):
            return note
        }
    }
}

extension EquipmentEntry {

    /// Parses a single equipment string against the item registry and currencies.
    ///
    /// Resolution order:
    /// 1. Try as money (e.g., `"8 GP"`).
    /// 2. Strip a leading integer quantity (e.g., `"2 Daggers"` → qty 2, name `"Daggers"`).
    /// 3. Look up the name in the items registry by exact name or plural.
    /// 4. Fall through to `.note(string)`.
    public static func parse(_ string: String, items: Items, currencies: Currencies) -> EquipmentEntry {
        let trimmed = string.trimmingCharacters(in: .whitespaces)

        // 1. Money?
        if let money = trimmed.parseMoney(currencies) {
            return .money(money)
        }

        // 2. Leading quantity?
        var quantity = 1
        var itemName = trimmed
        if let firstSpace = trimmed.firstIndex(of: " ") {
            let possibleNumber = String(trimmed[..<firstSpace])
            if let amount = Int(possibleNumber), amount > 0 {
                quantity = amount
                itemName = String(trimmed[trimmed.index(after: firstSpace)...])
                    .trimmingCharacters(in: .whitespaces)
            }
        }

        // 3. Item registry lookup (exact, then plural variants)
        if let item = items[itemName] {
            return .item(item, quantity: quantity)
        }

        // 4. Fall through
        return .note(trimmed)
    }

    /// Parses an array of equipment option strings into typed entries.
    public static func parseOption(
        _ strings: [String],
        items: Items,
        currencies: Currencies
    ) -> [EquipmentEntry] {
        strings.map { parse($0, items: items, currencies: currencies) }
    }
}
