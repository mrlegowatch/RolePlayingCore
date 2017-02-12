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

/// Interprets a dictionary trait value as a number or string with weight suffixes (e.g., lb, kg).
/// A number without a suffix is treated as pounds. Returns nil if the trait is nil or
/// if a suffix or number is not present.
///
public func weight(from trait: Any?) -> Weight? {
    guard let trait = trait else { return nil }
    
    var weight: Weight?
    
    if let number = trait as? Int {
        weight = Weight(value: Double(number), unit: .pounds)
    } else if let number = trait as? Double {
        weight = Weight(value: number, unit: .pounds)
    } else if let string = trait as? String {
        let weightMap: [String: UnitMass] = [
            "lb": .pounds,
            "kg": .kilograms]
        
        for (key, unit) in weightMap {
            if let range = string.range(of: key) {
                let value = Double(string.substring(to: range.lowerBound).trimmingCharacters(in: .whitespaces))!
                weight = Weight(value: value, unit: unit)
                break
            }
        }
    }
    
    return weight
}
