//
//  MoneyRollTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/5/26.
//  Copyright © 2026 Brian Arnold. All rights reserved.
//

import Testing
@testable import RolePlayingCore
import Foundation

@Suite("MoneyRoll Tests")
struct MoneyRollTests {

    let bundle = Bundle.module
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let currencies: Currencies

    init() throws {
        let data = try! bundle.loadJSON("TestCurrencies")
        self.currencies = try! decoder.decode(Currencies.self, from: data)
    }

    @Test("Decoding dice notation leaves fixed nil")
    func decodingDiceNotation() async throws {
        let json = """
        { "gp": "d10", "sp": "2d8" }
        """.data(using: .utf8)!

        let moneyRoll = try decoder.decode(MoneyRoll.self, from: json, configuration: currencies)
        #expect(moneyRoll.fixed == nil, "dice expressions are not fixed")
        #expect("\(moneyRoll)" == "d10 gp 2d8 sp", "description shows highest coefficient first")
    }

    @Test("Decoding all constants makes fixed equal the same Money")
    func decodingAllConstants() async throws {
        let json = """
        { "cp": 175, "sp": 65, "ep": 29, "gp": 35 }
        """.data(using: .utf8)!

        let moneyRoll = try decoder.decode(MoneyRoll.self, from: json, configuration: currencies)
        let gp = currencies["gp"]!
        let sp = currencies["sp"]!
        let ep = currencies["ep"]!
        let cp = currencies["cp"]!
        let expected = Money([gp: 35, sp: 65, ep: 29, cp: 175])

        let fixed = try #require(moneyRoll.fixed, "all constants should produce a fixed Money")
        #expect(fixed == expected)
        #expect(abs(fixed.totalValue - 57.75) < 0.0001, "totalValue should be 57.75 gp")
    }

    @Test("Unknown currency symbol throws")
    func unknownSymbolThrows() async throws {
        let json = """
        { "zz": 3 }
        """.data(using: .utf8)!

        #expect(throws: (any Error).self) {
            _ = try decoder.decode(MoneyRoll.self, from: json, configuration: currencies)
        }
    }

    @Test("Bad dice notation throws")
    func badDiceNotationThrows() async throws {
        let json = """
        { "gp": "banana" }
        """.data(using: .utf8)!

        #expect(throws: (any Error).self) {
            _ = try decoder.decode(MoneyRoll.self, from: json, configuration: currencies)
        }
    }

    @Test("Round trip encode then decode")
    func roundTrip() async throws {
        let json = """
        { "gp": "d10", "cp": 175 }
        """.data(using: .utf8)!

        let moneyRoll = try decoder.decode(MoneyRoll.self, from: json, configuration: currencies)
        let encoded = try encoder.encode(moneyRoll, configuration: currencies)

        let decoded = try decoder.decode(MoneyRoll.self, from: encoded, configuration: currencies)
        #expect(decoded == moneyRoll)

        let dict = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        #expect(dict["gp"] as? String == "d10")
        #expect(dict["cp"] as? Int == 175)
    }

    @Test("roll() stays within the dice range and only has that denomination")
    func rollStaysInRange() async throws {
        let json = """
        { "gp": "d6" }
        """.data(using: .utf8)!
        let moneyRoll = try decoder.decode(MoneyRoll.self, from: json, configuration: currencies)
        let gp = currencies["gp"]!

        for _ in 0..<200 {
            let rolled = moneyRoll.roll()
            #expect(rolled.quantities.count == 1, "only gp should be present")
            let amount = rolled[gp]
            #expect((1...6).contains(amount), "d6 gp should stay within 1...6")
        }
    }

    @Test("Init from Money round trips through fixed")
    func initFromMoney() async throws {
        let gp = currencies["gp"]!
        let sp = currencies["sp"]!
        let money = Money([gp: 14, sp: 6])

        let moneyRoll = MoneyRoll(money)
        #expect(moneyRoll.fixed == money)
    }

    @Test("Zero constants are dropped")
    func zeroConstantsDropped() async throws {
        let json = """
        { "gp": 0, "sp": 4 }
        """.data(using: .utf8)!

        let moneyRoll = try decoder.decode(MoneyRoll.self, from: json, configuration: currencies)
        #expect(moneyRoll.quantities.count == 1)
        let sp = currencies["sp"]!
        #expect(moneyRoll[sp]?.constant == 4)
    }
}
