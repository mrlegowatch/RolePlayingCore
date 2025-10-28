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
    
    /// The default base unit is a currency called "credit". It may be replaced at runtime.
    internal static var baseUnitCurrency = UnitCurrency(symbol: "c", converter: UnitConverterLinear(coefficient: 1.0), name: "credit", plural: "credits")
    
    public override class func baseUnit() -> UnitCurrency {
        return baseUnitCurrency
    }
    
    public init(symbol: String, converter: UnitConverter, name: String, plural: String) {
        self.name = name
        self.plural = plural
        super.init(symbol: symbol, converter: converter)
    }
    
    // TODO: In order to provide the other init method, I was required to implement
    // this one as well. However, I don't know how to reconcile NSCoder with Codable.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
