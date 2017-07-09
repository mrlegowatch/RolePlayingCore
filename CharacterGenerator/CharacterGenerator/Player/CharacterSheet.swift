//
//  CharacterSheet.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

import RolePlayingCore

/// Character sheet provides a mapping between player properties and collection view identifiers.
class CharacterSheet {
    
    let player: Player
    
    init(_ player: Player) {
        self.player = player
    }
    
    // Mapping between sections/items and key paths to properties.
    var keys: [[PartialKeyPath<Player>]] = [
        [\Player.name, \Player.experiencePoints],
        [\Player.level, \Player.className, \Player.raceName, \Player.alignment],
        [\Player.abilities],
        [\Player.armorClass, \Player.maximumHitPoints, \Player.hitDice, \Player.money]
    ]
    
    // TODO: implement a better mechanism for mapping label keys to properties.
    var labelKeys: [[String]] = [
        ["Name", "Experience Points"],
        ["Level", "Class", "Race", "Alignment"],
        ["Abilities"],
        ["Armor Class", "Hit Points", "Hit Dice", "Money"]
    ]
    
    // TODO: this can't live here. We need data transformers to keep the number of cell types down.
    var cellIdentifiers: [[String]] = [
        ["labeledText", "labeledNumber"],
        ["labeledNumber", "labeledText", "labeledText", "alignment"],
        ["abilities"],
        ["labeledNumber", "labeledNumber", "dice", "money"]
    ]
    
    var numberOfSections: Int { return keys.count }
    
    func numberOfItems(in section: Int) -> Int {
        return keys[section].count
    }
    
}
