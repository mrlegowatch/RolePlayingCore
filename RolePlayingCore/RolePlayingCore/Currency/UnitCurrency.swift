//
//  UnitCurrency.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

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
    
    /// Creates a currency instance from a dictionary with the following keys:
    /// - symbol: a string representing the currency symbol (e.g., "cp")
    /// - coefficient: a double relative to baseUnit() (e.g., 0.01)
    /// - long name: a string representing the currency singular name (e.g., "copper piece")
    /// - long name plural: a string representing the currency plural name (e.g., "copper pieces")
    internal static func makeCurrency(from dictionary: [String:Any]) -> UnitCurrency {
        let symbol = dictionary["symbol"] as! String
        let coefficient = dictionary["coefficient"] as! Double
        
        let currency = UnitCurrency(symbol: symbol, converter: UnitConverterLinear(coefficient: coefficient))
        currency.longName = dictionary["long name"] as? String
        currency.longNamePlural = dictionary["long name plural"] as? String
        
        return currency
    }
    
    /// The default currencies JSON file name.
    public static let defaultCurrenciesFile = "DefaultCurrencies"
    
    /// Loads the specified currency file in JSON format from the specified bundle. 
    /// Defaults to a file named "DefaultCurrencies" in the main bundle.
    ///
    /// The JSON file must contain an array labeled "currency", and each array element
    /// must contain values for "symbol", "coefficient", "long name", and "long name plural".
    /// One of the currencies should contain "default" with a bool value of true.
    ///
    /// See `makeCurrency` for details on the array elements.
    public static func load(_ currenciesFile: String = defaultCurrenciesFile, in bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: currenciesFile, withExtension: "json") else { throw RuntimeError("Could not load \(currenciesFile).json from \(bundle.bundleURL)") }
        let jsonData = try Data(contentsOf: url, options: [.mappedIfSafe])
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: AnyObject]
        
        let currencies = jsonObject["currency"] as! [[String: Any]]
        for dictionary in currencies {
            let currency = UnitCurrency.makeCurrency(from: dictionary)
            
            // Throw a runtime error if this currency already exists.
            guard UnitCurrency.allCurrencies.index(of: currency) == nil else { throw RuntimeError("Currency \"\(currency.symbol)\" already loaded") }
            
            UnitCurrency.allCurrencies.append(currency)
            
            // If this is the default and the default is not yet set, set the default currency.
            if let isDefault = dictionary["default"] as? Bool, isDefault && UnitCurrency.default == nil {
                UnitCurrency.default = currency
            }
        }
    }
    
}
