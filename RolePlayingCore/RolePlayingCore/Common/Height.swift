//
//  Height
//  RolePlayingCore
//
//  Created by Brian Arnold on 2/5/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import Foundation

/// Height is a measurement of length.
public typealias Height = Measurement<UnitLength>

extension String {
    
    /// Parses ft or ', in or ", cm, m into a measurement of length.
    /// Returns nil if the string could not be parsed.
    public var parseHeight: Height? {
        var value: Double?
        var unit: UnitLength = .feet
        
        // Try going feet-first.
        let feetList = ["'", "ft"]
        var feetEndRange: Range<String.Index>?
        for key in feetList {
            feetEndRange = self.range(of: key)
            if let feetEndRange = feetEndRange {
                value = Double(self[..<feetEndRange.lowerBound].trimmingCharacters(in: .whitespaces))!
                break
            }
        }
        
        // Try using or adding inches.
        let inchesList = ["\"", "in"]
        for key in inchesList {
            if let range = self.range(of: key) {
                let inchesRange = Range(uncheckedBounds: (feetEndRange?.upperBound ?? self.startIndex, range.lowerBound))
                let inches = Double(self[inchesRange].trimmingCharacters(in: .whitespaces)) ?? 0
                let inchesInFeet = Measurement<UnitLength>(value: inches, unit: .inches).converted(to: .feet).value
                value = value != nil ? value! + inchesInFeet : inchesInFeet
                break
            }
        }
        
        // If neither feet nor inches were specified, try metric.
        if value == nil {
            let metricMap: [String: UnitLength] = [
                "cm": .centimeters,
                "m": .meters]
            
            for (key, metricUnit) in metricMap {
                if let range = self.range(of: key) {
                    value = Double(self[..<range.lowerBound].trimmingCharacters(in: .whitespaces))
                    if value != nil {
                        unit = metricUnit
                        break
                    }
                }
            }
        }
        
        // Try converting string to number.
        if value == nil {
            value = Double(self)
        }
        
        // Bail if the value could not be parsed.
        guard value != nil else { return nil }
        
        return Height(value: value!, unit: unit)
    }
    
}

public extension KeyedDecodingContainer  {
    
    /// Decodes either a number or a string into a Height.
    ///
    /// - throws `DecodingError.dataCorrupted` if the height could not be decoded.
    func decode(_ type: Height.Type, forKey key: K) throws -> Height {
        let height: Height?
        
        if let double = try? self.decode(Double.self, forKey: key) {
            height = Height(value: double, unit: .feet)
        } else {
            height = try self.decode(String.self, forKey: key).parseHeight
        }
        
        // Throw if we were unsuccessful parsing.
        guard height != nil else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Missing string or number for Height value")
            throw DecodingError.dataCorrupted(context)
        }
        
        return height!
    }
    
    /// Decodes either a number or a string into a Height, if present.
    ///
    /// - throws `DecodingError.dataCorrupted` if the height could not be decoded.
    func decodeIfPresent(_ type: Height.Type, forKey key: K) throws -> Height? {
        let height: Height?
        
        if let double = try? self.decode(Double.self, forKey: key) {
            height = Height(value: double, unit: .feet)
        } else if let string = try self.decodeIfPresent(String.self, forKey: key) {
            height = string.parseHeight
        } else {
            height = nil
        }
        
        return height
    }
}
