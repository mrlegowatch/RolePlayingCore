//
//  LabeledTextCell.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import UIKit

import RolePlayingCore

class LabeledTextCell: TraitCell {
    
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var labelView: UILabel!
    
    override func configure(_ characterSheet: CharacterSheet, at indexPath: IndexPath) {
        // TODO: can't use a PartialKeyPath for some reason, need to cast to KeyPath with String
        let keyPath = characterSheet.keys[indexPath.section][indexPath.row] as! KeyPath<Player, String>
        textView.text = characterSheet.player[keyPath: keyPath]
        labelView.text = NSLocalizedString(characterSheet.labelKeys[indexPath.section][indexPath.row], comment: "").localizedUppercase
    }
}
