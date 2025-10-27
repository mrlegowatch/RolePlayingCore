//
//  PlayersTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/18/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore

class PlayersTests: XCTestCase {
    
    let bundle = Bundle(for: PlayersTests.self)
    let decoder = JSONDecoder()
    
    var backgrounds: Backgrounds!
    var classes: Classes!
    var species: Species!
    
    override func setUp() {
        // TODO: Need to initialize UnitCurrency before creating Money instances in Player class.
        let currenciesData = try! bundle.loadJSON("TestCurrencies")
        _ = try! decoder.decode(Currencies.self, from: currenciesData)
        
        let backgroundsData = try! bundle.loadJSON("TestBackgrounds")
        backgrounds = try! decoder.decode(Backgrounds.self, from: backgroundsData)
        
        let classesData = try! bundle.loadJSON("TestClasses")
        classes = try! decoder.decode(Classes.self, from: classesData)
        
        let speciesData = try! bundle.loadJSON("TestSpecies")
        species = try! decoder.decode(Species.self, from: speciesData)
    }
    
    func testPlayers() {
        
        var players: Players! = nil
        do {
            let playersData = try bundle.loadJSON("TestPlayers")
            players = try decoder.decode(Players.self, from: playersData)
            try players.resolve(backgrounds: backgrounds, classes: classes, species: species)
        }
        catch let error {
            XCTFail("players.load failed, error \(error)")
        }
        XCTAssertEqual(players.players.count, 2, "players count")
        XCTAssertEqual(players.count, 2, "players count")

        let removedPlayer = players[0]!
        players.remove(at: 0)
        XCTAssertEqual(players.count, 1, "players count")
        
        players.insert(removedPlayer, at: 1)
        XCTAssertEqual(players.count, 2, "players count")
        XCTAssertTrue(players[1]! === removedPlayer, "players count")
    }
    
    func testMissingTraits() {
        do {
            let playersData = try! bundle.loadJSON("InvalidClassPlayers")
            let players = try decoder.decode(Players.self, from: playersData)
            try players.resolve(backgrounds: backgrounds, classes: classes, species: species)
            XCTFail("players.load should have failed")
        }
        catch let error {
            print("players.load correctly threw an error \(error)")
        }
        
        do {
            let playersData = try! bundle.loadJSON("InvalidSpeciesPlayers")
            let players = try decoder.decode(Players.self, from: playersData)
            try players.resolve(backgrounds: backgrounds, classes: classes, species: species)
            XCTFail("players.resolve should have failed")
        }
        catch let error {
            print("players.resolve correctly threw an error \(error)")
        }
        
        do {
            let playersData = try! bundle.loadJSON("MissingClassPlayers")
            let players = try decoder.decode(Players.self, from: playersData)
            try players.resolve(backgrounds: backgrounds, classes: classes, species: species)
            XCTFail("players.resolve should have failed")
        }
        catch let error {
            print("players.resolve correctly threw an error \(error)")
        }
        
        do {
            let playersData = try! bundle.loadJSON("MissingSpeciesPlayers")
            let players = try decoder.decode(Players.self, from: playersData)
            try players.resolve(backgrounds: backgrounds, classes: classes, species: species)
            
            XCTFail("players.resolve should have failed")
        }
        catch let error {
            print("players.resolve correctly threw an error \(error)")
        }
    }
    
    
}
