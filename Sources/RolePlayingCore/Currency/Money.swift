//
//  Money.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/11/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// An error thrown when a spend operation cannot be completed.
public enum MoneyError: Error {
    case insufficientFunds
}

/// A collection of coin counts across one or more denominations.
///
/// Each denomination is keyed by a `UnitCurrency` and holds an integer coin count.
/// No implicit conversion between denominations occurs during arithmetic —
/// `Money(14, of: gp) + Money(6, of: sp)` produces a wallet with both denominations.
/// Use `totalValue` when you need a single numeric total in the base currency.
public struct Money: Sendable {
    public var quantities: [UnitCurrency: Int]

    /// Fallback base currency used when no `isDefault` denomination is present in the wallet.
    /// Set automatically during JSON decode; propagated through arithmetic (left operand wins).
    var base: UnitCurrency?

    public init(_ quantities: [UnitCurrency: Int] = [:]) {
        self.quantities = quantities
        self.base = quantities.keys.first(where: { $0.isDefault })
    }

    /// Convenience initializer for a single denomination.
    public init(_ count: Int, of currency: UnitCurrency) {
        self.quantities = count > 0 ? [currency: count] : [:]
        self.base = currency
    }

    /// The coin count for the given denomination.
    public subscript(currency: UnitCurrency) -> Int {
        get { quantities[currency] ?? 0 }
        set { quantities[currency] = newValue > 0 ? newValue : nil }
    }

    /// Adds `count` coins of the given denomination. Ignored if `count` ≤ 0.
    public mutating func add(_ count: Int, of currency: UnitCurrency) {
        guard count > 0 else { return }
        quantities[currency, default: 0] += count
    }

    /// Removes `count` coins of the given denomination.
    ///
    /// Throws `MoneyError.insufficientFunds` if fewer than `count` coins are available.
    public mutating func spend(_ count: Int, of currency: UnitCurrency) throws {
        let current = quantities[currency] ?? 0
        guard current >= count else { throw MoneyError.insufficientFunds }
        let remaining = current - count
        quantities[currency] = remaining > 0 ? remaining : nil
    }

    /// Total value expressed in the base currency.
    ///
    /// Searches `quantities` for a denomination marked `isDefault` first (stable regardless of
    /// arithmetic operand order), then falls back to the stored `base` set during decode or
    /// propagated through arithmetic. Returns 0 if no base can be determined.
    public var totalValue: Double {
        let resolvedBase = quantities.keys.first(where: { $0.isDefault }) ?? base
        guard let resolvedBase else { return 0 }
        return totalValue(relativeTo: resolvedBase)
    }

    /// Total value expressed relative to the given currency.
    ///
    /// Use when you need an explicit reference unit regardless of which base the wallet
    /// was configured with.
    public func totalValue(relativeTo base: UnitCurrency) -> Double {
        quantities.reduce(0.0) { $0 + Double($1.value) * $1.key.coefficient / base.coefficient }
    }
}

// MARK: - Arithmetic

extension Money {
    /// Denomination-preserving addition. Coin counts are summed per denomination; no conversion occurs.
    public static func + (lhs: Money, rhs: Money) -> Money {
        var result = lhs.quantities
        for (unit, count) in rhs.quantities {
            result[unit, default: 0] += count
        }
        var money = Money(result)
        money.base = lhs.base ?? rhs.base
        return money
    }

    /// Denomination-preserving subtraction. Coin counts are subtracted per denomination.
    /// Denominations that reach zero or below are removed from the result.
    public static func - (lhs: Money, rhs: Money) -> Money {
        var result = lhs.quantities
        for (unit, count) in rhs.quantities {
            let remaining = (result[unit] ?? 0) - count
            result[unit] = remaining > 0 ? remaining : nil
        }
        var money = Money(result)
        money.base = lhs.base ?? rhs.base
        return money
    }
}

// MARK: - CustomStringConvertible

