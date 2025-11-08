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

// NOTE: @retroactive is a compiler-suggested workaround in case Measurement
// adopts CodableWithConfiguration in the future.
extension Money: @retroactive CodableWithConfiguration {
    
    public init(from decoder: any Decoder, configuration: Currencies) throws {
        let container = try decoder.singleValueContainer()
        
        if let double = try? container.decode(Double.self) {
            self = Money(value: double, unit: UnitCurrency.baseUnit())
        } else {
            let string = try container.decode(String.self)
            if let money = string.parseMoney(configuration) {
                self = money
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Failed to decode Money from \"\(string)\"")
            }
        }
    }
    
    public func encode(to encoder: any Encoder, configuration: Currencies) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

public extension String {
    
    /// Parses numbers with currency symbols into money.
    /// If there is no currency symbol, the number is associated with the base unit currency.
    func parseMoney(_ configuration: Currencies) -> Money? {
        var value: Double?
        var unit: UnitCurrency = .baseUnit()
        
        // Get a thread-safe snapshot of all currencies
        let allCurrencies = configuration.all
        for currency in allCurrencies {
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
        guard let value else { return nil }
        
        return Money(value: value, unit: unit)
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
