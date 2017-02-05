//
//  WeightParser.swift
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// Interprets a dictionary trait value as a number or string with weight suffixes (e.g., lb, kg).
/// A number without a suffix is treated as pounds. Returns nil if the trait is nil or
/// if a suffix or number is not present.
///
/// Use `Measurement<UnitMass>` to hold values of weight.
public func weight(from trait: Any?) -> Measurement<UnitMass>? {
    guard let trait = trait else { return nil }
    
    var weight: Measurement<UnitMass>?
    
    if let number = trait as? Double {
        weight = Measurement(value: number, unit: UnitMass.pounds)
    } else if let string = trait as? String {
        let weightMap: [String: UnitMass] = [
            "lb": .pounds,
            "kg": .kilograms]
        
        for (key, unit) in weightMap {
            if let range = string.range(of: key) {
                let value = Double(string.substring(to: range.lowerBound).trimmingCharacters(in: .whitespaces))!
                weight = Measurement(value: value, unit: unit)
                break
            }
        }
    }
    
    return weight
}
