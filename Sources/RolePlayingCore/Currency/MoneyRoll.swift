//
//  MoneyRoll.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 10/5/26.
//  Copyright © 2026 Brian Arnold. Licensed under the MIT License.
//

import Foundation
import SwiftDice

/// Coin amounts per denomination where each amount is a dice expression.
///
/// Where `Money` holds fixed coin counts, `MoneyRoll` holds a dice expression per
/// denomination, e.g. "d6 gp each" or "2d8 sp and d10 gp". Call `roll()` to produce
/// a concrete `Money` value.
public struct MoneyRoll: Sendable, Hashable {
    public var quantities: [UnitCurrency: AnyRollable]

    /// Fallback base currency used when no `isDefault` denomination is present.
    /// Set automatically during JSON decode; propagated to `fixed` and `roll()`.
    var base: UnitCurrency?

    /// A constant of zero or less is dropped, the same as `Money` drops zero counts.
    public init(_ quantities: [UnitCurrency: AnyRollable] = [:]) {
        self.quantities = quantities.filter { (_, rollable) in
            guard let constant = rollable.constant else { return true }
            return constant > 0
        }
        self.base = quantities.keys.first(where: { $0.isDefault })
    }

    /// Converts every amount in `money` to a constant expression.
    public init(_ money: Money) {
        var result: [UnitCurrency: AnyRollable] = [:]
        for (unit, count) in money.quantities where count > 0 {
            result[unit] = AnyRollable(count)
        }
        self.quantities = result
        self.base = money.base
    }

    /// The dice expression for the given denomination. Setting `nil` removes the denomination.
    public subscript(currency: UnitCurrency) -> AnyRollable? {
        get { quantities[currency] }
        set { quantities[currency] = newValue }
    }

    public var isEmpty: Bool { quantities.isEmpty }

    /// The fixed amount when every denomination is a constant, otherwise `nil`.
    public var fixed: Money? {
        var result: [UnitCurrency: Int] = [:]
        for (unit, rollable) in quantities {
            guard let constant = rollable.constant else { return nil }
            if constant > 0 { result[unit] = constant }
        }
        var money = Money(result)
        money.base = base
        return money
    }

    /// Rolls every denomination once. Results of zero or less are dropped.
    public func roll() -> Money {
        var result: [UnitCurrency: Int] = [:]
        for (unit, rollable) in quantities {
            let value = rollable.roll().result
            if value > 0 { result[unit] = value }
        }
        var money = Money(result)
        money.base = base
        return money
    }
}

// MARK: - CustomStringConvertible

extension MoneyRoll: CustomStringConvertible {
    /// Shows each denomination sorted highest-value first, e.g. "d10 gp 2d8 sp".
    /// Returns "0 <base symbol>" when empty, or "0 ?" when no base is configured.
    public var description: String {
        if quantities.isEmpty {
            return "0 \(base?.symbol ?? "?")"
        }
        return quantities
            .sorted { $0.key.coefficient > $1.key.coefficient }
            .map { "\($0.value.description) \($0.key.symbol)" }
            .joined(separator: " ")
    }
}

// MARK: - Equatable & Hashable

extension MoneyRoll: Equatable {
    public static func == (lhs: MoneyRoll, rhs: MoneyRoll) -> Bool {
        lhs.quantities == rhs.quantities
    }
}

extension MoneyRoll {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(quantities)
    }
}

// MARK: - CodableWithConfiguration

extension MoneyRoll: CodableWithConfiguration {

    private struct SymbolCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    /// Decodes a money roll from an object `{"gp": "d10", "sp": "2d8", "cp": 175}`.
    /// Values are integers or dice notation strings. Unknown symbols throw a decoding error.
    public init(from decoder: any Decoder, configuration: Currencies) throws {
        let container = try decoder.container(keyedBy: SymbolCodingKey.self)
        var result: [UnitCurrency: AnyRollable] = [:]
        for key in container.allKeys {
            guard let unit = configuration[key.stringValue] else {
                throw DecodingError.dataCorruptedError(
                    forKey: key, in: container,
                    debugDescription: "Unknown currency symbol '\(key.stringValue)'"
                )
            }
            let rollable = try container.decode(AnyRollable.self, forKey: key)
            if let constant = rollable.constant, constant <= 0 { continue }
            result[unit] = rollable
        }
        quantities = result
        base = configuration.baseUnit
    }

    /// Encodes as `{"gp": "d10", "sp": "2d8", "cp": 175}`. Constants encode as integers,
    /// everything else as dice notation strings (via `AnyRollable`'s own encoding).
    public func encode(to encoder: any Encoder, configuration: Currencies) throws {
        var container = encoder.container(keyedBy: SymbolCodingKey.self)
        for (unit, rollable) in quantities {
            let key = SymbolCodingKey(stringValue: unit.symbol)!
            try container.encode(rollable, forKey: key)
        }
    }
}
