//
//  CharacterSheet.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation
import RolePlayingCore

extension Int {
    var displayModifier: String { self > 0 ? " +\(self) " : " \(self) " }
}

/// Character sheet provides a mapping between player properties and collection view groupings and views.
class CharacterSheet {
    let player: Player
    
    init(_ player: Player) {
        self.player = player
    }
    
    // Mapping between sections/items and key paths to properties.
    var keys: [[PartialKeyPath<CharacterSheet>]] = [
        [\.experiencePoints],
        [\.backgroundName, \.speciesName, \.className, \.subclassName],
        [\.abilities],
        [\.skills],
        [\.initiative, \.speed],
        [\.armorClass, \.proficiencyBonus, \.passivePerception],
        [\.currentHitPoints, \.maximumHitPoints, \.hitDice],
        [\.height, \.size],
        [\.money],
        [\.inventory]
    ]

    // Mapping of properties to label keys.
    var labelKeys: [[String]] = [
        ["Experience Points"],
        ["Background", "Species", "Class", "Subclass"],
        ["Abilities"],
        ["Skills"],
        ["Initiative", "Speed"],
        ["Armor Class", "Proficiency Bonus", "Passive Perception"],
        ["Current HP", "Max HP", "Hit Dice"],
        ["Height", "Size"],
        ["Money"],
        ["Inventory"]
    ]

    // Mapping of properties to view types.
    var cellIdentifiers: [[String]] = [
        ["experiencePoints"],
        ["labeledText", "labeledText", "labeledText", "labeledText"],
        ["abilities"],
        ["labeledText"],
        ["labeledNumber", "labeledNumber"],
        ["labeledNumber", "labeledNumber", "labeledNumber"],
        ["labeledNumber", "labeledNumber", "labeledText"],
        ["labeledText", "labeledText"],
        ["labeledText"],
        ["labeledText"]
    ]
    
    var numberOfSections: Int { return keys.count }
    
    func numberOfItems(in section: Int) -> Int {
        return keys[section].count
    }
    
    // Wrapped properties as display strings
    
    var experiencePoints: String { "\(player.experiencePoints)" }
    var level: String { "\(player.level)" }
    var backgroundName: String { player.backgroundName }
    var className: String { player.className }
    var speciesName: String { player.speciesName }
    var subclassName: String { player.subclassName }
    var alignment: String {
        if let alignment = player.alignment {
            return "\(alignment)"
        } else {
            return "Unaligned"
        }
    }
    var abilities: AbilityScores { player.abilities }
    var skills: String {
        player.skillProficiencies.skillNames.joined(separator: ", ")
    }
    var initiative: String { player.initiativeModifier.displayModifier }
    var armorClass: String { "\(player.armorClass)" }
    var proficiencyBonus: String { player.proficiencyBonus.displayModifier }
    var maximumHitPoints: String { "\(player.maximumHitPoints)" }
    var currentHitPoints: String { "\(player.currentHitPoints)" }
    var hitDice: String { "\(player.hitDice)" }
    var money: String { "\(player.money)" }
    var gender: String { player.gender.map(\.rawValue) ?? "Androgynous" }
    var height: String { player.height.displayString }
    var speed: String {
        let value = player.speed
        let distance = Measurement(value: Double(value), unit: UnitLength.feet)
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .providedUnit
        return formatter.string(from: distance)
    }
    var size: String { "\(player.size)".capitalized }
    var passivePerception: String { "\(player.passivePerception)" }
    var inventory: String {
        guard !player.inventory.isEmpty else { return "None" }
        return player.inventory.map { entry in
            let qty = entry.quantity > 1 ? "\(entry.quantity)x " : ""
            let equipped = entry.isEquipped ? " ✓" : ""
            return "\(qty)\(entry.item.name)\(equipped)"
        }.joined(separator: "\n")
    }
}
