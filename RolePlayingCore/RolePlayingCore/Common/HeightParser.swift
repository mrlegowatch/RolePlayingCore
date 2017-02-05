//
//  HeightParser
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// Interprets a dictionary trait value as a number or string with height suffixes (e.g., 5'2", 2ft 3in, 1.7m).
/// Feet and inches suffixes can be combined. A number without a suffix is treated as feet. 
/// Returns nil if the trait is nil or if a suffix or number is not present.
///
/// Use `Measurement<UnitLength>` to hold values of height.
public func height(from trait: Any?) -> Measurement<UnitLength>? {
    guard let trait = trait else { return nil }
    
    var height: Measurement<UnitLength>?
    
    if let number = trait as? Double {
        height = Measurement(value: number, unit: .feet)
    } else if let string = trait as? String {
        // Try going feet-first
        let feetList = ["'", "ft"]
        var feetEndRange: Range<String.Index>?
        for key in feetList {
            feetEndRange = string.range(of: key)
            if let feetEndRange = feetEndRange {
                let feet = Double(string.substring(to: feetEndRange.lowerBound).trimmingCharacters(in: .whitespaces))!
                height = Measurement(value: feet, unit: .feet)
                break
            }
        }
        
        // Try using or adding inches
        let inchesList = ["\"", "in"]
        for key in inchesList {
            if let range = string.range(of: key) {
                let inchesRange = Range(uncheckedBounds: (feetEndRange?.upperBound ?? string.startIndex, range.lowerBound))
                let inches = Double(string.substring(with: inchesRange).trimmingCharacters(in: .whitespaces))!
                let inchesInFeet = Measurement<UnitLength>(value: inches, unit: .inches).converted(to: .feet)
                height = height != nil ? height! + inchesInFeet : inchesInFeet
                break
            }
        }
        
        // If neither feet nor inches were specified, try metric
        if height == nil {
            let metricMap: [String: UnitLength] = [
                "cm": .centimeters,
                "m": .meters]
            
            for (key, unit) in metricMap {
                if let range = string.range(of: key) {
                    let value = Double(string.substring(to: range.lowerBound).trimmingCharacters(in: .whitespaces))!
                    height = Measurement(value: value, unit: unit)
                    break
                }
            }
        }
    }
    
    return height
}
