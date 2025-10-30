//
//  Currencies.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 6/24/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

public struct Currencies {
    
    /// A map of all currently loaded currencies.
    internal static nonisolated(unsafe) var allCurrencies: [String: UnitCurrency] = [:]
    
    /// The default base unit is a currency called "credit". It may be replaced at runtime.
    internal static nonisolated(unsafe) var baseUnitCurrency = UnitCurrency(symbol: "c", converter: UnitConverterLinear(coefficient: 1.0), name: "credit", plural: "credits")

    /// A lock to protect access to allCurrencies from multiple threads.
    private static let lock = NSLock()
    
    /// Returns the unit currency corresponding to this symbol. Returns nil if no symbol matches.
    public static func find(_ symbol: String) -> UnitCurrency? {
        lock.lock()
        defer { lock.unlock() }
        return Currencies.allCurrencies[symbol]
    }
  
    public static func add(_ currency: UnitCurrency) {
        lock.lock()
        defer { lock.unlock() }
        allCurrencies[currency.symbol] = currency
    }

    public static func setDefault(_ newBaseUnit: UnitCurrency) {
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
    
    public static func base() -> UnitCurrency {
        lock.lock()
        defer { lock.unlock() }
        return baseUnitCurrency
    }
}

extension Currencies: Codable {
    
    /// TODO: Codable and NSCoding haven't yet converged. In the meantime,
    /// mirror UnitCurrency, using Codable instead of NSCoding.
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
    
    /// Decodes an array of currencies, setting the default currency if present.
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
