//
//  Currencies.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 6/24/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

public struct Currencies {
    
    /// An array of all currently loaded currencies.
    public static var allCurrencies: [UnitCurrency] = []
    
    /// Looks up the currency instance that matches the specified symbol.
    /// Returns nil if the symbol isn't found.
    public static func find(_ symbol: String) -> UnitCurrency? {
        return allCurrencies.first(where: { $0.symbol == symbol })
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
        let `default`: Bool? // TODO: this is fishy
        
        init(_ unitCurrency: UnitCurrency) {
            self.symbol = unitCurrency.symbol
            self.coefficient = (unitCurrency.converter as! UnitConverterLinear).coefficient
            self.name = unitCurrency.name
            self.plural = unitCurrency.plural
            self.default = unitCurrency == .baseUnit()
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
            if Currencies.find(currency.symbol) == nil {
                let converter = UnitConverterLinear(coefficient: currency.coefficient)
                let unitCurrency = UnitCurrency(symbol: currency.symbol, converter: converter, name: currency.name, plural: currency.plural)
                Currencies.allCurrencies.append(unitCurrency)
                
                if currency.default != nil, currency.default! {
                    UnitCurrency.default = unitCurrency
                }
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var currencies = [Currency]()
        for unitCurrency in Currencies.allCurrencies {
            let currency = Currency(unitCurrency)
            currencies.append(currency)
        }
        
        try container.encode(currencies, forKey: .currencies)
    }
    
}
