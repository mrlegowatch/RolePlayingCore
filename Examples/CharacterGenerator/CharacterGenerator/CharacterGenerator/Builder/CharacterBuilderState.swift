//
//  CharacterBuilderState.swift
//  CharacterGenerator
//
//  Copyright © 2025 Brian Arnold. All rights reserved.
//

import Observation
import RolePlayingCore

@Observable
class CharacterBuilderState {
    var selectedSpecies: SpeciesTraits?
    var selectedClass: ClassTraits?
    var selectedBackground: BackgroundTraits?

    /// Six rolled scores (4d6-drop-lowest) available to assign to abilities.
    var rolledScores: [Int] = []

    /// Ability scores as assigned by the user; all six start at 0.
    var assignedAbilities: AbilityScores = AbilityScores()

    /// Class skill proficiencies chosen by the user (background skills are granted automatically).
    var chosenSkills: [Skill] = []

    /// Cantrips chosen during character creation.
    var chosenCantrips: [Spell] = []

    /// Level-1 spells chosen during character creation.
    var chosenSpells: [Spell] = []

    var name: String = ""
    var gender: Player.Gender?
    var alignment: CharacterAlignment?

    /// Current step index (0 = Species … last = Name & Finish).
    var currentStep: Int = 0

    /// True after ability scores have been auto-rolled on first appearance.
    var hasAutoRolled: Bool = false

    /// Class skill options available to the user, excluding skills already granted by the selected background.
    var availableClassSkills: [Skill] {
        guard let classTraits = selectedClass else { return [] }
        guard let background = selectedBackground else {
            return classTraits.skillProficiencies
        }
        let backgroundSkillNames = Set(background.skillProficiencies.skillNames)
        return classTraits.skillProficiencies.filter { !backgroundSkillNames.contains($0.name) }
    }

    var isComplete: Bool {
        guard selectedSpecies != nil,
              selectedClass != nil,
              selectedBackground != nil,
              !name.isEmpty else { return false }
        let allAssigned = Ability.defaults.allSatisfy { (assignedAbilities[$0] ?? 0) > 0 }
        let correctSkillCount = chosenSkills.count == (selectedClass?.startingSkillCount ?? 0)
        guard allAssigned && correctSkillCount else { return false }
        if let cls = selectedClass, cls.spellcastingAbility != nil {
            let needsCantrips = cls.cantripsKnown ?? 0
            let needsSpells = cls.spellsKnown ?? 0
            guard chosenCantrips.count == needsCantrips && chosenSpells.count == needsSpells else { return false }
        }
        return true
    }

    /// Rolls six ability scores (4d6-drop-lowest) and resets any prior assignments.
    func rollAbilityScores() {
        var temp = AbilityScores()
        temp.roll()
        rolledScores = Array(temp.values).sorted(by: >)
        assignedAbilities = AbilityScores()
    }

    /// Creates the finished Player from the builder's current selections. Returns nil if `isComplete` is false.
    func finalize() -> Player? {
        guard let species = selectedSpecies,
              let classTraits = selectedClass,
              let background = selectedBackground,
              isComplete else { return nil }

        var allSkills = chosenSkills
        allSkills.append(background.skillProficiencies)

        let player = Player(name,
                            backgroundTraits: background,
                            speciesTraits: species,
                            classTraits: classTraits,
                            baseAbilities: assignedAbilities,
                            skillProficiencies: allSkills,
                            gender: gender,
                            alignment: alignment)
        for spell in chosenCantrips + chosenSpells {
            player.prepareSpell(spell)
        }
        return player
    }
}
