//
//  Player+Rest.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

extension Player {

    // MARK: - Short rest

    /// The result of a short rest: how many hit dice were spent and how much HP was restored.
    public struct ShortRestResult: Sendable {
        public let hitDiceSpent: Int
        public let hitPointsGained: Int
    }

    /// Spends up to `hitDiceToSpend` hit dice from the available pool.
    ///
    /// Each die is rolled (using the class hit die) and the Constitution modifier is added;
    /// the per-die contribution is floored at 0. Healed HP is capped at `maximumHitPoints`.
    /// Requesting more dice than `availableHitDice` silently spends only what remains.
    @discardableResult
    public func shortRest(hitDiceToSpend: Int) -> ShortRestResult {
        let toSpend = min(max(0, hitDiceToSpend), availableHitDice)
        guard toSpend > 0 else {
            return ShortRestResult(hitDiceSpent: 0, hitPointsGained: 0)
        }

        let constitutionModifier: Int = modifiers[.constitution]
        var totalHealed = 0
        for _ in 0..<toSpend {
            totalHealed += max(0, classTraits.hitDice.roll().result + constitutionModifier)
        }

        let before = currentHitPoints
        currentHitPoints = min(maximumHitPoints, currentHitPoints + totalHealed)
        usedHitDice += toSpend

        return ShortRestResult(hitDiceSpent: toSpend, hitPointsGained: currentHitPoints - before)
    }

    // MARK: - Long rest

    /// Restores all hit points, all spent hit dice, and all expended spell slots (5e 2024 rules).
    public func longRest() {
        currentHitPoints = maximumHitPoints
        usedHitDice = 0
        spellbook.resetSlots()
    }
}
