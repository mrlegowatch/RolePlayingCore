//
//  InventoryView.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 1/3/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import SwiftUI
import RolePlayingCore

struct InventoryView: View {
    let player: Player

    private var weapons: [InventoryEntry] {
        player.inventory.filter { $0.item is Weapon }.sorted { $0.item.name < $1.item.name }
    }

    private var armorItems: [InventoryEntry] {
        player.inventory.filter { $0.item is Armor }.sorted { $0.item.name < $1.item.name }
    }

    private var gearItems: [InventoryEntry] {
        player.inventory.filter { !($0.item is Weapon) && !($0.item is Armor) }.sorted { $0.item.name < $1.item.name }
    }

    private var totalWeight: String {
        let pounds = player.inventory.reduce(0.0) { $0 + $1.totalWeight.converted(to: .pounds).value }
        return Weight(value: pounds, unit: .pounds).displayString
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                Label("Equipment", systemImage: "bag")
                    .font(.headline)
                Spacer()
                statPill(title: "\(player.money)", subtitle: "Money")
                statPill(title: totalWeight, subtitle: "Weight")
            }
            if !weapons.isEmpty {
                Divider()
                inventorySection("Weapons", entries: weapons)
            }
            if !armorItems.isEmpty {
                Divider()
                inventorySection("Armor", entries: armorItems)
            }
            if !gearItems.isEmpty {
                Divider()
                inventorySection("Gear", entries: gearItems)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statPill(title: String, subtitle: String) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.subheadline.bold())
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func inventorySection(_ title: String, entries: [InventoryEntry]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            FlowLayout(spacing: 6) {
                ForEach(entries) { entry in
                    ItemChip(entry: entry)
                }
            }
        }
    }
}

private struct ItemChip: View {
    let entry: InventoryEntry

    private var nameText: String {
        entry.quantity > 1 ? "\(entry.quantity)× \(entry.item.name)" : entry.item.name
    }

    private var detailText: String? {
        if let weapon = entry.item as? Weapon {
            var parts = ["\(weapon.damage)"]
            if let normal = weapon.normalRange, let long = weapon.longRange {
                parts.append("\(normal)/\(long) ft")
            }
            return parts.joined(separator: " · ")
        } else if let armor = entry.item as? Armor {
            return "AC \(armor.baseAC) · \(armor.category.rawValue)"
        }
        return nil
    }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            if entry.isEquipped {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.tint)
                    .padding(.top, 2)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(nameText)
                    .font(.caption)
                if let detail = detailText {
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chipStyle(backgroundOpacity: entry.isEquipped ? 0.15 : 0.08)
    }
}

#Preview("Inventory View") {
    if let player = try? CharacterGenerator(GameData("Configuration")).makeCharacter() {
        InventoryView(player: player)
            .padding()
    } else {
        Text("No player generated")
    }
}
