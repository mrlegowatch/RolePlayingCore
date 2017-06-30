//
//  Configuration.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

// TODO: this needs work. Nominally it's purpose is to help integrate related classes,
// but because we don't have much of an implementation, it's not doing much besides
// wiring up races and classes to players.

/// This is designed to configure a client.
public struct Configuration: Codable {
    
    let bundle: Bundle
    
    var races = Races()
    var classes = Classes()
    var players = Players()
    
    enum CodingKeys: String, CodingKey {
        case races
        case classes
        case players
    }
    
    public init(from decoder: Decoder) throws {
        self.init()
        
        try decode(from: decoder)
    }
    
    public init(_ bundle: Bundle = .main) {
        self.bundle = Bundle.main
    }
    
    public mutating func decode(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let racesFiles = try values.decode([String].self, forKey: .races)
        let classesFiles = try values.decode([String].self, forKey: .classes)
        let playersFiles = try values.decodeIfPresent([String].self, forKey: .players)
        
        let jsonDecoder = JSONDecoder()
        for raceFile in racesFiles {
            let jsonData = try bundle.loadJSON(raceFile)
            let races = try jsonDecoder.decode(Races.self, from: jsonData)
            self.races.races += races.races
        }
        for classFile in classesFiles {
            let jsonData = try bundle.loadJSON(classFile)
            let classes = try jsonDecoder.decode(Classes.self, from: jsonData)
            self.classes.classes += classes.classes
        }
        
        if let playersFiles = playersFiles {
            for playersFile in playersFiles {
                let jsonData = try bundle.loadJSON(playersFile)
                let players = try jsonDecoder.decode(Players.self, from: jsonData)
                try players.resolve(classes: self.classes, races: self.races)
                self.players.players += players.players
            }
        }
    }
    
}
