//
//  Configuration.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

// TODO: this needs work. Nominally it's purpose is to help integrate related classes,
// but because we don't have much in terms of requirements, it's not doing much besides
// wiring up races and classes to players.

public struct ConfigurationFiles: Decodable {
    let currencies: [String]
    let races: [String]
    let classes: [String]
    let players: [String]?
}

/// This is designed to configure a client from a framework or application bundle.
public struct Configuration {
    
    let bundle: Bundle
    
    public var races = Races()
    public var classes = Classes()
    public var players = Players()
    
    public init(_ configurationFile: String, from bundle: Bundle = .main) throws {
        self.bundle = bundle
        let data = try bundle.loadJSON(configurationFile)
        let decoder = JSONDecoder()
        let configurationFiles = try decoder.decode(ConfigurationFiles.self, from: data)
        try self.load(configurationFiles)
    }
    
    public mutating func load(_ configurationFiles: ConfigurationFiles) throws {
        let jsonDecoder = JSONDecoder()
        
        for currenciesFile in configurationFiles.currencies {
            let jsonData = try bundle.loadJSON(currenciesFile)
            _ = try jsonDecoder.decode(Currencies.self, from: jsonData)
        }
        
        for raceFile in configurationFiles.races {
            let jsonData = try bundle.loadJSON(raceFile)
            let races = try jsonDecoder.decode(Races.self, from: jsonData)
            self.races.races += races.races
        }
        
        for classFile in configurationFiles.classes {
            let jsonData = try bundle.loadJSON(classFile)
            let classes = try jsonDecoder.decode(Classes.self, from: jsonData)
            self.classes.classes += classes.classes
            
            // Update the shared classes experience points table, then
            // update all of the classes to point to it. TODO: improve this.
            if let experiencePoints = classes.experiencePoints {
                self.classes.experiencePoints = experiencePoints
                for (index, _) in self.classes.classes.enumerated() {
                    self.classes.classes[index].experiencePoints = experiencePoints
                }
            }
        }
        
        if let playersFiles = configurationFiles.players {
            for playersFile in playersFiles {
                let jsonData = try bundle.loadJSON(playersFile)
                let players = try jsonDecoder.decode(Players.self, from: jsonData)
                try players.resolve(classes: self.classes, races: self.races)
                self.players.players += players.players
            }
        }
    }
    
}
