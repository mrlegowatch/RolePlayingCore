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
    internal private(set) static nonisolated(unsafe) var allCurrencies: [String: UnitCurrency] = [:]
    
    /// The default base unit is a currency called "credit". It may be replaced at runtime.
    fileprivate static nonisolated(unsafe) var baseUnitCurrency = UnitCurrency(symbol: "c", converter: UnitConverterLinear(coefficient: 1.0), name: "credit", plural: "credits")

    /// A lock to protect access to allCurrencies from multiple threads.
    private static let lock = NSLock()
    
    /// Returns the unit currency corresponding to this symbol. Returns nil if no symbol matches.
    public static func find(_ symbol: String) -> UnitCurrency? {
        lock.lock()
        defer { lock.unlock() }
        return Currencies.allCurrencies[symbol]
    }
  
    /// Adds the unit currency to the collection of currencies.
    public static func add(_ currency: UnitCurrency) {
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
        init(_ unitCurrency: UnitCurrency) {
            self.symbol = unitCurrency.symbol
            self.coefficient = (unitCurrency.converter as! UnitConverterLinear).coefficient
            self.name = unitCurrency.name
            self.plural = unitCurrency.plural
            self.isDefault = unitCurrency == .baseUnit()
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
        
        Currencies.lock.lock()
        let allCurrenciesSnapshot = Currencies.allCurrencies.values
        Currencies.lock.unlock()
        
        var currencies = [Currency]()
        for unitCurrency in allCurrenciesSnapshot {
            let currency = Currency(unitCurrency)
            currencies.append(currency)
        }
        
        try container.encode(currencies, forKey: .currencies)
    }
}