extension Money: CustomStringConvertible {
    /// Shows each non-zero denomination sorted highest-value first, e.g. "14 gp 6 sp 3 cp".
    /// Returns "0 <base symbol>" when empty, or "0 ?" when no base is configured.
    public var description: String {
        let nonZero = quantities.filter { $0.value > 0 }
        if nonZero.isEmpty {
            return "0 \(base?.symbol ?? "?")"
        }
        return nonZero
            .sorted { $0.key.coefficient > $1.key.coefficient }
            .map { "\($0.value) \($0.key.symbol)" }
            .joined(separator: " ")
    }
}

// MARK: - Equatable & Hashable

extension Money: Equatable {
    public static func == (lhs: Money, rhs: Money) -> Bool {
        lhs.quantities == rhs.quantities
    }
}

extension Money: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(quantities)
    }
}

// MARK: - CodableWithConfiguration

extension Money: CodableWithConfiguration {

    private struct SymbolCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    /// Decodes a money value from:
    /// - An object `{"gp": 130, "sp": 6}` — denomination-keyed coin counts (player wallet).
    ///   Unknown symbols throw a decoding error.
    /// - A string `"2 GP"` — parsed via `parseMoney` (item cost fields in JSON).
    /// - A number `130` — treated as the base currency unit (legacy format).
    public init(from decoder: any Decoder, configuration: Currencies) throws {
        // Try keyed container first (object format: {"gp": 130})
        if let keyed = try? decoder.container(keyedBy: SymbolCodingKey.self), !keyed.allKeys.isEmpty {
            var result: [UnitCurrency: Int] = [:]
            for key in keyed.allKeys {
                guard let unit = configuration[key.stringValue] else {
                    throw DecodingError.dataCorruptedError(
                        forKey: key, in: keyed,
                        debugDescription: "Unknown currency symbol '\(key.stringValue)'"
                    )
                }
                let count = try keyed.decode(Int.self, forKey: key)
                if count > 0 { result[unit] = count }
            }
            quantities = result
            base = configuration.baseUnit
            return
        }
        // Fallback: string ("2 GP") or bare number (130) — used by item cost fields
        let single = try decoder.singleValueContainer()
        if let double = try? single.decode(Double.self) {
            guard let baseUnit = configuration.baseUnit else {
                throw DecodingError.dataCorruptedError(
                    in: single,
                    debugDescription: "Cannot decode bare number without a configured base currency"
                )
            }
            quantities = [baseUnit: max(0, Int(double))]
            base = configuration.baseUnit
        } else {
            let string = try single.decode(String.self)
            guard let money = string.parseMoney(configuration) else {
                throw DecodingError.dataCorruptedError(
                    in: single,
                    debugDescription: "Failed to decode Money from \"\(string)\""
                )
            }
            quantities = money.quantities
            base = configuration.baseUnit
        }
    }

    /// Encodes as `{"gp": 130, "sp": 6}`. Denominations with zero count are omitted.
    public func encode(to encoder: any Encoder, configuration: Currencies) throws {
        var container = encoder.container(keyedBy: SymbolCodingKey.self)
        for (unit, count) in quantities where count > 0 {
            let key = SymbolCodingKey(stringValue: unit.symbol)!
            try container.encode(count, forKey: key)
        }
    }
}

// MARK: - String parsing

public extension String {
    /// Parses a string like `"14 GP"` or `"50gp"` into a `Money` value.
    ///
    /// Matches denomination symbols case-insensitively at the end of the string.
    /// A bare number with no symbol is treated as the base currency unit.
    /// Returns `nil` if no valid denomination or bare number is found, or if a bare
    /// number is encountered but no base currency is configured.
    func parseMoney(_ currencies: Currencies) -> Money? {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        for currency in currencies.all {
            if let range = trimmed.range(of: currency.symbol, options: .caseInsensitive),
               range.upperBound == trimmed.endIndex {
                let numberPart = String(trimmed[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                if let parsed = Double(numberPart) {
                    let count = Int(parsed)
                    var money = count > 0 ? Money(count, of: currency) : Money()
                    money.base = currencies.baseUnit
                    return money
                }
            }
        }
        
        // Bare number — use base unit
        guard let parsed = Double(trimmed) else { return nil }
        let count = Int(parsed)
        guard let baseUnit = currencies.baseUnit else { return nil }
        var money = count > 0 ? Money(count, of: baseUnit) : Money()
        money.base = baseUnit
        return money
    }
}
