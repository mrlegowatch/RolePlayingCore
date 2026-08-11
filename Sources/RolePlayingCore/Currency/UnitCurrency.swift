//
//  UnitCurrency.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

/// A unit of currency or coinage, defined by its symbol, exchange rate, and display names.
public struct UnitCurrency: Sendable {
    /// The short symbol used in display and JSON (e.g. "gp").
    public let symbol: String
    /// Exchange rate relative to the base unit (base unit coefficient = 1.0).
    public let coefficient: Double
    /// Singular display name (e.g. "gold piece").
    public let name: String
    /// Plural display name (e.g. "gold pieces").
    public let plural: String
    /// Whether this is the default (base) currency for the game system.
    public let isDefault: Bool

    public init(symbol: String, coefficient: Double, name: String, plural: String, isDefault: Bool = false) {
        self.symbol = symbol
        self.coefficient = coefficient
        self.name = name
        self.plural = plural
        self.isDefault = isDefault
    }
}

// MARK: - Equatable & Hashable (identity by symbol)

extension UnitCurrency: Equatable {
    public static func == (lhs: UnitCurrency, rhs: UnitCurrency) -> Bool {
        lhs.symbol == rhs.symbol
    }
}

extension UnitCurrency: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
}

// MARK: - Codable

extension UnitCurrency: Codable {

    private enum CodingKeys: String, CodingKey {
        case symbol
        case coefficient
        case name
        case plural
        case isDefault = "is default"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        coefficient = try container.decode(Double.self, forKey: .coefficient)
        name = try container.decode(String.self, forKey: .name)
        plural = try container.decode(String.self, forKey: .plural)
        isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(coefficient, forKey: .coefficient)
        try container.encode(name, forKey: .name)
        try container.encode(plural, forKey: .plural)
        if isDefault {
            try container.encode(isDefault, forKey: .isDefault)
        }
    }
}
