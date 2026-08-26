//
//  Player+Inventory.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 8/11/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

extension Player {

    /// Computed Armor Class.
    /// Without armor, falls back to the class's unarmored defense feature, or base 10 + DEX.
    /// Override by equipping armor or a shield via `inventory`.
    public var armorClass: Int {
        let dexterityModifier: Int = modifiers[.dexterity]
        let shieldBonus = inventory.equippedShield?.baseAC ?? 0

        if let armor = inventory.equippedArmor {
            switch armor.dexterityModifierRule {
            case .full: return armor.baseAC + dexterityModifier + shieldBonus
            case .capped(let cap): return armor.baseAC + min(dexterityModifier, cap) + shieldBonus
            case .excluded: return armor.baseAC + shieldBonus
            case .bonus: return armor.baseAC + shieldBonus
            }
        }

        let unarmoredBase = classTraits.unarmoredDefense.map { defense in
            defense.additionalAbilities.reduce(10 + dexterityModifier) { ac, ability in
                ac + (modifiers[ability] ?? 0)
            }
        } ?? (10 + dexterityModifier)

        return unarmoredBase + shieldBonus
    }

    /// All weapon proficiencies — from class and from feats.
    public var allWeaponProficiencies: [WeaponProficiency] {
        classTraits.weaponProficiencies + feats.flatMap(\.weaponProficiencies)
    }

    /// All armor weight categories trained in — from class and from feats.
    public var allArmorTraining: [ArmorProficiency] {
        classTraits.armorTraining + feats.flatMap(\.armorTraining)
    }
}
