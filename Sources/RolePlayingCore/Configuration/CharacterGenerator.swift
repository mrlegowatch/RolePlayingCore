//
//  CharacterGenerator.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// Given a configuration of species traits and class traits,
/// provides a random character.
public struct CharacterGenerator {
    let configuration: Configuration
    let names: SpeciesNames
    
    /// Creates a character generator instance with a reference to the current configuration.
    public init(_ configuration: Configuration, from bundle: Bundle = .main) throws {
        guard let speciesNamesFile = configuration.configurationFiles.speciesNames else {
            throw RuntimeError("Missing speciesNames file name in configuration file")
        }
        
        self.configuration = configuration
        let data = try bundle.loadJSON(speciesNamesFile)
        let decoder = JSONDecoder()
        self.names = try decoder.decode(SpeciesNames.self, from: data)
    }
    
    // TODO: support non-uniform distributions for different traits (e.g., some species and classes tend to have specific alignments)
    
    func randomAlignment<G: RandomIndexGenerator>(using generator: inout G) -> Alignment {
        let ethics = Ethics.allCases.randomElementByIndex(using: &generator)!
        let morals = Morals.allCases.randomElementByIndex(using: &generator)!
        return Alignment(ethics, morals)
    }
    
    public func makeCharacter<G: RandomIndexGenerator>(using generator: inout G) -> Player {
        // TODO: have SpeciesTraits, ClassTraits conform to whatever protocol specifies the random() function
        let randomClass = generator.randomIndex(upperBound: configuration.classes.count)
        let gender = Player.Gender.allCases.randomElementByIndex(using: &generator)
        
        let backgroundTraits = configuration.backgrounds.randomElementByIndex(using: &generator)
        let speciesTraits = configuration.species.randomElementByIndex(using: &generator)
        let classTraits = configuration.classes[randomClass]!
        let name = names.randomName(speciesTraits: speciesTraits, gender: gender, using: &generator)
        let alignment = randomAlignment(using: &generator)
        
        return Player(name, backgroundTraits: backgroundTraits, speciesTraits: speciesTraits, classTraits: classTraits, gender: gender, alignment: alignment)
    }
    
    public func makeCharacter() -> Player {
        var generator = DefaultRandomIndexGenerator()
        return makeCharacter(using: &generator)
    }
}
