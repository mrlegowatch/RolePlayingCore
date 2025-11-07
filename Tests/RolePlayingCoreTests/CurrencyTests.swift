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
    
    @Test("Unit currency calculations")
    func unitCurrency() async throws {
        #expect(UnitCurrency.baseUnit() == Currencies.find("gp"), "base unit should be goldPieces")
        
        let goldPieces = Money(value: 25, unit: Currencies.find("gp")!)
        let silverPieces = Money(value: 12, unit: Currencies.find("sp")!)
        let copperPieces = Money(value: 1, unit: Currencies.find("cp")!)
        let electrumPieces = Money(value: 2, unit: Currencies.find("ep")!)
        let platinumPieces = Money(value: 2, unit: Currencies.find("pp")!)
        
        let totalPieces = goldPieces + silverPieces - copperPieces + electrumPieces - platinumPieces
        
        // Should be 25 + 1.2 - 0.01 + 1 - 20
        #expect(abs(totalPieces.value - 7.19) < 0.0001, "adding coins should equal 7.19")
        
        let totalPiecesInCopper = totalPieces.converted(to: Currencies.find("cp")!)
        #expect(abs(totalPiecesInCopper.value - 719) < 0.01, "adding coins converted to copper should equal 719")
    }
    
    @Test("Printing currency values")
    func printingValues() async throws {
        let goldPieces = Money(value: 13.7, unit: .baseUnit())
        
        let formatter = MeasurementFormatter()
        
        // Test default
        let gp = formatter.string(from: goldPieces)
        #expect(gp == "13.7 gp", "gold pieces")
        
        // Test provided unit
        formatter.unitOptions = [.providedUnit]
        let gpDefault = formatter.string(from: goldPieces)
        #expect(gpDefault == "13.7 gp", "gold pieces")
        
        let silverPieces = goldPieces.converted(to: Currencies.find("sp")!)
        let sp = formatter.string(from: silverPieces)
        #expect(sp == "137 sp", "silver pieces")
        
        let platinumPieces = goldPieces.converted(to: Currencies.find("pp")!)
        let ppProvided = formatter.string(from: platinumPieces)
        #expect(ppProvided == "1.37 pp", "platinum pieces")
        
        // Test natural scale
        formatter.unitOptions = [.naturalScale]
        let ppNatural = formatter.string(from: platinumPieces)
        #expect(ppNatural == "13.7 gp", "gold pieces")
        
        formatter.unitOptions = [.providedUnit]
        
        // Test short
        formatter.unitStyle = .short
        let gpShort = formatter.string(from: goldPieces)
        #expect(gpShort == "13.7gp", "gold pieces")
        
        // Test long
        formatter.unitStyle = .long
        let gpLong = formatter.string(from: goldPieces)
        #expect(gpLong == "13.7 gold pieces", "gold pieces")
        
        let gpSingularLong = formatter.string(from: Money(value: 1.0, unit: .baseUnit()))
        #expect(gpSingularLong == "1 gold piece", "gold piece")
    }
    
    @Test("Money parsing and creation")
    func money() async throws {
        let gp = Money(value: 2.5, unit: .baseUnit())
        #expect(gp.value == 2.5, "coinage as Double should be 2.5")
        
        let cp = "3.2 cp".parseMoney
        let unwrappedCp = try #require(cp, "coinage as cp should not be nil")
        #expect(abs(unwrappedCp.value - 3.2) < 0.0001, "coinage as string cp should be 3.2")
        #expect(unwrappedCp.unit == Currencies.find("cp"), "coinage as string cp should be copper pieces")
        #expect(unwrappedCp.unit != Currencies.find("pp"), "coinage as string cp should not be platinum pieces")
        
        let invalid = "hello".parseMoney
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
        #expect(Currencies.allValues().count == 5, "currencies count")
        
        let data = try bundle.loadJSON("TestCurrencies")
        _ = try decoder.decode(Currencies.self, from: data)
        
        #expect(Currencies.allValues().count == 5, "currencies count should remain 5")
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
        
        let moneyContainer = MoneyContainer(money: Money(value: 48.93, unit: Currencies.find("sp")!))
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(moneyContainer)
        let deserialized = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: String]
        
        #expect(deserialized?["money"] == "48.93 sp", "encoded money failed to deserialize as string")
    }
    
    @Test("Decoding money from string and number")
    func decodingMoney() async throws {
        struct MoneyContainer: Decodable {
            let money: Money
        }
        let decoder = JSONDecoder()
        
        // Test parseable string
        let stringMoney = """
        {
            "money": "72.17 ep"
        }
        """.data(using: .utf8)!
        let stringContainer = try decoder.decode(MoneyContainer.self, from: stringMoney)
        #expect("\(stringContainer.money)" == "72.17 ep", "Decoded money from string")
        
        // Test raw number
        let numberMoney = """
        {
            "money": 85
        }
        """.data(using: .utf8)!
        let numberContainer = try decoder.decode(MoneyContainer.self, from: numberMoney)
        #expect("\(numberContainer.money)" == "85.0 gp", "Decoded money from number")
        
        // Test invalid value
        let invalidMoney = """
        {
            "money": "no money"
        }
        """.data(using: .utf8)!
        
        #expect(throws: (any Error).self) {
            _ = try decoder.decode(MoneyContainer.self, from: invalidMoney)
        }
    }
    
    @Test("Decoding optional money")
    func decodingMoneyIfPresent() async throws {
        struct MoneyContainer: Decodable {
            let money: Money?
        }
        let decoder = JSONDecoder()
        
        // Test parseable string
        let stringMoney = """
        {
            "money": "72.17 ep"
        }
        """.data(using: .utf8)!
        let stringContainer = try decoder.decode(MoneyContainer.self, from: stringMoney)
        #expect("\(stringContainer.money!)" == "72.17 ep", "Decoded money from string")
        
        // Test raw number
        let numberMoney = """
        {
            "money": 85
        }
        """.data(using: .utf8)!
        let numberContainer = try decoder.decode(MoneyContainer.self, from: numberMoney)
        #expect("\(numberContainer.money!)" == "85.0 gp", "Decoded money from number")
        
        // Test invalid value should result in nil for optional
        let invalidMoney = """
        {
            "money": "no money"
        }
        """.data(using: .utf8)!
        let invalidContainer = try decoder.decode(MoneyContainer.self, from: invalidMoney)
        #expect(invalidContainer.money == nil, "decoded invalid money string should be nil")
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
