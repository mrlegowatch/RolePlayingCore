//
//  UnitCurrencyTests.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

import RolePlayingCore


class UnitCurrencyTests: XCTestCase {
    
    static var currencies: Currencies!
    
    override class func setUp() {
        super.setUp()
        
        // Only load once. TODO: this has a side effect on other unit tests: currencies are already loaded.
        let bundle = Bundle(for: UnitCurrencyTests.self)
        let decoder = JSONDecoder()
        let data = try! bundle.loadJSON("TestCurrencies")
        
        currencies = try! decoder.decode(Currencies.self, from: data)
    }
    
    func testUnitCurrency() {
        XCTAssertEqual(UnitCurrency.baseUnit(), Currencies.find("gp"), "base unit should be goldPieces")
        
        let goldPieces = Money(value: 25, unit: Currencies.find("gp")!)
        let silverPieces = Money(value: 12, unit: Currencies.find("sp")!)
        let copperPieces = Money(value: 1, unit: Currencies.find("cp")!)
        let electrumPieces = Money(value: 2, unit: Currencies.find("ep")!)
        let platinumPieces = Money(value: 2, unit: Currencies.find("pp")!)
        
        let totalPieces = goldPieces + silverPieces - copperPieces + electrumPieces - platinumPieces
        
        // Should be 25 + 1.2 - 0.01 + 1 - 20
        XCTAssertEqualWithAccuracy(totalPieces.value, 7.19, accuracy: 0.0001, "adding coins")
        
        let totalPiecesInCopper = totalPieces.converted(to: Currencies.find("cp")!)
        XCTAssertEqualWithAccuracy(totalPiecesInCopper.value, 719, accuracy: 0.01, "adding coins")
        
    }
    
    func testPrintingValues() {
        let goldPieces = Money(value: 13.7, unit: .baseUnit())
        
        let formatter = MeasurementFormatter()
        
        // Test default
        let gp = formatter.string(from: goldPieces)
        XCTAssertEqual(gp, "13.7 gp", "gold pieces")
        
        // Test provided unit
        formatter.unitOptions = [.providedUnit]
        let gpDefault = formatter.string(from: goldPieces)
        XCTAssertEqual(gpDefault, "13.7 gp", "gold pieces")
        
        let silverPieces = goldPieces.converted(to: Currencies.find("sp")!)
        let sp = formatter.string(from: silverPieces)
        XCTAssertEqual(sp, "137 sp", "silver pieces")
        
        let platinumPieces = goldPieces.converted(to: Currencies.find("pp")!)
        let ppProvided = formatter.string(from: platinumPieces)
        XCTAssertEqual(ppProvided, "1.37 pp", "platinum pieces")
        
        // Test natural scale
        formatter.unitOptions = [.naturalScale]
        let ppNatural = formatter.string(from: platinumPieces)
        XCTAssertEqual(ppNatural, "13.7 gp", "gold pieces")
        
        formatter.unitOptions = [.providedUnit]
        
        // Test short
        formatter.unitStyle = .short
        let gpShort = formatter.string(from: goldPieces)
        XCTAssertEqual(gpShort, "13.7gp", "gold pieces")
        
        // Test long
        formatter.unitStyle = .long
        let gpLong = formatter.string(from: goldPieces)
        XCTAssertEqual(gpLong, "13.7 gold pieces", "gold pieces")
        
        let gpSingularLong = formatter.string(from: Money(value: 1.0, unit: .baseUnit()))
        XCTAssertEqual(gpSingularLong, "1 gold piece", "gold piece")
    }
    
    func testMoney() {
        do {
            let gp = Money(value: 2.5, unit: .baseUnit())
            XCTAssertEqual(gp.value, 2.5, "coinage as Double should be 2.5")
        }
        
        do {
            let cp = "3.2 cp".parseMoney
            XCTAssertNotNil(cp, "coinage as cp should not be nil")
            if let cp = cp {
                XCTAssertEqualWithAccuracy(cp.value, 3.2, accuracy: 0.0001, "coinage as string cp should be 3.2")
                XCTAssertEqual(cp.unit, Currencies.find("cp"), "coinage as string cp should be copper pieces")
                XCTAssertNotEqual(cp.unit, Currencies.find("pp"), "coinage as string cp should not be platinum pieces")
            }
        }
        
        do {
            let gp = "hello".parseMoney
            XCTAssertNil(gp, "coinage as string with hello should be nil")
        }
    }
    
    func testMissingCurrenciesFile() {
        do {
            let bundle = Bundle(for: UnitCurrencyTests.self)
            _ = try bundle.loadJSON("Blarg")
            XCTFail("load should have thrown an error")
        }
        catch let error {
            XCTAssertTrue(error is ServiceError, "should be a service error")
            let description = "\(error)"
            XCTAssertTrue(description.contains("Runtime error"), "should be a runtime error")
        }
    }
    
    func testDuplicateCurrencies() {
        // Try loading the default currencies file a second time. 
        // It should ignore the duplicate currencies.
        do {
            XCTAssertEqual(Currencies.allCurrencies.count, 5, "currencies count")
            
            let bundle = Bundle(for: UnitCurrencyTests.self)
            let decoder = JSONDecoder()
            let data = try bundle.loadJSON("TestCurrencies")
            
            _ = try decoder.decode(Currencies.self, from: data)
            
            XCTAssertEqual(Currencies.allCurrencies.count, 5, "currencies count")
        }
        catch let error {
            XCTFail("duplicate currency should not throw error: \(error)")
        }
    }
    
    func testMissingCurrencyTraits() {
        let decoder = JSONDecoder()
        
        // Test missing symbol
        do {
            let traits = """
            {
                "currencies": [{"name": "Foo"}]
            }
            """.data(using: .utf8)!
            let currency = try? decoder.decode(Currencies.self, from: traits)
            XCTAssertNil(currency, "missing symbol")
        }
        
        // Test symbol with missing coefficient
        do {
            let traits = """
            {
                "currencies": [{"symbol": "Foo"}]
            }
            """.data(using: .utf8)!
            
            let currency = try? decoder.decode(Currencies.self, from: traits)
            XCTAssertNil(currency, "missing coefficient")
        }
        
        // Test list of items with missing required traits
        do {
            let traits = """
            {
                 "currencies": [{"name": "Foo"}, {"name": "Bar"}]
            }
            """.data(using: .utf8)!
            do {
                _ = try decoder.decode(Currencies.self, from: traits)
                XCTFail("should have thrown an error")
            }
            catch let error {
                print("Successfully caught error decoding missing required traits for Currencies. Error: \(error)")
            }
        }
    }

}
