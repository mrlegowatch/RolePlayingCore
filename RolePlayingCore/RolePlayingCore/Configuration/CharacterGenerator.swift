//
//  CharacterGenerator.swift
//  CharacterGenerator
//
//  Created by Brian Arnold on 7/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// Given a configuration of racial traits and class traits,
/// provides a random character.
public struct CharacterGenerator {
    
    let configuration: Configuration
    
    let names: RacialNames
    
    /// Creates a character generator instance with a reference to the current configuration.
    public init(_ configuration: Configuration, from bundle: Bundle = .main) throws {
        guard let racialNamesFile = configuration.configurationFiles.racialNames else {
            throw RuntimeError("Missing racialNames file name in configuration file")
        }
        
        self.configuration = configuration
        let data = try bundle.loadJSON(racialNamesFile)
        let decoder = JSONDecoder()
        self.names = try decoder.decode(RacialNames.self, from: data)
    }
    
    // TODO: support non-uniform distributions for different traits (e.g., some races and classes tend to have specific alignments)
    
    func randomAlignment<G: RandomNumberGenerator>(using generator: inout G) -> Alignment {
        let ethics = Ethics.allCases.randomElement(using: &generator)!
        let morals = Morals.allCases.randomElement(using: &generator)!
        return Alignment(ethics, morals)
    }
    
    public func makeCharacter<G: RandomNumberGenerator>(using generator: inout G) -> Player {
        // TODO: have RacialTraits, ClassTraits conform to whatever protocol specifies the random() function
        
        let randomRace = Int.random(in: 0..<configuration.races.count, using: &generator)
        let randomClass = Int.random(in: 0..<configuration.classes.count, using: &generator)
        let gender = Player.Gender.allCases.randomElement(using: &generator)
        
        let racialTraits = configuration.races[randomRace]!
        let classTraits = configuration.classes[randomClass]!
        let name = names.randomName(racialTraits: racialTraits, gender: gender, using: &generator)
        let alignment = racialTraits.alignment != nil ? racialTraits.alignment : randomAlignment(using: &generator)
        
        return Player(name, racialTraits: racialTraits, classTraits: classTraits, gender: gender, alignment: alignment)
    }
    
    public func makeCharacter() -> Player {
        return makeCharacter(using: &Random.default)
    }
}
