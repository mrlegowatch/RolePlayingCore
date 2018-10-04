//
//  GenderCell.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/9/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import UIKit

import RolePlayingCore

class GenderCell: UICollectionViewCell, TraitConfigurable {
    
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var labelView: UILabel!
    
    func configure(_ characterSheet: CharacterSheet, at indexPath: IndexPath) {
        let keyPath = characterSheet.keys[indexPath.section][indexPath.row] as! KeyPath<Player, Player.Gender?>
        let gender = characterSheet.player[keyPath: keyPath]
        let genderString = gender != nil ? "\(gender!)" : "androgynous"
        textView.text = genderString.localizedCapitalized
        labelView.text = NSLocalizedString(characterSheet.labelKeys[indexPath.section][indexPath.row], comment: "").localizedUppercase
    }
    
}
