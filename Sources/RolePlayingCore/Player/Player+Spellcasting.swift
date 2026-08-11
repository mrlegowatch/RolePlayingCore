//
//  Player+Spellcasting.swift
//  RolePlayingCore
//
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

extension Player {

    // MARK: - Spellcasting stats

    public var spellcastingAbility: Ability? { classTraits.spellcastingAbility }

    public var spellcastingModifier: Int? {
        guard let ability = spellcastingAbility else { return nil }
        return modifiers[ability]
    }

    public var spellSaveDC: Int? {
        spellcastingModifier.map { 8 + proficiencyBonus + $0 }
    }

    public var spellAttackBonus: Int? {
        spellcastingModifier.map { proficiencyBonus + $0 }
    }

    /// Maximum spells that can be prepared: spellcasting modifier + character level, minimum 1.
    public var maxPreparedSpells: Int? {
        guard classTraits.spellcastingType == .prepared,
              let modifier = spellcastingModifier else { return nil }
        return max(1, modifier + level)
    }

    // MARK: - Spell slots

    /// Returns the total spell slots at the given 1-based slot level for the character's current class level.
    public func totalSpellSlots(at slotLevel: Int) -> Int {
        guard slotLevel >= 1,
              let slots = classTraits.spellSlots,
              level >= 1, level <= slots.count else { return 0 }
        let levelSlots = slots[level - 1]
        guard slotLevel <= levelSlots.count else { return 0 }
        return levelSlots[slotLevel - 1]
    }

    /// Returns the number of remaining unused spell slots at the given 1-based slot level.
    public func availableSpellSlots(at slotLevel: Int) -> Int {
        let total = totalSpellSlots(at: slotLevel)
        return max(0, total - spellbook.slotsExpended(at: slotLevel))
    }

    /// Expends one spell slot at the given 1-based slot level.
    ///
    /// Returns `true` if a slot was available and expended, `false` if no slots remain at that level.
    @discardableResult
    public func castSpell(usingSlotLevel slotLevel: Int) -> Bool {
        guard availableSpellSlots(at: slotLevel) > 0 else { return false }
        spellbook.expendSlot(at: slotLevel)
        return true
    }
}
