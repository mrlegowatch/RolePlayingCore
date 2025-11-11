//
//  Configuration.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

// MARK: - Configuration Files

/// Represents a collection of JSON file names that belong to a bundle.
/// Used by the `Configuration` to determine which files to load.
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

// MARK: - Configuration

/// Configure a client's data from a framework or application bundle.
///
/// This type manages the loading and organization of game data including currencies,
/// skills, backgrounds, creature types, species, classes, and players from JSON files.
public struct Configuration {
    let bundle: Bundle
    let decoder = JSONDecoder()
    public var configurationFiles: ConfigurationFiles
    
    public var currencies = Currencies()
    public var skills = Skills()
    public var backgrounds = Backgrounds()
    public var creatureTypes = CreatureTypes()
    public var species = Species()
    public var classes = Classes()
    public var players = Players()
    
    // MARK: - Initialization
    
    /// Creates a new configuration by loading data from the specified configuration file.
    ///
    /// - Parameters:
    ///   - configurationFile: The name of the main configuration JSON file.
    ///   - bundle: The bundle containing the configuration files. Defaults to `.main`.
    /// - Throws: An error if the configuration file cannot be loaded or decoded.
    public init(_ configurationFile: String, from bundle: Bundle = .main) throws {
        self.bundle = bundle
        let data = try bundle.loadJSON(configurationFile)
        self.configurationFiles = try decoder.decode(ConfigurationFiles.self, from: data)
        try self.load(configurationFiles)
    }
    
    // MARK: - Loading Methods
    
    /// Loads all configuration data from the specified configuration files.
    ///
    /// - Parameter configurationFiles: The configuration files structure containing file names.
    /// - Throws: An error if any file cannot be loaded or decoded.
    public mutating func load(_ configurationFiles: ConfigurationFiles) throws {
        try loadCurrencies(from: configurationFiles.currencies)
        try loadSkills(from: configurationFiles.skills)
        try loadBackgrounds(from: configurationFiles.backgrounds)
        try loadCreatureTypes(from: configurationFiles.creatureTypes)
        try loadSpecies(from: configurationFiles.species)
        try loadClasses(from: configurationFiles.classes)
        try loadPlayers(from: configurationFiles.players)
    }
    
    // MARK: - Private Loading Helpers
    
    /// Loads currencies from the specified file names.
    private mutating func loadCurrencies(from fileNames: [String]) throws {
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let currencies = try decoder.decode(Currencies.self, from: jsonData)
            self.currencies.add(currencies.all)
        }
    }
    
    /// Loads skills from the specified file names.
    private mutating func loadSkills(from fileNames: [String]) throws {
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let skills = try decoder.decode(Skills.self, from: jsonData)
            self.skills.add(skills.all)
        }
    }
    
    /// Loads backgrounds from the specified file names.
    private mutating func loadBackgrounds(from fileNames: [String]) throws {
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let backgrounds = try decoder.decode(Backgrounds.self, from: jsonData, configuration: self)
            self.backgrounds.add(backgrounds.all)
        }
    }
    
    /// Loads creature types from the specified file names.
    private mutating func loadCreatureTypes(from fileNames: [String]) throws {
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let creatureTypes = try decoder.decode(CreatureTypes.self, from: jsonData)
            self.creatureTypes.add(creatureTypes.all)
        }
    }
    
    /// Loads species from the specified file names.
    private mutating func loadSpecies(from fileNames: [String]) throws {
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let species = try decoder.decode(Species.self, from: jsonData, configuration: self)
            self.species.add(species)
        }
    }
    
    /// Loads classes from the specified file names.
    private mutating func loadClasses(from fileNames: [String]) throws {
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let classes = try decoder.decode(Classes.self, from: jsonData, configuration: self)
            self.classes.add(classes)
        }
    }
    
    /// Loads players from the specified file names, if provided.
    private mutating func loadPlayers(from fileNames: [String]?) throws {
        guard let fileNames else { return }
        
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let players = try decoder.decode(Players.self, from: jsonData, configuration: self)
            self.players.players += players.players
        }
    }
}
