//
//  Currencies.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 6/24/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

public struct Currencies {
    
    /// A map of all currently loaded currencies.
    internal static var allCurrencies: [String: UnitCurrency] = [:]
    
    /// Returns the unit currency corresponding to this symbol. Returns nil if no symbol matches.
    public static func find(_ symbol: String) -> UnitCurrency? {
        return Currencies.allCurrencies[symbol]
    }
  
    public static func add(_ currency: UnitCurrency) {
        allCurrencies[currency.symbol] = currency
    }

    public static func setDefault(_ newBaseUnit: UnitCurrency) {
        // Remove the old base unit from all currencies.
        let oldSymbol = UnitCurrency.baseUnitCurrency.symbol
        guard oldSymbol != newBaseUnit.symbol else {
            return
        }
        
        allCurrencies[oldSymbol] = nil
        
        UnitCurrency.baseUnitCurrency = newBaseUnit
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
        
        var currencies = [Currency]()
        for unitCurrency in Currencies.allCurrencies.values {
            let currency = Currency(unitCurrency)
            currencies.append(currency)
        }
        
        try container.encode(currencies, forKey: .currencies)
    }
    
}
