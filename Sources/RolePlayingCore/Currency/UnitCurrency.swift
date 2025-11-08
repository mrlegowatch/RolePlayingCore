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
/// Use `Measurement<UnitCurrency>` to hold values of currency.
public final class UnitCurrency : Dimension, @unchecked Sendable {
    
    /// The singular unit name used when the unitStyle is long.
    public internal(set) var name: String!
    
    /// The plural unit name used when the unitStyle is long.
    public internal(set) var plural: String!
    
    public internal(set) var isDefault: Bool = false
    
    public override class func baseUnit() -> UnitCurrency {
        return Currencies.base
    }
    
    public init(symbol: String, converter: UnitConverter, name: String, plural: String, isDefault: Bool = false) {
        self.name = name
        self.plural = plural
        self.isDefault = isDefault
        super.init(symbol: symbol, converter: converter)
    }
    
    // TODO: In order to provide the other init method, I was required to implement
    // this one as well. However, I don't know how to reconcile NSCoder with Codable.
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
