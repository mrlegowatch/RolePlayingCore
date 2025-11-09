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
    let configuration: Configuration
    
    init() throws {
        configuration = try Configuration("TestConfiguration", from: .module)
    }
    
    @Test("Load and manipulate players collection")
    func players() async throws {
        let playersData = try bundle.loadJSON("TestPlayers")
        let players = try decoder.decode(Players.self, from: playersData, configuration: configuration)
        
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
        
        // Attempt to decode, expecting an error to be thrown during decoding
        // since all trait resolution now happens during the decoding phase
        do {
            _ = try decoder.decode(Players.self, from: playersData, configuration: configuration)
            
            // If we reach here, no error was thrown - the test should fail
            Issue.record("Expected an error to be thrown for \(jsonFile), but none was thrown")
        } catch {
            // Success - an error was thrown as expected
            // Optionally, you could verify the specific error type or message here
        }
    }
}
