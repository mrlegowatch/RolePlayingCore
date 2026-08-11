//
//  Spellbook.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

/// A character's prepared spells and expended spell slot tracking.
public struct Spellbook: Sendable {
    /// Spells currently prepared or known.
    public var preparedSpells: [Spell]
    /// Slots expended at each level since the last long rest (0-indexed; index 0 = 1st-level slots).
    public var usedSpellSlots: [Int]

    public init(preparedSpells: [Spell] = [], usedSpellSlots: [Int] = []) {
        self.preparedSpells = preparedSpells
        self.usedSpellSlots = usedSpellSlots
    }

    public var isEmpty: Bool {
        preparedSpells.isEmpty && usedSpellSlots.isEmpty
    }

    // MARK: - Spell management

    /// Adds a spell to the prepared list. Ignored if the spell is already prepared.
    public mutating func prepare(_ spell: Spell) {
        guard !preparedSpells.contains(spell) else { return }
        preparedSpells.append(spell)
    }

    /// Removes a spell from the prepared list. Ignored if the spell is not prepared.
    public mutating func unprepare(_ spell: Spell) {
        preparedSpells.removeAll { $0 == spell }
    }

    // MARK: - Slot management

    /// Returns the number of slots already expended at the given 1-based slot level.
    public func slotsExpended(at slotLevel: Int) -> Int {
        guard slotLevel >= 1, slotLevel <= usedSpellSlots.count else { return 0 }
        return usedSpellSlots[slotLevel - 1]
    }

    /// Expends one slot at the given 1-based slot level, growing the array as needed.
    public mutating func expendSlot(at slotLevel: Int) {
        if slotLevel > usedSpellSlots.count {
            usedSpellSlots += Array(repeating: 0, count: slotLevel - usedSpellSlots.count)
        }
        usedSpellSlots[slotLevel - 1] += 1
    }

    /// Resets all expended spell slots (long rest).
    public mutating func resetSlots() {
        usedSpellSlots = []
    }
}

extension Spellbook: CodableWithConfiguration {

    private enum CodingKeys: String, CodingKey {
        case preparedSpells = "prepared spells"
        case usedSpellSlots = "used spell slots"
    }

    public init(from decoder: any Decoder, configuration: GameData) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let spellNames = try container.decodeIfPresent([String].self, forKey: .preparedSpells) ?? []
        let preparedSpells = spellNames.compactMap { configuration.spells[$0] }
        let usedSpellSlots = try container.decodeIfPresent([Int].self, forKey: .usedSpellSlots) ?? []
        self.init(preparedSpells: preparedSpells, usedSpellSlots: usedSpellSlots)
    }

    public func encode(to encoder: any Encoder, configuration: GameData) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !preparedSpells.isEmpty {
            try container.encode(preparedSpells.map(\.name), forKey: .preparedSpells)
        }
        if !usedSpellSlots.isEmpty {
            try container.encode(usedSpellSlots, forKey: .usedSpellSlots)
        }
    }
}
