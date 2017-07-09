//
//  AbilitiesCell.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/9/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import UIKit

import RolePlayingCore

class AbilitiesCell: TraitCell {
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var values: [UILabel]!
    
    @IBOutlet weak var proficiencyBonusLabel: UILabel!
    @IBOutlet weak var proficiencyBonusValue: UILabel!
    
    // Sort order for abilities
    let abilities = [Ability.strength, Ability.dexterity, Ability.constitution, Ability.intelligence, Ability.wisdom, Ability.charisma]
    
    override func configure(_ characterSheet: CharacterSheet, at indexPath: IndexPath) {
        // TODO: we combine ability scores and ability score modifier
        let abilityScores = characterSheet.player.abilities
        let modifiers = abilityScores - characterSheet.player.baseAbilities
        for (index, ability) in abilities.enumerated() {
            labels[index].text = NSLocalizedString(abilities[index].name, comment: "").localizedUppercase
            let score = abilityScores[ability]!
            let modifier = modifiers[ability]!
            let modifierString = modifier > 0 ? "+\(modifier)" : "\(modifier)"
            values[index].text = "\(score) (\(modifierString))"
        }
        
        proficiencyBonusLabel.text = NSLocalizedString("Proficiency Bonus", comment: "").localizedUppercase
        let proficiencyBonus = characterSheet.player.proficiencyBonus
        let proficiencyBonusString = proficiencyBonus > 0 ? "+\(proficiencyBonus)" : "\(proficiencyBonus)"
        proficiencyBonusValue.text = proficiencyBonusString
    }
    
}
