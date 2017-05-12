//
//  Configuration.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 3/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

// TODO: this needs a better name.

/// This is designed to configure a client.
public class Configuration {
    
    public internal(set) var races = Races()
    
    public internal(set) var classes = Classes()
    
    /// Creates configuration from the specified races file.
    public init(_ configurationFile: String, in bundle: Bundle = .main) throws  {
        try load(configurationFile, in: bundle)
    }
    
    /// Adds races from the specified races file.
    public func load(_ configurationFile: String, in bundle: Bundle = .main) throws {
        let jsonObject = try bundle.loadJSON(configurationFile)
        try load(from: jsonObject, in: bundle)
    }

    public func load(from dictionary: [String: Any], in bundle: Bundle = .main) throws {
        
        // Configure currencies
        if let currencyFiles = dictionary[Trait.currencies] as? [String] {
            for currencyFile in currencyFiles {
                try UnitCurrency.load(currencyFile, in: bundle)
            }
        }
        
        /// Load races
        if let racesFiles = dictionary[Trait.races] as? [String] {
            for racesFile in racesFiles {
                try races.load(racesFile, in: bundle)
            }
        }
        
        /// Load classes
        if let classesFiles = dictionary[Trait.classes] as? [String] {
            for classesFile in classesFiles {
                try classes.load(classesFile, in: bundle)
            }
        }
    }
}
