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
    
    // TODO: support non-uniform distributions for different traits
    
    static let randomNumberGenerator: RandomNumberGenerator = DefaultRandomNumberGenerator()
    
    func random(_ upperBound: Int) -> Int {
        return CharacterGenerator.randomNumberGenerator.random(upperBound)
    }
    
    func randomAlignment() -> Alignment {
        let ethics: Ethics
        switch random(3) {
        case 0: ethics = .chaotic
        case 2: ethics = .lawful
        default:  ethics = .neutral
        }
        
        let morals: Morals
        switch random(3) {
        case 0: morals = .evil
        case 2: morals = .good
        default:  morals = .neutral
        }
        
        return Alignment(ethics, morals)
    }
    
    public func makeCharacter() -> Player {
        let randomRace = random(configuration.races.count)
        let randomClass = random(configuration.classes.count)
        let gender: Player.Gender = random(2) == 0 ? .male : .female
        
        let racialTraits = configuration.races[randomRace]!
        let classTraits = configuration.classes[randomClass]!
        let name = names.randomName(racialTraits: racialTraits, gender: gender)
        let alignment = racialTraits.alignment != nil ? racialTraits.alignment : randomAlignment()

        return Player(name, racialTraits: racialTraits, classTraits: classTraits, gender: gender, alignment: alignment)
    }
}
