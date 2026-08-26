//
//  UnitCurrencyTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Testing
@testable import RolePlayingCore
import Foundation

struct MoneyContainer: DecodableWithConfiguration {
    typealias DecodingConfiguration = Currencies

    let money: Money!

    private enum CodingKeys: String, CodingKey {
        case money
    }

    init(from decoder: any Decoder, configuration: RolePlayingCore.Currencies) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        money = try container.decode(Money.self, forKey: .money, configuration: configuration)
    }
}

@Suite("Currency Tests")
struct UnitCurrencyTests {

    let bundle = Bundle.module
    let decoder = JSONDecoder()
    let currencies: Currencies

    init() throws {
        // Only load once. TODO: this has a side effect on other unit tests: currencies are already loaded.
        let data = try! bundle.loadJSON("TestCurrencies")
        self.currencies = try! decoder.decode(Currencies.self, from: data)
    }

    @Test("Denomination-preserving arithmetic")
    func denominationArithmetic() async throws {
        let gp = currencies["gp"]!
        let sp = currencies["sp"]!
        let ep = currencies["ep"]!

        let wallet = Money(25, of: gp) + Money(12, of: sp) + Money(2, of: ep)
        #expect(wallet[gp] == 25, "gold pieces")
        #expect(wallet[sp] == 12, "silver pieces")
        #expect(wallet[ep] == 2, "electrum pieces")

        // totalValue: 25*1.0 + 12*0.1 + 2*0.5 = 27.2 gp
        #expect(abs(wallet.totalValue - 27.2) < 0.0001, "totalValue should be 27.2 gp")

        // Subtraction removes from the matching denomination only
        let spent = wallet - Money(5, of: gp)
        #expect(spent[gp] == 20, "after spending 5 gp")
        #expect(spent[sp] == 12, "sp unchanged")

        // Subtracting a denomination not present is a no-op
        let cp = currencies["cp"]!
        let afterCp = wallet - Money(1, of: cp)
        #expect(afterCp[cp] == 0, "cp stays zero when not present")
        #expect(afterCp[gp] == 25, "gp unchanged")
    }

    @Test("Money parsing and creation")
    func money() async throws {
        let gp = currencies["gp"]!
        let wallet = Money(2, of: gp)
        #expect(wallet[gp] == 2, "coin count should be 2")
        #expect(wallet.totalValue == 2.0, "totalValue in base currency")

        // parseMoney truncates fractional values to Int
        let cp = "3 cp".parseMoney(currencies)
        let unwrappedCp = try #require(cp, "coinage as cp should not be nil")
        #expect(unwrappedCp[currencies["cp"]!] == 3, "coinage as string cp should be 3")
        #expect(unwrappedCp.quantities[currencies["pp"]!] == nil, "coinage as string cp should not have platinum")

        let invalid = "hello".parseMoney(currencies)
        #expect(invalid == nil, "coinage as string with hello should be nil")
    }

