//
//  Money.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/11/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// A measurement of currency.
public typealias Money = Measurement<UnitCurrency>

public extension String {
    
    /// Parses numbers with currency symbols into money.
    var parseMoney: Money? {
        var value: Double?
        var unit: UnitCurrency = .baseUnit()
        
        for currency in Currencies.allCurrencies.values {
            if let range = self.range(of: currency.symbol), range.upperBound == self.endIndex {
                value = Double(self[..<range.lowerBound].trimmingCharacters(in: .whitespaces))!
                unit = currency
                break
            }
        }
        
        // Try converting string to number.
        if value == nil {
            value = Double(self)
        }
        
        // Bail if the value could not be parsed.
        guard value != nil else { return nil }
        
        return Money(value: value!, unit: unit)
    }
    
}

public extension KeyedDecodingContainer  {
    
    /// Decodes either a number or a string into Money.
    ///
    /// - throws `DecodingError.dataCorrupted` if the money could not be decoded.
    func decode(_ type: Money.Type, forKey key: K) throws -> Money {
        let money: Money?
        
        if let double = try? self.decode(Double.self, forKey: key) {
            money = Money(value: double, unit: .baseUnit())
        } else {
            money = try self.decode(String.self, forKey: key).parseMoney
        }
        
        // Throw if we were unsuccessful parsing.
        guard money != nil else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Missing string or number for Money value")
            throw DecodingError.dataCorrupted(context)
        }
        
        return money!
    }
    
    /// Decodes either a number or a string into Money, if present.
    ///
    /// - throws `DecodingError.dataCorrupted` if the money could not be decoded.
    func decodeIfPresent(_ type: Money.Type, forKey key: K) throws -> Money? {
        let money: Money?
        
        if let double = try? self.decode(Double.self, forKey: key) {
            money = Money(value: double, unit: .baseUnit())
        } else if let string = try self.decodeIfPresent(String.self, forKey: key) {
            money = string.parseMoney
        } else {
            money = nil
        }
        
        return money
    }
    
}


extension MeasurementFormatter {
    
    /// The formatter requires a specialization that knows how to find UnitCurrency's baseUnit() and
    /// long name; otherwise, the default formatting (naturalScale) will return an empty string.
    public func string<UnitType: UnitCurrency>(from measurement: Measurement<UnitType>) -> String {
        let unitToUse = unitOptions == .naturalScale ? UnitCurrency.baseUnit() : measurement.unit
        let value = unitOptions == .naturalScale ? measurement.converted(to: UnitCurrency.baseUnit() as! UnitType).value : measurement.value
        let unitsString = unitStyle == .short || unitStyle == .medium ? unitToUse.symbol : value == 1.0 ? unitToUse.name : unitToUse.plural
        
        let valueString = numberFormatter.string(from: NSNumber(value: value))!
        let formatString = unitStyle == .short ? "%@%@" : "%@ %@"
        return String(format: formatString, valueString, unitsString!)
    }
}
