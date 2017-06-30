//
//  Players.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/18/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

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
