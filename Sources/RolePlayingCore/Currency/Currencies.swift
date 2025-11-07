//
//  Currencies.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 6/24/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// A collection of currencies.
public struct Currencies {
    
    /// A map of all currently loaded currencies.
    private static nonisolated(unsafe) var allCurrencies: [String: UnitCurrency] = [:]
    
    /// The default base unit is a currency called "credit". It may be replaced at runtime.
    private static nonisolated(unsafe) var baseUnitCurrency = UnitCurrency(symbol: "c", converter: UnitConverterLinear(coefficient: 1.0), name: "credit", plural: "credits")

    /// A lock to protect access to allCurrencies from multiple threads.
    private static let lock = NSLock()
    
    /// Returns the unit currency corresponding to this symbol. Returns nil if no symbol matches.
    public static func find(_ symbol: String) -> UnitCurrency? {
        lock.lock()
        defer { lock.unlock() }
        return Currencies.allCurrencies[symbol]
    }
  
    /// Adds the unit currency to the collection of currencies.
    fileprivate static func add(_ currency: UnitCurrency) {
        lock.lock()
        defer { lock.unlock() }
        allCurrencies[currency.symbol] = currency
    }

    /// Makes this unit currency the default for `Money`.
    fileprivate static func setDefault(_ newBaseUnit: UnitCurrency) {
        lock.lock()
        defer { lock.unlock() }
        
        // Remove the old base unit from all currencies.
        let oldSymbol = baseUnitCurrency.symbol
        guard oldSymbol != newBaseUnit.symbol else {
            return
        }
        
        allCurrencies[oldSymbol] = nil
        
        baseUnitCurrency = newBaseUnit
    }
    
    internal static func base() -> UnitCurrency {
        lock.lock()
        defer { lock.unlock() }
        return baseUnitCurrency
    }
    
    /// Returns a snapshot of all currency values as an array, and the base currency.
    fileprivate static func allCurrenciesAndBase() -> (all: [UnitCurrency], base: UnitCurrency) {
        lock.lock()
        defer { lock.unlock() }
        return (Array(allCurrencies.values), baseUnitCurrency)
    }
    
    /// Returns a snapshot of all currency values as an array (for safe iteration).
    /// - Returns: Array copy of all currencies to avoid holding the lock during iteration
    internal static func allValues() -> [UnitCurrency] {
        lock.lock()
        defer { lock.unlock() }
        return Array(allCurrencies.values)
    }
}

extension Currencies: Codable {
    
    /// TODO: UnitCurrency's Dimension conforms to NSCoding, not Codable . To support Codable, we
    /// use this type to mirror UnitCurrency, and then map it once decoded.
    private struct Currency: Codable {
        let symbol: String
        let coefficient: Double
        let name: String
        let plural: String
        let isDefault: Bool
        
        private enum CodingKeys: String, CodingKey {
            case symbol
            case coefficient
            case name
            case plural
            case isDefault = "is default"
        }
        
        // For writing
        init(_ unitCurrency: UnitCurrency, isDefault: Bool) {
            self.symbol = unitCurrency.symbol
            self.coefficient = (unitCurrency.converter as! UnitConverterLinear).coefficient
            self.name = unitCurrency.name
            self.plural = unitCurrency.plural
            self.isDefault = isDefault
        }
        
        // For reading
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            symbol = try container.decode(String.self, forKey: .symbol)
            coefficient = try container.decode(Double.self, forKey: .coefficient)
            name = try container.decode(String.self, forKey: .name)
            plural = try container.decode(String.self, forKey: .plural)
            isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case currencies
    }
    
    /// Decodes an array of currencies, setting the default currency if specified.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let currencies = try container.decode([Currency].self, forKey: .currencies)
        for currency in currencies {
            let converter = UnitConverterLinear(coefficient: currency.coefficient)
            let unitCurrency = UnitCurrency(symbol: currency.symbol, converter: converter, name: currency.name, plural: currency.plural)
            
            Currencies.add(unitCurrency)
            
            if currency.isDefault {
                Currencies.setDefault(unitCurrency)
            }
        }
    }
    
    /// Encodes an array of currencies.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Take a snapshot of all currencies AND the base unit in a single lock
        let allCurrenciesSnapshot = Currencies.allValues()
        let baseUnit = Currencies.base()
        
        // Now safely process the snapshot without holding the lock
        var currencies = [Currency]()
        for unitCurrency in allCurrenciesSnapshot {
            let isDefault = unitCurrency == baseUnit
            let currency = Currency(unitCurrency, isDefault: isDefault)
            currencies.append(currency)
        }
        
        try container.encode(currencies, forKey: .currencies)
    }
}
