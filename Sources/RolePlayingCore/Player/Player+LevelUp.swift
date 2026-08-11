//
//  Player+LevelUp.swift
//  RolePlayingCore
//
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

extension Player {

    // MARK: - Hit points

    public class func rollHitPoints(classTraits: ClassTraits, speciesTraits: SpeciesTraits) -> Int {
        return max(classTraits.hitDice.sides / 2 + 1, classTraits.hitDice.roll().result)
    }

    public func rollHitPoints() -> Int {
        return Player.rollHitPoints(classTraits: classTraits, speciesTraits: speciesTraits)
    }

    // MARK: - Level-up

    public var canLevelUp: Bool {
        return level < classTraits.maxLevel && experiencePoints > classTraits.maxExperiencePoints(at: level)
    }

    /// Describes what changed and what choices are pending after a level-up.
    public struct LevelUpResult: Sendable {
        /// The new character level.
        public let newLevel: Int
        /// Hit points added to both maximum and current HP.
        public let hitPointsGained: Int
        /// The feat category to select at this level, or nil if no feat is awarded.
        public let featCategoryToSelect: FeatTraits.Category?
        /// True when this level triggers subclass selection and choices are available.
        public let requiresSubclassSelection: Bool
    }

    /// Levels up the character if the XP threshold has been reached.
    ///
    /// Returns a `LevelUpResult` describing HP gained and any pending choices
    /// (feat selection, subclass selection) the UI needs to present, or `nil`
    /// if the level-up precondition was not met.
    @discardableResult
    public func levelUp() -> LevelUpResult? {
        guard canLevelUp else { return nil }

        level += 1

        let hpGained = rollHitPoints()
        maximumHitPoints += hpGained
        currentHitPoints += hpGained

        let featCategory: FeatTraits.Category?
        switch level {
        case 20:            featCategory = .epicBoon
        case 4, 8, 12, 16, 19: featCategory = .general
        default:            featCategory = nil
        }

        let requiresSubclassSelection =
            subclassTraits == nil &&
            level == classTraits.subclassChoiceLevel &&
            !classTraits.subclasses.isEmpty

        return LevelUpResult(
            newLevel: level,
            hitPointsGained: hpGained,
            featCategoryToSelect: featCategory,
            requiresSubclassSelection: requiresSubclassSelection
        )
    }

    /// Assigns a subclass to this character.
    ///
    /// Silently ignored if the character's level is below `classTraits.subclassChoiceLevel`
    /// or if the subclass does not belong to the character's class.
    public func selectSubclass(_ subclass: SubclassTraits) {
        guard level >= classTraits.subclassChoiceLevel,
              classTraits.subclasses.contains(subclass) else { return }
        subclassTraits = subclass
    }
}
