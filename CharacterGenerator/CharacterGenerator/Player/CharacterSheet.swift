//
//  CharacterSheet.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

import RolePlayingCore

/// Character sheet provides a mapping between player properties and collection view groupings and views.
class CharacterSheet {
    
    let player: Player
    
    init(_ player: Player) {
        self.player = player
    }
    
    // Mapping between sections/items and key paths to properties.
    var keys: [[PartialKeyPath<CharacterSheet>]] = [
        [\.level, \.experiencePoints],
        [\.className, \.speciesName, \.alignment],
        [\.abilities],
        [\.armorClass, \.proficiencyBonus, \.maximumHitPoints, \.hitDice, \.money],
        [\.gender, \.height, \.weight]
    ]
    
    // Mapping of properties to label keys.
    var labelKeys: [[String]] = [
        ["Level", "Experience Points"],
        ["Class", "Species", "Alignment"],
        ["Abilities"],
        ["Armor Class", "Proficiency Bonus", "Hit Points", "Hit Dice", "Money"],
        ["Gender", "Height", "Weight"]
    ]
    
    // Mapping of properties to view types.
    var cellIdentifiers: [[String]] = [
        ["labeledText", "labeledText"],
        ["labeledText", "labeledText", "labeledText"],
        ["abilities"],
        ["labeledText", "labeledText", "labeledText", "labeledText", "labeledText"],
        ["labeledText", "labeledText", "labeledText"]
    ]
    
    var numberOfSections: Int { return keys.count }
    
    func numberOfItems(in section: Int) -> Int {
        return keys[section].count
    }
    
    // Wrapped properties as display strings
    
    var experiencePoints: String { "\(player.experiencePoints)" }
    var level: String { "\(player.level)" }
    var className: String { player.className }
    var speciesName: String { player.speciesName }
    var alignment: String {
        if let alignment = player.alignment {
            return "\(alignment)"
        } else {
            return "Unaligned"
        }
    }
    var abilities: AbilityScores { player.abilities }
    var armorClass: String { "\(player.armorClass)" }
    var proficiencyBonus: String { "\(player.proficiencyBonus)" }
    var maximumHitPoints: String { "\(player.maximumHitPoints)" }
    var currentHitPoints: String { "\(player.currentHitPoints)" }
    var hitDice: String { "\(player.hitDice)" }
    var money: String { "\(player.money)" }
    var gender: String { player.gender.map(\.rawValue) ?? "Androgynous" }
    var height: String { player.height.displayString }
    var weight: String { player.weight.displayString }
}
