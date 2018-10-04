//
//  TraitConfigurable.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/9/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import UIKit

import RolePlayingCore

// TODO: in many cases, what we need are data transformers, not types of cells
protocol TraitConfigurable {
    
    func configure(_ characterSheet: CharacterSheet, at indexPath: IndexPath)
}

// Data transformers
extension CharacterSheet {
    
    func int(from indexPath: IndexPath) -> Int? {
        let keyPath = self.keys[indexPath.section][indexPath.row] as! KeyPath<Player, Int>
        return Int(self.player[keyPath: keyPath])
    }
    
    func string(from indexPath: IndexPath) -> String? {
        let keyPath = self.keys[indexPath.section][indexPath.row] as! KeyPath<Player, String>
        return String(self.player[keyPath: keyPath])
    }
}