    @Test("Missing currencies file")
    func missingCurrenciesFile() async throws {
        #expect(throws: (any Error).self) {
            _ = try bundle.loadJSON("Blarg")
        }
    }

    @Test("Duplicate currencies are ignored")
    func duplicateCurrencies() async throws {
        #expect(currencies.all.count == 5, "currencies count")

        let data = try bundle.loadJSON("TestCurrencies")
        _ = try decoder.decode(Currencies.self, from: data)

        #expect(currencies.all.count == 5, "currencies count should remain 5")
    }

    @Test("Missing currency traits")
    func missingCurrencyTraits() async throws {
        let decoder = JSONDecoder()

        // Test missing symbol
        let missingSymbol = """
        {
            "currencies": [{"name": "Foo"}]
        }
        """.data(using: .utf8)!
        let currencyNoSymbol = try? decoder.decode(Currencies.self, from: missingSymbol)
        #expect(currencyNoSymbol == nil, "missing symbol")

        // Test symbol with missing coefficient
        let missingCoefficient = """
        {
            "currencies": [{"symbol": "Foo"}]
        }
        """.data(using: .utf8)!
        let currencyNoCoefficient = try? decoder.decode(Currencies.self, from: missingCoefficient)
        #expect(currencyNoCoefficient == nil, "missing coefficient")

        // Test list of items with missing required traits
        let missingTraits = """
        {
             "currencies": [{"name": "Foo"}, {"name": "Bar"}]
        }
        """.data(using: .utf8)!

        #expect(throws: (any Error).self) {
            _ = try decoder.decode(Currencies.self, from: missingTraits)
        }
    }

    @Test("Encoding money")
    func encodingMoney() async throws {
        struct MoneyContainer: Encodable {
            let money: Money

            enum CodingKeys: String, CodingKey {
                case money
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode("\(money)", forKey: .money)
            }
        }

        let moneyContainer = MoneyContainer(money: Money(48, of: currencies["sp"]!))
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(moneyContainer)
        let deserialized = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: String]

        #expect(deserialized?["money"] == "48 sp", "encoded money failed to deserialize as string")
    }

    @Test("Decoding money from keyed object format")
    func decodingMoneyObject() async throws {
        let decoder = JSONDecoder()

        // Keyed object format: {"ep": 72}
        let objectMoney = """
        {
            "money": {"ep": 72}
        }
        """.data(using: .utf8)!
        let objectContainer = try decoder.decode(MoneyContainer.self, from: objectMoney, configuration: currencies)
        #expect(objectContainer.money![currencies["ep"]!] == 72, "Decoded 72 ep from keyed object")
        #expect("\(objectContainer.money!)" == "72 ep", "Description from keyed object")
    }

    @Test("Decoding money from string and number fallbacks")
    func decodingMoney() async throws {
        let decoder = JSONDecoder()

        // Test parseable string — truncated to Int
        let stringMoney = """
        {
            "money": "72 ep"
        }
        """.data(using: .utf8)!
        let stringContainer = try decoder.decode(MoneyContainer.self, from: stringMoney, configuration: currencies)
        #expect("\(stringContainer.money!)" == "72 ep", "Decoded money from string")

        // Test raw number — treated as base currency (gp)
        let numberMoney = """
        {
            "money": 85
        }
        """.data(using: .utf8)!
        let numberContainer = try decoder.decode(MoneyContainer.self, from: numberMoney, configuration: currencies)
        #expect("\(numberContainer.money!)" == "85 gp", "Decoded money from number")

        // Test invalid value
        let invalidMoney = """
        {
            "money": "no money"
        }
        """.data(using: .utf8)!

        #expect(throws: (any Error).self) {
            _ = try decoder.decode(MoneyContainer.self, from: invalidMoney, configuration: currencies)
        }
    }

    @Test("Decoding money encodes back as keyed object")
    func encodingMoneyRoundTrip() async throws {
        struct MoneyWrapper: CodableWithConfiguration {
            typealias EncodingConfiguration = Currencies
            typealias DecodingConfiguration = Currencies

            let money: Money

            enum CodingKeys: String, CodingKey { case money }

            init(from decoder: any Decoder, configuration: Currencies) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                money = try container.decode(Money.self, forKey: .money, configuration: configuration)
            }

            func encode(to encoder: any Encoder, configuration: Currencies) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(money, forKey: .money, configuration: configuration)
            }
        }

        let json = """
        { "money": {"sp": 48} }
        """.data(using: .utf8)!
        let wrapper = try decoder.decode(MoneyWrapper.self, from: json, configuration: currencies)
        #expect(wrapper.money[currencies["sp"]!] == 48, "decoded 48 sp")

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(wrapper, configuration: currencies)
        let dict = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        let moneyDict = try #require(dict["money"] as? [String: Any])
        #expect(moneyDict["sp"] as? Int == 48, "encoded as keyed object with sp: 48")
    }

    @Test("UnitCurrency Equatable uses symbol only")
    func unitCurrencyEquatable() {
        let a = UnitCurrency(symbol: "gp", coefficient: 1.0, name: "gold piece", plural: "gold pieces", isDefault: true)
        let b = UnitCurrency(symbol: "gp", coefficient: 999.0, name: "other", plural: "others", isDefault: false)
        let c = UnitCurrency(symbol: "sp", coefficient: 0.1, name: "silver piece", plural: "silver pieces")
        #expect(a == b, "same symbol is equal regardless of other fields")
        #expect(a != c)
    }

    @Test("UnitCurrency Hashable uses symbol")
    func unitCurrencyHashable() {
        let a = UnitCurrency(symbol: "gp", coefficient: 1.0, name: "gold piece", plural: "gold pieces")
        let b = UnitCurrency(symbol: "gp", coefficient: 2.0, name: "other", plural: "others")
        var h1 = Hasher(); a.hash(into: &h1)
        var h2 = Hasher(); b.hash(into: &h2)
        #expect(h1.finalize() == h2.finalize())
        let set: Set<UnitCurrency> = [a, b]
        #expect(set.count == 1)
    }

    @Test("UnitCurrency encode omits isDefault when false, includes when true")
    func unitCurrencyEncodeIsDefault() async throws {
        let defaultCurrency = UnitCurrency(symbol: "gp", coefficient: 1.0, name: "gold piece", plural: "gold pieces", isDefault: true)
        let nonDefault = UnitCurrency(symbol: "sp", coefficient: 0.1, name: "silver piece", plural: "silver pieces")
        let encoder = JSONEncoder()

        let encodedDefault = try encoder.encode(defaultCurrency)
        let defaultDict = try #require(JSONSerialization.jsonObject(with: encodedDefault) as? [String: Any])
        #expect(defaultDict["is default"] as? Bool == true)

        let encodedNonDefault = try encoder.encode(nonDefault)
        let nonDefaultDict = try #require(JSONSerialization.jsonObject(with: encodedNonDefault) as? [String: Any])
        #expect(nonDefaultDict["is default"] == nil)
    }

    @Test("Money init with zero count produces empty quantities")
    func moneyInitZeroCount() {
        let gp = currencies["gp"]!
        let wallet = Money(0, of: gp)
        #expect(wallet.quantities.isEmpty)
        #expect(wallet[gp] == 0)
    }

    @Test("Money subscript setter: assigning zero removes denomination")
    func subscriptZeroRemovesDenomination() {
        let gp = currencies["gp"]!
        var wallet = Money(10, of: gp)
        wallet[gp] = 0
        #expect(wallet.quantities[gp] == nil)
        #expect(wallet[gp] == 0)
    }

    @Test("Money add accumulates coins and ignores non-positive counts")
    func moneyAdd() {
        let gp = currencies["gp"]!
        var wallet = Money()
        wallet.add(10, of: gp)
        wallet.add(5, of: gp)
        #expect(wallet[gp] == 15)
        wallet.add(0, of: gp)
        wallet.add(-3, of: gp)
        #expect(wallet[gp] == 15, "zero and negative counts are no-ops")
    }

    @Test("Money spend reduces coins, removes denomination at zero, throws when insufficient")
    func moneySpend() async throws {
        let gp = currencies["gp"]!
        var wallet = Money(10, of: gp)
        try wallet.spend(4, of: gp)
        #expect(wallet[gp] == 6)
        try wallet.spend(6, of: gp)
        #expect(wallet.quantities[gp] == nil, "denomination removed when fully spent")
        #expect(wallet[gp] == 0)
    }

    @Test("Money spend throws insufficientFunds and leaves wallet unchanged")
    func moneySpendInsufficientFunds() {
        let gp = currencies["gp"]!
        var wallet = Money(3, of: gp)
        #expect(throws: MoneyError.insufficientFunds) {
            try wallet.spend(5, of: gp)
        }
        #expect(wallet[gp] == 3, "wallet unchanged after failed spend")
    }

    @Test("Money description: no coins and no base shows '0 ?'")
    func descriptionNoCurrencyNoBase() {
        let wallet = Money()
        #expect("\(wallet)" == "0 ?")
    }

    @Test("Money description: no coins but has base shows '0 <symbol>'")
    func descriptionNoCurrencyHasBase() {
        let gp = currencies["gp"]!
        let wallet = Money(0, of: gp)
        #expect("\(wallet)" == "0 gp")
    }

    @Test("Money totalValue(relativeTo:) uses the provided unit")
    func totalValueRelativeTo() {
        let gp = currencies["gp"]!
        let sp = currencies["sp"]!
        // 10 gp at coefficient 1.0, sp at coefficient 0.1 → 10 * 1.0 / 0.1 = 100 sp
        let wallet = Money(10, of: gp)
        #expect(abs(wallet.totalValue(relativeTo: sp) - 100.0) < 0.0001)
    }

    @Test("Money Equatable compares quantities")
    func moneyEquatable() {
        let gp = currencies["gp"]!
        let sp = currencies["sp"]!
        let a = Money(10, of: gp)
        let b = Money(10, of: gp)
        let c = Money(10, of: sp)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Decoding money with unknown currency symbol throws")
    func decodingUnknownSymbol() {
        let data = """
        { "money": {"xyz": 100} }
        """.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            _ = try decoder.decode(MoneyContainer.self, from: data, configuration: currencies)
        }
    }

    @Test("Encoding currencies")
    func encodeCurrencies() async throws {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(currencies)
        let deserialized = try #require(
            JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any],
            "Failed to deserialize encoded currencies"
        )

        let currenciesArray = try #require(
            deserialized["currencies"] as? [[String: Any]],
            "Failed to get currencies array"
        )
        #expect(currenciesArray.count == 5, "5 currencies")
    }
}
