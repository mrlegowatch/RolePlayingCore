//
//  WeaponTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 7/21/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import SwiftDice
import Foundation

@Suite("Weapon Tests")
struct WeaponTests {

    // MARK: - DamageRoll

    @Test("DamageRoll parses standard D&D expressions")
    func damageRollParsing() {
        let d8Slashing = DamageRoll(parsing: "1d8 slashing")
        #expect(d8Slashing != nil)
        #expect(d8Slashing?.type == .slashing)
        #expect((d8Slashing?.dice as? Dice)?.sides == 8)

        let d12Piercing = DamageRoll(parsing: "1d12 piercing")
        #expect(d12Piercing?.type == .piercing)

        let twoD6Bludgeoning = DamageRoll(parsing: "2d6 bludgeoning")
        #expect(twoD6Bludgeoning?.type == .bludgeoning)
        #expect((twoD6Bludgeoning?.dice as? Dice)?.sides == 6)
    }

    @Test("DamageRoll parses elemental damage types")
    func elementalDamageTypes() {
        #expect(DamageRoll(parsing: "2d6 fire")?.type == .fire)
        #expect(DamageRoll(parsing: "1d8 cold")?.type == .cold)
        #expect(DamageRoll(parsing: "1d10 lightning")?.type == .lightning)
        #expect(DamageRoll(parsing: "1d6 necrotic")?.type == .necrotic)
    }

    @Test("DamageRoll supports custom damage types for other game systems")
    func customDamageType() {
        // Pathfinder 2e adds "bleed" — no library change required
        let bleed = DamageRoll(parsing: "1d4 bleed")
        #expect(bleed?.type == DamageType("bleed"))
        #expect(bleed?.type != .slashing)
    }

    @Test("DamageRoll rejects malformed strings")
    func damageRollInvalid() {
        #expect(DamageRoll(parsing: "slashing") == nil)    // no dice part
        #expect(DamageRoll(parsing: "1d8") == nil)         // no type
        #expect(DamageRoll(parsing: "") == nil)
    }

    @Test("DamageRoll round-trips through description")
    func damageRollDescription() {
        // SwiftDice omits `times` when it equals 1: "1d8" → description "d8"
        let roll = DamageRoll(parsing: "1d8 slashing")!
        #expect(roll.description == "d8 slashing")
        // Multi-die descriptions preserve the count
        let twoD6 = DamageRoll(parsing: "2d6 fire")!
        #expect(twoD6.description == "2d6 fire")
    }

    // MARK: - WeaponProficiency

    @Test("WeaponProficiency parses category (lowercase)")
    func proficiencyCategory() {
        let simple = WeaponProficiency(parsing: "simple")
        if case .category(let cat) = simple {
            #expect(cat == .simple)
        } else {
            Issue.record("Expected .category, got \(simple)")
        }

        let martial = WeaponProficiency(parsing: "martial")
        if case .category(let cat) = martial {
            #expect(cat == .martial)
        } else {
            Issue.record("Expected .category, got \(martial)")
        }
    }

    @Test("WeaponProficiency parses restricted category with properties")
    func proficiencyRestricted() {
        let restricted = WeaponProficiency(parsing: "martial (finesse, light)")
        if case .restricted(let cat, let props) = restricted {
            #expect(cat == .martial)
            #expect(props.contains(.finesse))
            #expect(props.contains(.light))
        } else {
            Issue.record("Expected .restricted, got \(restricted)")
        }
    }

    @Test("WeaponProficiency parses specific weapon (Title Case)")
    func proficiencySpecific() {
        let longsword = WeaponProficiency(parsing: "Longsword")
        if case .specific(let name) = longsword {
            #expect(name == "Longsword")
        } else {
            Issue.record("Expected .specific, got \(longsword)")
        }

        let handCrossbow = WeaponProficiency(parsing: "Hand Crossbow")
        if case .specific(let name) = handCrossbow {
            #expect(name == "Hand Crossbow")
        } else {
            Issue.record("Expected .specific, got \(handCrossbow)")
        }
    }

    @Test("WeaponProficiency round-trips through encode/decode")
    func proficiencyRoundTrip() throws {
        let profs: [WeaponProficiency] = [
            .category(.simple),
            .restricted(.martial, [.finesse, .light]),
            .specific("Longsword")
        ]
        let encoded = try JSONEncoder().encode(profs)
        let decoded = try JSONDecoder().decode([WeaponProficiency].self, from: encoded)
        #expect(decoded == profs)
    }

    // MARK: - Weapon struct

    @Test("Weapon ranged weapon has range values")
    func weaponRange() {
        let shortbow = Weapon(
            name: "Shortbow",
            cost: Money(value: 25, unit: .baseUnit()),
            weight: Weight(value: 2, unit: .pounds),
            category: .simple,
            damage: DamageRoll(parsing: "1d6 piercing")!,
            normalRange: 80,
            longRange: 320,
            properties: [.ammunition, .twoHanded]
        )
        #expect(shortbow.normalRange == 80)
        #expect(shortbow.longRange == 320)
        #expect(shortbow.properties.contains(.ammunition))
    }

    @Test("Weapon versatile damage is optional for non-versatile weapons")
    func weaponVersatile() {
        let dagger = Weapon(
            name: "Dagger",
            cost: Money(value: 2, unit: .baseUnit()),
            weight: Weight(value: 1, unit: .pounds),
            category: .simple,
            damage: DamageRoll(parsing: "1d4 piercing")!,
            properties: [.finesse, .light, .thrown]
        )
        #expect(dagger.versatileDamage == nil)

        let quarterstaff = Weapon(
            name: "Quarterstaff",
            cost: Money(value: 0, unit: .baseUnit()),
            weight: Weight(value: 4, unit: .pounds),
            category: .simple,
            damage: DamageRoll(parsing: "1d6 bludgeoning")!,
            versatileDamage: DamageRoll(parsing: "1d8 bludgeoning"),
            properties: [.versatile]
        )
        #expect(quarterstaff.versatileDamage?.type == .bludgeoning)
    }

    @Test("WeaponProperty string-struct supports custom properties")
    func customWeaponProperty() {
        // Pathfinder 2e "agile" — no library change required
        let agile = WeaponProperty("agile")
        #expect(agile != .finesse)
        #expect(agile == WeaponProperty("agile"))
    }
}

// WeaponProficiency needs Equatable for the round-trip test.
extension WeaponProficiency: Equatable {
    public static func == (lhs: WeaponProficiency, rhs: WeaponProficiency) -> Bool {
        switch (lhs, rhs) {
        case (.category(let a), .category(let b)):             return a == b
        case (.restricted(let a, let ap), .restricted(let b, let bp)): return a == b && ap == bp
        case (.specific(let a), .specific(let b)):             return a == b
        default: return false
        }
    }
}
