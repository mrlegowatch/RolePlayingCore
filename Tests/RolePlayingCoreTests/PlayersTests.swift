//
//  PlayersTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/18/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore
import Foundation

@Suite("Players Tests")
struct PlayersTests {
    
    let bundle = Bundle.module
    let decoder = JSONDecoder()
    let skills: Skills
    let backgrounds: Backgrounds
    let classes: Classes
    let species: Species
    
    init() throws {
        // TODO: Need to initialize UnitCurrency before creating Money instances in Player class.
        let currenciesData = try! bundle.loadJSON("TestCurrencies")
        _ = try! decoder.decode(Currencies.self, from: currenciesData)
        
        let skillsData = try! bundle.loadJSON("TestSkills")
        self.skills = try! decoder.decode(Skills.self, from: skillsData)
        
        let backgroundsData = try! bundle.loadJSON("TestBackgrounds")
        self.backgrounds = try! decoder.decode(Backgrounds.self, from: backgroundsData)

        let classesData = try! bundle.loadJSON("TestClasses")
        self.classes = try! decoder.decode(Classes.self, from: classesData)
        
        let speciesData = try! bundle.loadJSON("TestSpecies")
        self.species = try! decoder.decode(Species.self, from: speciesData)
    }
    
    @Test("Load and manipulate players collection")
    func players() async throws {
        let playersData = try bundle.loadJSON("TestPlayers")
        let players = try decoder.decode(Players.self, from: playersData)
        try players.resolve(backgrounds: backgrounds, classes: classes, species: species)
        
        #expect(players.players.count == 2, "players count")
        #expect(players.count == 2, "players count")

        let removedPlayer = try #require(players[0])
        players.remove(at: 0)
        #expect(players.count == 1, "players count")
        
        players.insert(removedPlayer, at: 1)
        #expect(players.count == 2, "players count")
        #expect(players[1]! === removedPlayer, "players count")
    }
    
    @Test("Verify missing or invalid traits cause resolution failure", arguments: [
        "InvalidClassPlayers",
        "InvalidSpeciesPlayers",
        "MissingClassPlayers",
        "MissingSpeciesPlayers"
    ])
    func missingTraits(jsonFile: String) async throws {
        let playersData = try bundle.loadJSON(jsonFile)
        
        // Attempt to decode and resolve, expecting an error to be thrown
        // Error could occur during decoding (missing required fields) or resolution (invalid references)
        do {
            let players = try decoder.decode(Players.self, from: playersData)
            try players.resolve(backgrounds: backgrounds, classes: classes, species: species)
            
            // If we reach here, no error was thrown - the test should fail
            Issue.record("Expected an error to be thrown for \(jsonFile), but none was thrown")
        } catch {
            // Success - an error was thrown as expected
            // Optionally, you could verify the specific error type or message here
        }
    }
}
