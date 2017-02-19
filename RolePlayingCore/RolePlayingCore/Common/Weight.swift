//
//  WeightParser.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// Weight is a measurement of mass.
public typealias Weight = Measurement<UnitMass>

public extension Measurement where UnitType: UnitMass {

    /// Creates an instance from a dictionary trait value as a number or string with 
    /// weight suffixes (e.g., lb, kg).
    ///
    /// A number without a suffix is treated as pounds. Returns nil if the trait is nil or
    /// if a suffix or number is not present.
    init?(from trait: Any?) {
        guard let trait = trait else { return nil }
        
        var value: Double?
        var unit: UnitMass = .pounds
        
        if let number = trait as? Int {
            value = Double(number)
        } else if let number = trait as? Double {
            value = number
        } else if let string = trait as? String {
            let weightMap: [String: UnitMass] = [
                "lb": .pounds,
                "kg": .kilograms]
            
            for (key, weightUnit) in weightMap {
                if let range = string.range(of: key) {
                    value = Double(string.substring(to: range.lowerBound).trimmingCharacters(in: .whitespaces))!
                    unit = weightUnit
                    break
                }
            }
        }
        
        guard value != nil else { return nil }
        self.init(value: value!, unit: unit as! UnitType)
    }
    
}
