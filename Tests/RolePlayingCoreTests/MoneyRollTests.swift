//
//  MoneyRollTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/5/26.
//  Copyright © 2026 Brian Arnold. Licensed under the MIT License.
//

import Testing
@testable import RolePlayingCore
import Foundation
import SwiftDice

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

    @Test("Default init produces an empty MoneyRoll with no base")
    func defaultInitIsEmpty() async throws {
        let moneyRoll = MoneyRoll()
        #expect(moneyRoll.isEmpty)
        #expect(moneyRoll.base == nil)
        #expect("\(moneyRoll)" == "0 ?")
    }

    @Test("Init with quantities keeps dice expressions and positive constants, drops zero and negative constants")
    func initWithQuantitiesFiltersNonPositiveConstants() async throws {
        let gp = currencies["gp"]!
        let sp = currencies["sp"]!
        let cp = currencies["cp"]!
        let ep = currencies["ep"]!
        let dice = try AnyRollable(parsing: "d6")

        let moneyRoll = MoneyRoll([
            gp: AnyRollable(5),
            sp: AnyRollable(0),
            cp: AnyRollable(-3),
            ep: dice
        ])

        #expect(moneyRoll[gp]?.constant == 5, "positive constants are kept")
        #expect(moneyRoll[sp] == nil, "zero constant is dropped")
        #expect(moneyRoll[cp] == nil, "negative constant is dropped")
        #expect(moneyRoll[ep] == dice, "dice expressions are kept regardless of sign")
    }

    @Test("Init with quantities sets base from the isDefault currency, or nil when none is default")
    func initWithQuantitiesSetsBase() async throws {
        let gp = currencies["gp"]!
        let sp = currencies["sp"]!
        let cp = currencies["cp"]!

        let withDefault = MoneyRoll([sp: AnyRollable(5), gp: AnyRollable(10)])
        #expect(withDefault.base == gp)

        let withoutDefault = MoneyRoll([sp: AnyRollable(5), cp: AnyRollable(3)])
        #expect(withoutDefault.base == nil)
    }

    @Test("Init from Money skips non-positive counts")
    func initFromMoneySkipsNonPositiveCounts() async throws {
        let gp = currencies["gp"]!
        let sp = currencies["sp"]!
        let money = Money([gp: 10, sp: 0])

        let moneyRoll = MoneyRoll(money)
        #expect(moneyRoll[gp]?.constant == 10)
        #expect(moneyRoll[sp] == nil)
    }

    @Test("isEmpty reflects whether quantities is empty")
    func isEmptyReflectsQuantities() async throws {
        let gp = currencies["gp"]!
        var moneyRoll = MoneyRoll()
        #expect(moneyRoll.isEmpty)

        moneyRoll[gp] = AnyRollable(5)
        #expect(!moneyRoll.isEmpty)
    }

    @Test("Subscript set adds, updates, and removes a denomination")
    func subscriptSetAddsUpdatesRemoves() async throws {
        let gp = currencies["gp"]!
        var moneyRoll = MoneyRoll()
        #expect(moneyRoll[gp] == nil)

        moneyRoll[gp] = AnyRollable(5)
        #expect(moneyRoll[gp]?.constant == 5)

        moneyRoll[gp] = AnyRollable(9)
        #expect(moneyRoll[gp]?.constant == 9, "setting again updates the value")

        moneyRoll[gp] = nil
        #expect(moneyRoll[gp] == nil, "setting nil removes the denomination")
        #expect(moneyRoll.isEmpty)
    }

    @Test("fixed is an empty Money when quantities is empty")
    func fixedIsEmptyMoneyWhenEmpty() async throws {
        let moneyRoll = MoneyRoll()
        let fixed = try #require(moneyRoll.fixed)
        #expect(fixed.quantities.isEmpty)
    }

    @Test("roll() drops denominations that roll to zero or less")
    func rollDropsNonPositiveResults() async throws {
        let gp = currencies["gp"]!
        var moneyRoll = MoneyRoll()
        moneyRoll[gp] = AnyRollable(-5)

        let rolled = moneyRoll.roll()
        #expect(rolled.quantities.isEmpty)
        #expect(rolled[gp] == 0)
    }

    @Test("Equality compares quantities only, ignoring base")
    func equalityIgnoresBase() async throws {
        let gp = currencies["gp"]!
        var a = MoneyRoll([gp: AnyRollable(5)])
        var b = MoneyRoll([gp: AnyRollable(5)])
        a.base = nil
        b.base = currencies["sp"]!
        #expect(a == b)
    }

    @Test("Equal MoneyRoll values hash the same")
    func equalValuesHashTheSame() async throws {
        let gp = currencies["gp"]!
        let a = MoneyRoll([gp: AnyRollable(5)])
        let b = MoneyRoll([gp: AnyRollable(5)])
        #expect(a.hashValue == b.hashValue)
    }

    @Test("Encoding and decoding an empty MoneyRoll round trips")
    func emptyRoundTrip() async throws {
        let moneyRoll = MoneyRoll()
        let encoded = try encoder.encode(moneyRoll, configuration: currencies)
        let decoded = try decoder.decode(MoneyRoll.self, from: encoded, configuration: currencies)
        #expect(decoded.isEmpty)
        #expect(decoded.base == currencies.baseUnit)
    }
}
