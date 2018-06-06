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
    
    func randomAlignment() -> Alignment {
        let ethics = Ethics.allCases.randomElement()!
        let morals = Morals.allCases.randomElement()!
        return Alignment(ethics, morals)
    }
    
    public func makeCharacter() -> Player {
        // TODO: have RacialTraits, ClassTraits conform to whatever specifies the random() protocol
        
        let randomRace = Int.random(in: 0..<configuration.races.count)
        let randomClass = Int.random(in: 0..<configuration.classes.count)
        let gender = Player.Gender.allCases.randomElement()
        
        let racialTraits = configuration.races[randomRace]!
        let classTraits = configuration.classes[randomClass]!
        let name = names.randomName(racialTraits: racialTraits, gender: gender)
        let alignment = racialTraits.alignment != nil ? racialTraits.alignment : randomAlignment()

        return Player(name, racialTraits: racialTraits, classTraits: classTraits, gender: gender, alignment: alignment)
    }
}
