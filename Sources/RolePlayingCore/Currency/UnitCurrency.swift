//
//  UnitCurrency.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation
import Synchronization

/// Units of currency or coinage.
///
/// Use `Measurement<UnitCurrency>` to hold values of currency.
public final class UnitCurrency : Dimension, @unchecked Sendable {
    
    /// The singular unit name used when the unitStyle is long.
    public internal(set) var name: String!
    
    /// The plural unit name used when the unitStyle is long.
    public internal(set) var plural: String!
    
    /// Whether this currency is meant to be the default or base unit currency.
    public internal(set) var isDefault: Bool = false
    
    /// The default or base unit currency.
    private static let base: Mutex<UnitCurrency> = Mutex(UnitCurrency(symbol: "Credits", converter: UnitConverterLinear(coefficient: 1.0), name: "Credit", plural: "Credits"))
    
    /// Sets the base unit currency using a Mutex to manage concurrency.
    public static func setBaseUnit(_ unit: UnitCurrency) {
        base.withLock { $0 = unit }
    }
    
    /// Returns the base unit currency using a Mutex to manage concurrency.
    public override class func baseUnit() -> UnitCurrency {
        base.withLock { return $0 }
    }
    
    public init(symbol: String, converter: UnitConverter, name: String, plural: String, isDefault: Bool = false) {
        self.name = name
        self.plural = plural
        self.isDefault = isDefault
        super.init(symbol: symbol, converter: converter)
    }
    
    // MARK: NSCoding Support
    
    /// Required initializer for NSCoding support, because `Dimension` conforms to `NSSecureCoding`.
    /// Since this class has a custom initializer, Swift requires all designated initializers from the superclass.
    ///
    /// This library actually uses `Codable` for serialization (see below).
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: Codable support

extension UnitCurrency: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case symbol
        case coefficient
        case name
        case plural
        case isDefault = "is default"
    }
    
    public convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let symbol = try container.decode(String.self, forKey: .symbol)
        let coefficient = try container.decode(Double.self, forKey: .coefficient)
        let name = try container.decode(String.self, forKey: .name)
        let plural = try container.decode(String.self, forKey: .plural)
        let isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false

        let converter = UnitConverterLinear(coefficient: coefficient)
        self.init(symbol: symbol, converter: converter, name: name, plural: plural, isDefault: isDefault)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.symbol, forKey: .symbol)
        try container.encode(self.converter.baseUnitValue(fromValue: 1.0), forKey: .coefficient)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.plural, forKey: .plural)
        if self.isDefault {
            try container.encode(self.isDefault, forKey: .isDefault)
        }
    }
}
