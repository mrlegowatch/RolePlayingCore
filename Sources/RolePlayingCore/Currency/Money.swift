//
//  Money.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/11/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// A monetary value consisting of an amount and a currency unit.
public struct Money: Sendable {
    /// The numeric amount.
    public var value: Double
    /// The currency unit.
    public var unit: UnitCurrency

    public init(value: Double, unit: UnitCurrency) {
        self.value = value
        self.unit = unit
    }
}

extension Money: CustomStringConvertible {
    /// Formats the value and unit symbol, e.g. `"8.0 gp"`.
    public var description: String { "\(value) \(unit.symbol)" }
}

extension Money: Equatable {
    public static func == (lhs: Money, rhs: Money) -> Bool {
        lhs.unit == rhs.unit && lhs.value == rhs.value
    }
}

extension Money: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(unit)
    }
}

extension Money {
    /// Returns this amount expressed in another currency unit.
    public func converted(to target: UnitCurrency) -> Money {
        let base = unit.converter.baseUnitValue(fromValue: value)
        return Money(value: target.converter.value(fromBaseUnitValue: base), unit: target)
    }

    public static func + (lhs: Money, rhs: Money) -> Money {
        Money(value: lhs.value + rhs.converted(to: lhs.unit).value, unit: lhs.unit)
    }

    public static func - (lhs: Money, rhs: Money) -> Money {
        Money(value: lhs.value - rhs.converted(to: lhs.unit).value, unit: lhs.unit)
    }
}

extension Money {
    static let zero = Money(value: 0, unit: .baseUnit())
}

extension Money: CodableWithConfiguration {
    public typealias EncodingConfiguration = Currencies
    public typealias DecodingConfiguration = Currencies

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

        let allCurrencies = configuration.all
        for currency in allCurrencies {
            if let range = self.range(of: currency.symbol, options: .caseInsensitive), range.upperBound == self.endIndex {
                guard let parsed = Double(self[..<range.lowerBound].trimmingCharacters(in: .whitespaces)) else {
                    continue
                }
                value = parsed
                unit = currency
                break
            }
        }

        if value == nil {
            value = Double(self)
        }

        guard let value else { return nil }

        return Money(value: value, unit: unit)
    }
}

extension MeasurementFormatter {

    /// Formats a monetary value using this formatter's unit style and options.
    public func string(from money: Money) -> String {
        let unitToUse: UnitCurrency
        let value: Double
        if unitOptions == .naturalScale {
            let baseUnit = UnitCurrency.baseUnit()
            unitToUse = baseUnit
            value = money.converted(to: baseUnit).value
        } else {
            unitToUse = money.unit
            value = money.value
        }
        let unitsString: String? = unitStyle == .short || unitStyle == .medium
            ? unitToUse.symbol
            : value == 1.0 ? unitToUse.name : unitToUse.plural
        let valueString = numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        let formatString = unitStyle == .short ? "%@%@" : "%@ %@"
        return String(format: formatString, valueString, unitsString ?? unitToUse.symbol)
    }
}
