//
//  HeightParser
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// Height is a measurement of length.
public typealias Height = Measurement<UnitLength>

public extension Measurement where UnitType: UnitLength {
    
    /// Creates an instance from a dictionary trait value as a number or string with 
    /// height suffixes (e.g., 5'2", 2ft 3in, 1.7m).
    ///
    /// Feet and inches suffixes can be combined. A number without a suffix is treated as feet.
    /// Returns nil if the trait is nil or if a suffix or number is not present.
    init?(from trait: Any?) {
        guard let trait = trait else { return nil }
        
        var value: Double?
        var unit: UnitLength = .feet
        
        if let number = trait as? Int {
            value = Double(number)
        } else if let number = trait as? Double {
            value = number
        } else if let string = trait as? String {
            // Try going feet-first
            let feetList = ["'", "ft"]
            var feetEndRange: Range<String.Index>?
            for key in feetList {
                feetEndRange = string.range(of: key)
                if let feetEndRange = feetEndRange {
                    value = Double(string.substring(to: feetEndRange.lowerBound).trimmingCharacters(in: .whitespaces))!
                    break
                }
            }
            
            // Try using or adding inches
            let inchesList = ["\"", "in"]
            for key in inchesList {
                if let range = string.range(of: key) {
                    let inchesRange = Range(uncheckedBounds: (feetEndRange?.upperBound ?? string.startIndex, range.lowerBound))
                    let inches = Double(string.substring(with: inchesRange).trimmingCharacters(in: .whitespaces))!
                    let inchesInFeet = Height(value: inches, unit: .inches).converted(to: .feet).value
                    value = value != nil ? value! + inchesInFeet : inchesInFeet
                    break
                }
            }
            
            // If neither feet nor inches were specified, try metric
            if value == nil {
                let metricMap: [String: UnitLength] = [
                    "cm": .centimeters,
                    "m": .meters]
                
                for (key, metricUnit) in metricMap {
                    if let range = string.range(of: key) {
                        value = Double(string.substring(to: range.lowerBound).trimmingCharacters(in: .whitespaces))!
                        unit = metricUnit
                        break
                    }
                }
            }
        }
        
        guard value != nil else { return nil }
        
        self.init(value: value!, unit: unit as! UnitType)
    }
    
}
