//
//  ItemTests.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Item Protocol Tests")
struct ItemTests {

    // Minimal conforming type using the default plural
    private struct BasicItem: Item {
        var name: String
        var cost: Money
        var weight: Weight
    }

    // Conforming type that overrides the default plural
    private struct IrregularItem: Item {
        var name: String
        var plural: String
        var cost: Money
        var weight: Weight
    }

    let zeroCost = Money(value: 0, unit: UnitCurrency.baseUnit())
    let zeroWeight = Weight(value: 0, unit: .pounds)

    // MARK: - Default plural

    @Test("Default plural appends 's' to name")
    func defaultPlural() {
        let dagger = BasicItem(name: "Dagger", cost: zeroCost, weight: zeroWeight)
        #expect(dagger.plural == "Daggers")

        let shield = BasicItem(name: "Shield", cost: zeroCost, weight: zeroWeight)
        #expect(shield.plural == "Shields")

        let potion = BasicItem(name: "Potion", cost: zeroCost, weight: zeroWeight)
        #expect(potion.plural == "Potions")

        let torch = BasicItem(name: "Torch", cost: zeroCost, weight: zeroWeight)
        #expect(torch.plural == "Torchs", "Default appends 's' verbatim, even for irregular plurals")
    }

    // MARK: - Custom plural override

    @Test("Custom plural overrides the default")
    func customPlural() {
        let staff = IrregularItem(name: "Staff", plural: "Staves", cost: zeroCost, weight: zeroWeight)
        #expect(staff.plural == "Staves")
        #expect(staff.plural != staff.name + "s", "Custom plural must not match the default")
    }

    @Test("Name and cost are accessible via protocol")
    func nameAndCostViaProtocol() {
        let item: any Item = BasicItem(name: "Rope", cost: zeroCost, weight: zeroWeight)
        #expect(item.name == "Rope")
        #expect(item.plural == "Ropes")
    }
}
