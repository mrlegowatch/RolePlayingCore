//
//  GameDataErrorTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
import RolePlayingCore

@Suite("Game Data Error Tests")
struct GameDataErrorTests {
    
    @Test("Verify GameDataError contains expected information")
    func configurationError() async throws {
        do {
            throw missingFileError("Foo.json", "MyBundle")
        } catch {
            #expect(error is GameDataError, "should be a configuration error")
            let description = "\(error)"
            #expect(description.contains("Configuration error"), "should be a configuration error")
            #expect(description.contains("Foo.json"), "should contain the message")
            #expect(description.contains("configurationError"), "should have throw function name in it")
            #expect(description.contains("GameDataErrorTests"), "should have throw file name in it")
        }
    }

    @Test("missingJSONError contains expected information")
    func missingJSONError() async throws {
        do {
            throw RolePlayingCore.missingJSONError("species")
        } catch {
            #expect(error is GameDataError, "should be a GameDataError")
            let description = "\(error)"
            #expect(description.contains("Configuration error"))
            #expect(description.contains("species"))
            #expect(description.contains("missingJSONError"))
        }
    }

    @Test("missingTypeError contains expected information")
    func missingTypeError() async throws {
        do {
            throw RolePlayingCore.missingTypeError("class", "Fighter")
        } catch {
            #expect(error is GameDataError, "should be a GameDataError")
            let description = "\(error)"
            #expect(description.contains("Configuration error"))
            #expect(description.contains("class"))
            #expect(description.contains("Fighter"))
            #expect(description.contains("missingTypeError"))
        }
    }

    @Test("GameDataError cases are distinct")
    func configurationErrorCases() {
        let file = GameDataError.missingFile("a.json", "Bundle", "loc")
        let json = GameDataError.missingJSON("species", "loc")
        let type_ = GameDataError.missingType("class", "Fighter", "loc")

        #expect(file.description.contains("Missing file"))
        #expect(json.description.contains("Missing species"))
        #expect(type_.description.contains("Could not resolve"))
    }
}
