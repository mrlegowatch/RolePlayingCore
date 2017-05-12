//
//  Players.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/18/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

public extension Trait {
    
    public static let players = "players"
    
}

public class Players {

    public var players = [Player]()
    
    public let classes: Classes
    
    public let races: Races
    
    public init(classes: Classes, races: Races) {
        self.classes = classes
        self.races = races
    }
    
    /// Adds races from the specified races file.
    public func load(_ playersFile: String, in bundle: Bundle = .main) throws {
        let jsonObject = try bundle.loadJSON(playersFile)
        
        let players = jsonObject[Trait.players] as! [[String: Any]]
        for player in players {
            try add(player)
        }
    }
    
    public func add(_ playerDictionary: [String: Any]) throws {
        if let player = Player(from: playerDictionary) {
            // Find the class and racial traits and set them for the player
            guard let className = playerDictionary[Trait.className] as? String else { throw RuntimeError("Missing class name") }
            guard let classTraits = classes.find(className) else { throw RuntimeError("Missing class trait \"\(className)\"") }
            player.classTraits = classTraits
    
            guard let raceName = playerDictionary[Trait.race] as? String else { throw RuntimeError("Missing race name") }
            guard let racialTraits = races.find(raceName) else { throw RuntimeError("Missing racial trait \"\(raceName)\"") }
            player.racialTraits = racialTraits

            self.players.append(player)
        }
    }

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
