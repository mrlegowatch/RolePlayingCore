//
//  GameData.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

// MARK: - Game Data Files

/// Represents a collection of JSON file names that belong to a bundle.
/// Used by `GameData` to determine which files to load.
public struct GameDataFiles: Decodable, Sendable {
    let currencies: [String]
    let skills: [String]
    let feats: [String]?
    let spells: [String]?
    let items: [String]?
    let backgrounds: [String]
    let creatureTypes: [String]
    let species: [String]
    let classes: [String]
    let players: [String]?
    let speciesNames: String?

    private enum CodingKeys: String, CodingKey {
        case currencies
        case skills
        case feats
        case spells
        case items
        case backgrounds
        case creatureTypes = "creature types"
        case species
        case classes
        case players
        case speciesNames = "species names"
    }
}

// MARK: - GameData

/// Configure a client's data from a framework or application bundle.
///
/// This type manages the loading and organization of game data including currencies,
/// skills, backgrounds, creature types, species, classes, and players from JSON files.
public struct GameData {
    let bundle: Bundle
    let decoder = JSONDecoder()
    public private(set) var gameDataFiles: GameDataFiles
    
    public private(set) var currencies = Currencies()
    public private(set) var skills = Skills()
    public private(set) var feats = Feats()
    public private(set) var spells = Spells()
    public private(set) var items = Items()
    public private(set) var backgrounds = Backgrounds()
    public private(set) var creatureTypes = CreatureTypes()
    public private(set) var species = Species()
    public private(set) var classes = Classes()
    public private(set) var players = Players()
    
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
        self.gameDataFiles = try decoder.decode(GameDataFiles.self, from: data)
        try self.load(gameDataFiles)
    }
    
    // MARK: - Loading Methods
    
    /// Loads all configuration data from the specified configuration files.
    ///
    /// - Parameter gameDataFiles: The configuration files structure containing file names.
    /// - Throws: An error if any file cannot be loaded or decoded.
    mutating func load(_ gameDataFiles: GameDataFiles) throws {
        try loadCurrencies(from: gameDataFiles.currencies)
        try loadSkills(from: gameDataFiles.skills)
        try loadFeats(from: gameDataFiles.feats)
        try loadSpells(from: gameDataFiles.spells)
        try loadItems(from: gameDataFiles.items)
        try loadBackgrounds(from: gameDataFiles.backgrounds)
        try loadCreatureTypes(from: gameDataFiles.creatureTypes)
        try loadSpecies(from: gameDataFiles.species)
        try loadClasses(from: gameDataFiles.classes)
        try loadPlayers(from: gameDataFiles.players)
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

    /// Loads feats from the specified file names, if provided.
    private mutating func loadFeats(from fileNames: [String]?) throws {
        guard let fileNames else { return }
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let feats = try decoder.decode(Feats.self, from: jsonData)
            self.feats.add(feats.all)
        }
    }

    /// Loads spells from the specified file names, if provided.
    private mutating func loadSpells(from fileNames: [String]?) throws {
        guard let fileNames else { return }
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let spells = try decoder.decode(Spells.self, from: jsonData)
            self.spells.add(spells.all)
        }
    }

    /// Loads items from the specified file names, if provided.
    private mutating func loadItems(from fileNames: [String]?) throws {
        guard let fileNames else { return }
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let items = try decoder.decode(Items.self, from: jsonData, configuration: self)
            self.items.add(items)
        }
    }
    
    /// Loads backgrounds from the specified file names.
    private mutating func loadBackgrounds(from fileNames: [String]) throws {
        for fileName in fileNames {
            let jsonData = try bundle.loadJSON(fileName)
            let backgrounds = try decoder.decode(Backgrounds.self, from: jsonData, configuration: self)
            self.backgrounds.add(backgrounds)
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
