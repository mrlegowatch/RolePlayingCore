//
//  Currencies.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 6/24/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// A collection of currencies.
public struct Currencies: Codable {
            
    /// A dictionary of currencies indexed by currency symbol.
    private var allCurrencies: [String: UnitCurrency] = [:]
    
    /// A read-only array of currencies.
    var all: [UnitCurrency] { Array(allCurrencies.values) }

    /// Returns a currencies instance that can access a currency by symbol, and a base unit currency if specified.
    public init(_ currencies: [UnitCurrency] = []) {
        add(currencies)
    }
    
    /// Accesses the currency with the specified symbol.
    public subscript(symbol: String) -> UnitCurrency? {
        return allCurrencies[symbol]
    }
    
    /// Adds the array of currencies to the collection. Updates the default or base unit currency if specified.
    mutating func add(_ currencies: [UnitCurrency]) {
        allCurrencies = Dictionary(currencies.map { ($0.symbol, $0) }, uniquingKeysWith: { _, last in last })
        
        if let baseCurrency = allCurrencies.first(where: { $0.value.isDefault }) {
            UnitCurrency.setBaseUnit(baseCurrency.value)
        }
    }

    // MARK: Codable conformance
    
    private enum CodingKeys: String, CodingKey {
        case currencies
    }
    
    /// Decodes an array of currencies, updating the default or base unit currency if specified.
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
