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
            
    /// A dictionary of all currently loaded currencies.
    private var allCurrencies: [String: UnitCurrency] = [:]
    
    /// Returns a currencies instance that can access a currency by name, and a base unit currency (if one is specified).
    init(_ currencies: [UnitCurrency] = []) {
        add(currencies)
    }
 
    /// Returns the currency with the specified name.
    ///
    /// - parameter symbol: The shorthand name of the currency.
    public func find(_ symbol: String) -> UnitCurrency? { allCurrencies[symbol] }
    
    /// Adds the array of currencies to the collection.
    mutating func add(_ currencies: [UnitCurrency]) {
        allCurrencies = Dictionary(currencies.map { ($0.symbol, $0) }, uniquingKeysWith: { _, last in last })
        
        if let baseCurrency = allCurrencies.first(where: { $0.value.isDefault }) {
            UnitCurrency.setBaseUnit(baseCurrency.value)
        }
    }
    
    /// Returns a read-only array of all currencies.
    var all: [UnitCurrency] { Array(allCurrencies.values) }
}

extension Currencies: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case currencies
    }
    
    /// Decodes an array of currencies, setting the default currency if specified.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let currencies = try container.decode([UnitCurrency].self, forKey: .currencies)
        add(currencies)
    }
    
    /// Encodes an array of currencies.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(all, forKey: .currencies)
    }
}
