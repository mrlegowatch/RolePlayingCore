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
    func resolveRace(from races: Races) throws {
        guard let racialTraits = races.find(self.raceName) else {
            throw RuntimeError("Could not resolve race name \(self.raceName)")
        }
        self.racialTraits = racialTraits
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
    
    public func resolve(classes: Classes, races: Races) throws {
        for player in players {
            try player.resolveRace(from: races)
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
