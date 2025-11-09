//
//  Configuration.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// Represents a collection of JSON file names that belong to a bundle.
/// Used by the `Configuration`.
public struct ConfigurationFiles: Decodable {
    let currencies: [String]
    let skills: [String]
    let backgrounds: [String]
    let creatureTypes: [String]
    let species: [String]
    let classes: [String]
    let players: [String]?
    let speciesNames: String?
    
    private enum CodingKeys: String, CodingKey {
        case currencies
        case skills
        case backgrounds
        case creatureTypes = "creature types"
        case species
        case classes
        case players
        case speciesNames = "species names"
    }
}

/// Configure a client's data from a framework or application bundle.
public struct Configuration {
    let bundle: Bundle
    
    public var configurationFiles: ConfigurationFiles
    
    public var currencies = Currencies()
    public var skills = Skills()
    public var backgrounds = Backgrounds()
    public var creatureTypes = CreatureTypes()
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
            let currencies = try jsonDecoder.decode(Currencies.self, from: jsonData)
            self.currencies.add(currencies.all)
        }

        for skillsFile in configurationFiles.skills {
            let jsonData = try bundle.loadJSON(skillsFile)
            let skills = try jsonDecoder.decode(Skills.self, from: jsonData)
            self.skills.add(skills.all)
        }

        for backgroundsFile in configurationFiles.backgrounds {
            let jsonData = try bundle.loadJSON(backgroundsFile)
            let backgrounds = try jsonDecoder.decode(Backgrounds.self, from: jsonData, configuration: self)
            self.backgrounds.add(backgrounds.all)
        }
        
        for creatureTypesFile in configurationFiles.creatureTypes {
            let jsonData = try bundle.loadJSON(creatureTypesFile)
            let creatureTypes = try jsonDecoder.decode(CreatureTypes.self, from: jsonData)
            self.creatureTypes.add(creatureTypes.all)
        }

        for speciesFile in configurationFiles.species {
            let jsonData = try bundle.loadJSON(speciesFile)
            let species = try jsonDecoder.decode(Species.self, from: jsonData, configuration: self)
            self.species.add(species)
        }
        
        for classFile in configurationFiles.classes {
            let jsonData = try bundle.loadJSON(classFile)
            let classes = try jsonDecoder.decode(Classes.self, from: jsonData, configuration: self)
            self.classes.add(classes)
        }
        
        if let playersFiles = configurationFiles.players {
            for playersFile in playersFiles {
                let jsonData = try bundle.loadJSON(playersFile)
                let players = try jsonDecoder.decode(Players.self, from: jsonData, configuration: self)
                self.players.players += players.players
            }
        }
    }
}
