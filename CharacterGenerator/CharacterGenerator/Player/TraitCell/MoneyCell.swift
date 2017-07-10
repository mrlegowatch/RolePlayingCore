//
//  MoneyCell.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/9/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import UIKit

import RolePlayingCore

class MoneyCell: TraitCell {
    
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var labelView: UILabel!
    
    override func configure(_ characterSheet: CharacterSheet, at indexPath: IndexPath) {
        let keyPath = characterSheet.keys[indexPath.section][indexPath.row] as! KeyPath<Player, Money>
        // TODO: support better formatting for Money.
        textView.text = "\(characterSheet.player[keyPath: keyPath])"
        labelView.text = NSLocalizedString(characterSheet.labelKeys[indexPath.section][indexPath.row], comment: "").localizedUppercase
    }
    
}
