//
//  Players.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/18/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

extension Player {
 
    // TODO: support KeyedArchiver?
    func resolveBackgrounds(from backgrounds: Backgrounds) throws {
        guard let backgroundTraits = backgrounds.find(self.backgroundName) else {
            throw RuntimeError("Could not resolve background name \(self.backgroundName)")
        }
        self.backgroundTraits = backgroundTraits
    }

    // TODO: support KeyedArchiver?
    func resolveSpecies(from species: Species) throws {
        guard let speciesTraits = species.find(self.speciesName) else {
            throw RuntimeError("Could not resolve species name \(self.speciesName)")
        }
        self.speciesTraits = speciesTraits
    }
   
    // TODO: support KeyedArchiver?
    func resolveClass(from classes: Classes) throws {
        guard let classTraits = classes.find(self.className) else {
            throw RuntimeError("Could not resolve class name \(self.className)")
        }
        self.classTraits = classTraits
    }
    
}

public class Players: Codable {

    public var players = [Player]()
    
    public func resolve(backgrounds: Backgrounds, classes: Classes, species: Species) throws {
        for player in players {
            try player.resolveBackgrounds(from: backgrounds)
            try player.resolveSpecies(from: species)
            try player.resolveClass(from: classes)
        }
    }
    
    // TODO: inherit protocols for these
    
    public var count: Int { return players.count }
    
    public subscript(index: Int) -> Player? {
        get {
            return players[index]
        }
    }
    
    public func insert(_ player: Player, at index: Int) {
        players.insert(player, at: index)
    }
    
    public func remove(at index: Int) {
        players.remove(at: index)
    }
    
}
