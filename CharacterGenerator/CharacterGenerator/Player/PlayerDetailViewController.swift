//
//  PlayerDetailViewController.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import UIKit

import RolePlayingCore

class PlayerDetailViewController: UICollectionViewController {
    
    var characterSheet: CharacterSheet!
    
    func configureView() {
        guard characterSheet != nil else { return }
        collectionView?.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the layout to be dynamic based on content
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 100, height: 50)
        }
        
        configureView()
    }

    var player: Player? {
        didSet {
            characterSheet = CharacterSheet(player!)
            configureView()
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return characterSheet?.numberOfSections ?? 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characterSheet.numberOfItems(in: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // TODO: implement a TraitCellFactory.
        let cellIdentifier = characterSheet.cellIdentifiers[indexPath.section][indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            
        if let configurable = cell as? TraitConfigurable {
            configurable.configure(characterSheet, at: indexPath)
        }
        
        return cell
    }
    
}
