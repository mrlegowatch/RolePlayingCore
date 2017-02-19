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

public extension Measurement where UnitType: UnitCurrency {

    /// Creates an instance from a dictionary trait. If it is a raw number, the Currency baseUnit() is used.
    /// If it contains one of the known currency symbols as a suffix, those units are used.
    /// Returns nil if not a number, or if none of the known currency symbols is found.
    init?(from trait: Any?) {
        guard let trait = trait else { return nil }
        
        var value: Double?
        var unit: UnitCurrency? = .baseUnit()
        
        if let number = trait as? Int {
            value = Double(number)
        } else if let number = trait as? Double {
            value = number
        } else if let trait = trait as? String {
            for currency in UnitCurrency.allCurrencies {
                if let range = trait.range(of: currency.symbol), range.upperBound == trait.endIndex {
                    value = Double(trait.substring(to: range.lowerBound).trimmingCharacters(in: .whitespaces))!
                    unit = currency
                    break
                }
            }
        }
        // If could not parse as double or string with unit currency suffix, bail.
        guard value != nil && unit != nil else { return nil }
        
        self.init(value: value!, unit: unit as! UnitType)
    }

}

extension MeasurementFormatter {
    
    /// The formatter requires a specialization that knows how to find UnitCurrency's baseUnit() and
    /// long name; otherwise, the default formatting (naturalScale) will return an empty string.
    public func string<UnitType: UnitCurrency>(from measurement: Measurement<UnitType>) -> String {
        let unitToUse = unitOptions == .naturalScale ? UnitCurrency.baseUnit() : measurement.unit
        let value = unitOptions == .naturalScale ? measurement.converted(to: UnitCurrency.baseUnit() as! UnitType).value : measurement.value
        let unitsString = unitStyle == .short || unitStyle == .medium ? unitToUse.symbol : value == 1.0 ? unitToUse.longName : unitToUse.longNamePlural
        
        let valueString = numberFormatter.string(from: NSNumber(value: value))!
        let formatString = unitStyle == .short ? "%@%@" : "%@ %@"
        return String(format: formatString, valueString, unitsString!)
    }
    
}
