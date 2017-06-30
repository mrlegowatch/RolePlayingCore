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
public class UnitCurrency : Dimension {
    
    /// The singular unit name used when the unitStyle is long.
    public internal(set) var name: String!
    
    /// The plural unit name used when the unitStyle is long.
    public internal(set) var plural: String!
    
    /// The default unit currency. Set during load().
    public internal(set) static var `default`: UnitCurrency?
    
    /// Returns the default unit currency. Will unwrap nil if load() hasn't been called,
    /// or if none of the loaded currencies was marked default.
    public override class func baseUnit() -> UnitCurrency {
        return UnitCurrency.default!
    }
    
    public init(symbol: String, converter: UnitConverter, name: String, plural: String) {
        self.name = name
        self.plural = plural
        super.init(symbol: symbol, converter: converter)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // TODO: In order to provide the other init method, I was required to implement
        // this one as well. However, I don't know how to reconcile NSCoder with Codable.
    }
}
