//
//  UnitCurrency.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

extension Trait {
    
    static let currency = "currency"
    
    static let `default` = "default"
    
    static let symbol = "symbol"
    
    static let coefficient = "coefficient"
    
    static let longName = "long name"
    
    static let longNamePlural = "long name plural"
    
}

/// Units of currency or coinage.
///
/// Use UnitCurrency.load() to load currencies from a JSON file;
/// the default JSON file name is "DefaultCurrencies.json".
///
/// Use `Measurement<UnitCurrency>` to hold values of currency.
public class UnitCurrency : Dimension {
    
    /// The singular unit name used when the unitStyle is long.
    public internal(set) var longName: String?
    
    /// The plural unit name used when the unitStyle is long.
    public internal(set) var longNamePlural: String?
    
    /// The default unit currency. Set during load().
    public internal(set) static var `default`: UnitCurrency?
    
    /// Returns the default unit currency. Will unwrap nil if load() hasn't been called,
    /// or if none of the loaded currencies was marked default.
    public override class func baseUnit() -> UnitCurrency {
        return UnitCurrency.default!
    }
    
    /// An array of all currently loaded currencies.
    public static var allCurrencies: [UnitCurrency] = []
    
    /// Looks up the currency instance that matches the specified symbol.
    /// Returns nil if the symbol isn't found.
    public static func find(_ symbol: String) -> UnitCurrency? {
        return allCurrencies.first(where: { $0.symbol == symbol })
    }
    
    /// Creates a currency instance from a dictionary of traits.
    ///
    /// - parameter traits: a dictionary with the following trait keys and values:
    ///   - "symbol": a required string representing the currency symbol (e.g., "cp")
    ///   - "coefficient": a required double relative to baseUnit() (e.g., 0.01)
    ///   - "long name": an optional string representing the currency singular name (e.g., "copper piece")
    ///   - "long name plural": an optional string representing the currency plural name (e.g., "copper pieces")
    ///
    /// - returns: a `UnitCurrency` instance, or `nil` if there are missing required traits.
    public static func makeCurrency(from traits: [String: Any]) -> UnitCurrency? {
        guard let symbol = traits[Trait.symbol] as? String else { return nil }
        guard let coefficient = traits[Trait.coefficient] as? Double else { return nil }
        
        let currency = UnitCurrency(symbol: symbol, converter: UnitConverterLinear(coefficient: coefficient))
        currency.longName = traits[Trait.longName] as? String
        currency.longNamePlural = traits[Trait.longNamePlural] as? String
        
        return currency
    }

    /// Loads currencies from dictionary traits.
    ///
    /// Sets the default currency, if one is specified with the "default" key.
    ///
    /// - parameter traits: a dictionary containing an array labeled "currency".
    ///   See `makeCurrency(from:)` for details on the array elements.
    ///
    /// - throws: `ServiceError.runtimeError` if a currency is missing a required trait, 
    ///   or if a currency has already been loaded.
    public static func load(from traits: [String: Any]) throws {
        let currencies = traits[Trait.currency] as! [[String: Any]]
        for dictionary in currencies {
            guard let currency = UnitCurrency.makeCurrency(from: dictionary) else { throw RuntimeError("Currency missing required symbol and/or coefficient") }
            
            // Throw a runtime error if this currency already exists.
            guard UnitCurrency.allCurrencies.index(of: currency) == nil else { throw RuntimeError("Currency \"\(currency.symbol)\" already loaded") }
            
            UnitCurrency.allCurrencies.append(currency)
            
            // If this is the default and the default is not yet set, set the default currency.
            if let isDefault = dictionary[Trait.default] as? Bool, isDefault && UnitCurrency.default == nil {
                UnitCurrency.default = currency
            }
        }
    }

    /// The default currencies JSON file name.
    public static let defaultCurrenciesFile = "DefaultCurrencies"
    
    // TODO: generalize load for any JSON file, and add a save function. Leverage TraitCoder.
    
    /// Loads the specified currency file in JSON format from the specified bundle. 
    /// Defaults to a file named "DefaultCurrencies" in the main bundle.
    ///
    /// See `load(from:)` for details on the JSON dictionary format.
    public static func load(_ currenciesFile: String = defaultCurrenciesFile, in bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: currenciesFile, withExtension: "json") else { throw RuntimeError("Could not load \(currenciesFile).json from \(bundle.bundleURL)") }
        let jsonData = try Data(contentsOf: url, options: [.mappedIfSafe])
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        
        try load(from: jsonObject)
    }
    
}
