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
// wiring up species and classes to players.

public struct ConfigurationFiles: Decodable {
    let currencies: [String]
    let backgrounds: [String]
    let species: [String]
    let classes: [String]
    let players: [String]?
    let speciesNames: String?
    
    private enum CodingKeys: String, CodingKey {
        case currencies
        case backgrounds
        case species
        case classes
        case players
        case speciesNames = "species names"
    }
}

/// This is designed to configure a client from a framework or application bundle.
public struct Configuration {
    let bundle: Bundle
    
    public var configurationFiles: ConfigurationFiles
    
    public var backgrounds = Backgrounds()
    public var species = Species()
    public var classes = Classes()
    public var players = Players()
    
    public init(_ configurationFile: String, from bundle: Bundle = .main) throws {
        self.bundle = bundle
        let data = try bundle.loadJSON(configurationFile)
        let decoder = JSONDecoder()
        self.configurationFiles = try decoder.decode(ConfigurationFiles.self, from: data)
        try self.load(configurationFiles)
    }
    
    public mutating func load(_ configurationFiles: ConfigurationFiles) throws {
        let jsonDecoder = JSONDecoder()
        
        for currenciesFile in configurationFiles.currencies {
            let jsonData = try bundle.loadJSON(currenciesFile)
            _ = try jsonDecoder.decode(Currencies.self, from: jsonData)
        }
        
        for backgroundsFile in configurationFiles.backgrounds {
            let jsonData = try bundle.loadJSON(backgroundsFile)
            let backgrounds = try jsonDecoder.decode(Backgrounds.self, from: jsonData)
            self.backgrounds.backgrounds += backgrounds.backgrounds
        }
        
        for speciesFile in configurationFiles.species {
            let jsonData = try bundle.loadJSON(speciesFile)
            let species = try jsonDecoder.decode(Species.self, from: jsonData)
            self.species.species += species.species
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
                try players.resolve(backgrounds: self.backgrounds, classes: self.classes, species: self.species)
                self.players.players += players.players
            }
        }
    }
}
