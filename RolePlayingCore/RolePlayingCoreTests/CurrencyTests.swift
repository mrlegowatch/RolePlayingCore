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
    
    override class func setUp() {
        super.setUp()
        
        // Only load once. TODO: this has a side effect on other unit tests: currencies are already loaded.
        try! UnitCurrency.load("TestCurrencies", in: Bundle(for: UnitCurrencyTests.self))
    }
    
    func testUnitCurrency() {
        XCTAssertEqual(UnitCurrency.baseUnit(), UnitCurrency.find("gp"), "base unit should be goldPieces")
        
        let goldPieces = Money(value: 25, unit: UnitCurrency.find("gp")!)
        let silverPieces = Money(value: 12, unit: UnitCurrency.find("sp")!)
        let copperPieces = Money(value: 1, unit: UnitCurrency.find("cp")!)
        let electrumPieces = Money(value: 2, unit: UnitCurrency.find("ep")!)
        let platinumPieces = Money(value: 2, unit: UnitCurrency.find("pp")!)
        
        let totalPieces = goldPieces + silverPieces - copperPieces + electrumPieces - platinumPieces
        
        // Should be 25 + 1.2 - 0.01 + 1 - 20
        XCTAssertEqualWithAccuracy(totalPieces.value, 7.19, accuracy: 0.0001, "adding coins")
        
        let totalPiecesInCopper = totalPieces.converted(to: UnitCurrency.find("cp")!)
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
        
        let silverPieces = goldPieces.converted(to: UnitCurrency.find("sp")!)
        let sp = formatter.string(from: silverPieces)
        XCTAssertEqual(sp, "137 sp", "silver pieces")
        
        let platinumPieces = goldPieces.converted(to: UnitCurrency.find("pp")!)
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
            let gp = Money(from: 2.5)
            XCTAssertNotNil(gp, "coinage as Double should not be nil")
            XCTAssertEqual(gp?.value, 2.5, "coinage as Double should be 2.5")
        }
        
        do {
            let cp = Money(from: "3.2 cp")
            XCTAssertNotNil(cp, "coinage as cp should not be nil")
            if let cp = cp {
                XCTAssertEqualWithAccuracy(cp.value, 3.2, accuracy: 0.0001, "coinage as string cp should be 3.2")
                XCTAssertEqual(cp.unit, UnitCurrency.find("cp"), "coinage as string cp should be copper pieces")
                XCTAssertNotEqual(cp.unit, UnitCurrency.find("pp"), "coinage as string cp should not be platinum pieces")
            }
        }
        
        do {
            let gp = Money(from: "hello")
            XCTAssertNil(gp, "coinage as string with hello should be nil")
        }
        
        do {
            let gp = Money(from: nil)
            XCTAssertNil(gp, "coinage with string as nil should be nil")
        }
    }
    
    func testMissingCurrenciesFile() {
        do {
            try UnitCurrency.load("Blarg", in: Bundle(for: UnitCurrencyTests.self))
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
            XCTAssertEqual(UnitCurrency.allCurrencies.count, 5, "currencies count")
            try UnitCurrency.load("TestCurrencies", in: Bundle(for: UnitCurrencyTests.self))
            XCTAssertEqual(UnitCurrency.allCurrencies.count, 5, "currencies count")
        }
        catch let error {
            XCTFail("duplicate currency should not throw error: \(error)")
        }
    }
    
    func testMissingCurrencyTraits() {
        // Test missing symbol
        do {
            let traits = ["name": "Foo"]
            let currency = UnitCurrency.makeCurrency(from: traits)
            XCTAssertNil(currency, "missing symbol")
        }
        
        // Test symbol with missing coefficient
        do {
            let traits = ["symbol": "Foo"]
            let currency = UnitCurrency.makeCurrency(from: traits)
            XCTAssertNil(currency, "missing coefficient")
        }
        
        // Test list of items with missing required traits
        do {
            let traits: [String: Any] = ["currency": [["name": "Foo"], ["name": "Bar"]]]
            do {
                try UnitCurrency.load(from: traits)
                XCTFail("should have thrown an error")
            }
            catch let error {
                XCTAssertTrue(error is ServiceError, "thrown ServiceError")
            }
        }
    }

}
