//
//  WeightCell.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/9/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import UIKit

import RolePlayingCore

class WeightCell: UICollectionViewCell, TraitConfigurable {
    
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var labelView: UILabel!
    
    func configure(_ characterSheet: CharacterSheet, at indexPath: IndexPath) {
        let keyPath = characterSheet.keys[indexPath.section][indexPath.row] as! KeyPath<Player, Weight>
        let formatter = MassFormatter()
        formatter.isForPersonMassUse = true
        formatter.unitStyle = .medium
        let weight = characterSheet.player[keyPath: keyPath]
        let weightString = formatter.string(fromKilograms: weight.converted(to: .kilograms).value)
        textView.text = weightString
        labelView.text = NSLocalizedString(characterSheet.labelKeys[indexPath.section][indexPath.row], comment: "").localizedUppercase
    }
    
}
