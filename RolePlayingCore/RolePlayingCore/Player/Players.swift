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
    public func load(_ classesFile: String, in bundle: Bundle = .main) throws {
        let jsonObject = try bundle.loadJSON(classesFile)
        
        let players = jsonObject[Trait.players] as! [[String: Any]]
        for player in players {
            try add(player)
        }
    }
    
    public func add(_ playerDictionary: [String: Any]) throws {
        if let player = Player(from: playerDictionary) {
            // Find the class and racial traits and set them for the player
            guard let classTraits = classes.find(playerDictionary[Trait.className] as? String) else { throw RuntimeError("Missing class trait \"\(playerDictionary[Trait.className])\"") }
            player.classTraits = classTraits
    
            guard let racialTraits = races.find(playerDictionary[Trait.race] as? String) else { throw RuntimeError("Missing racial trait \"\(playerDictionary[Trait.race])\"") }
            player.racialTraits = racialTraits

            self.players.append(player)
        }
    }
    
}
