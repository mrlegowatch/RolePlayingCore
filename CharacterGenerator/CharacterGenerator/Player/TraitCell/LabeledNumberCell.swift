//
//  LabeledNumberCell.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/9/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import UIKit

import RolePlayingCore

class LabeledNumberCell : UICollectionViewCell, TraitConfigurable {
    
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var labelView: UILabel!
    
    func configure(_ characterSheet: CharacterSheet, at indexPath: IndexPath) {
        //let keyPath = characterSheet.keys[indexPath.section][indexPath.row] as! KeyPath<Player, Int>
        //textView.text = String(characterSheet.player[keyPath: keyPath])
        textView.text = String(characterSheet.int(from: indexPath)!)
        labelView.text = NSLocalizedString(characterSheet.labelKeys[indexPath.section][indexPath.row], comment: "").localizedUppercase
    }
}
