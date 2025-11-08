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
    
    /// Thread-safe storage using NSLock for synchronization.
    private final class Storage: @unchecked Sendable {
        private let lock = NSLock()
        
        /// A map of all currently loaded currencies.
        private var allCurrencies: [String: UnitCurrency] = [:]
        
        /// The default or base unit currency. It must be set at runtime.
        private var baseUnitCurrency: UnitCurrency!
        
        func add(_ currencies: [UnitCurrency]) {
            lock.lock()
            defer { lock.unlock() }
            
            for currency in currencies {
                allCurrencies[currency.symbol] = currency
                if currency.isDefault {
                    baseUnitCurrency = currency
                }
            }
        }
        
        func find(_ symbol: String) -> UnitCurrency? {
            lock.lock()
            defer { lock.unlock() }
            return allCurrencies[symbol]
        }
        
        var base: UnitCurrency {
            lock.lock()
            defer { lock.unlock() }
            return baseUnitCurrency
        }
        
        var all: [UnitCurrency] {
            lock.lock()
            defer { lock.unlock() }
            return Array(allCurrencies.values)
        }
    }
    
    /// Shared storage instance.
    private static let storage = Storage()
    
    /// Returns the unit currency corresponding to this symbol. Returns nil if no symbol matches.
    public static func find(_ symbol: String) -> UnitCurrency? { storage.find(symbol) }
    
    /// Adds a collection of currencies, and updates the default or base unit currency.
    fileprivate static func add(_ currencies: [UnitCurrency]) { storage.add(currencies) }
    
    /// Returns the base unit currency.
    public static var base: UnitCurrency { storage.base }
    
    /// Returns all of the currently loaded currencies.
    public static var all: [UnitCurrency] { storage.all }
}

extension Currencies: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case currencies
    }
    
    /// Decodes an array of currencies, setting the default currency if specified.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let currencies = try container.decode([UnitCurrency].self, forKey: .currencies)
        Currencies.add(currencies)
    }
    
    /// Encodes an array of currencies.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let allCurrencies = Currencies.all
        try container.encode(allCurrencies, forKey: .currencies)
    }
}
