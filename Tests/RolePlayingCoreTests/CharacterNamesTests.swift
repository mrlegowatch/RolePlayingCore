//
//  CharacterNamesTests.swift
//  RolePlayingCoreTests
//
//  Created by Brian Arnold on 7/8/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
@testable import RolePlayingCore
import Foundation

@Suite("Character Names")
struct CharacterNamesTests {
    
    let gameData: GameData
    
    init() throws {
        gameData = try GameData("TestConfiguration", from: .module)
    }
    
    @Test("Loading and generating species names")
    func characterNames() async throws {
        let bundle = Bundle.module
        let data = try bundle.loadJSON("TestCharacterNames")
        let decoder = JSONDecoder()
        let characterNames = try decoder.decode(CharacterNames.self, from: data)
        
        #expect(characterNames.names.count == 8, "Number of species name families")
        
        // TODO: find a way to test just the minimum functionality.
        // In the meantime, use the test species.
        let jsonData = try bundle.loadJSON("TestSpecies")
        let species = try decoder.decode(Species.self, from: jsonData, configuration: gameData)
        let moreJsonData = try bundle.loadJSON("TestMoreSpecies")
        let moreSpecies = try decoder.decode(Species.self, from: moreJsonData, configuration: gameData)
        
        let allSpecies = Species()
        allSpecies.add(species.all + moreSpecies.all)
        
        // TODO: random names are hard; for now, get code coverage.
        let human = try #require(allSpecies["Human"])
        _ = characterNames.randomName(speciesTraits: human, gender: .female)
        
        let elf = try #require(allSpecies["Elf"])
        _ = characterNames.randomName(speciesTraits: elf, gender: .male)
        
        let mountainDwarf = try #require(allSpecies["Mountain Dwarf"])
        _ = characterNames.randomName(speciesTraits: mountainDwarf, gender: nil)
        
        let stout = try #require(allSpecies["Stout"])
        _ = characterNames.randomName(speciesTraits: stout, gender: nil)
        
        let dragonborn = try #require(allSpecies["Dragonborn"])
        _ = characterNames.randomName(speciesTraits: dragonborn, gender: nil)
        
        let tiefling = try #require(allSpecies["Tiefling"])
        _ = characterNames.randomName(speciesTraits: tiefling, gender: nil)
        
        let encoder = JSONEncoder()
        _ = try encoder.encode(characterNames)
    }
}
